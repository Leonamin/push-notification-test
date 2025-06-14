import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification_test/core/extension/date_time_ext.dart';
import 'package:push_notification_test/core/id/notification_id.dart';
import 'package:push_notification_test/data/domain/notification_instance.dart';
import 'package:push_notification_test/data/domain/notification_rule.dart';
import 'package:push_notification_test/view/notification/notification_repository.dart';
import 'package:push_notification_test/view/notification/notification_view_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationScheduler {
  final FlutterLocalNotificationsPlugin _plugin;
  final NotificationRepository _repository;

  NotificationScheduler({
    required FlutterLocalNotificationsPlugin plugin,
    required NotificationRepository repository,
  })  : _plugin = plugin,
        _repository = repository {
    _initializeTimeZone();
  }

  Future<void> initialize() async {
    _initializeTimeZone();
    await _initPlugin();
    await scheduleRemainingNotifications();
  }

  Future<void> _initPlugin() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(initSettings);
  }

  void _initializeTimeZone() {
    tz.initializeTimeZones();
  }

  /// 앱 실행 시 예약된 알림 규칙이 있으면 그 알림 규칙에 따라 알림을 생성한다
  Future<void> scheduleRemainingNotifications() async {
    final rules = await _repository.getRules();

    for (final rule in rules) {
      await scheduleNotification(rule);
    }
  }

  /// 1개의 규칙당 최대로 존재할 수 있는 알림 갯수
  static const _maxNotificationCount = 6;

  /// 최대 알림 규칙 갯수
  /// iOS의 알림 개수 제한은 64개이다
  /// 그런데 같은 알림 그룹당 최대 5개씩 미리 생성해두어야 하므로 12개가 최대이다
  static const _maxNotiRuleCount = 12;

  void scheduleNotiRule({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required TimeOfDay timeOfDay,
    required List<int> weekdays,
  }) async {
    final rules = await _repository.getRules();

    if (rules.length >= _maxNotiRuleCount) {
      throw Exception('최대 알림 규칙 갯수를 초과했습니다.');
    }

    final rule = await _repository.createRule(NotificationRuleCreateRequest(
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      timeOfDay: timeOfDay,
      weekdays: weekdays,
    ));

    await scheduleNotification(rule);
  }

  Future<void> cancelRule(int ruleId) async {
    final List<NotificationInstance> instances =
        await _repository.getInstancesByRuleId(ruleId);

    for (final instance in instances) {
      await _plugin.cancel(instance.id.id);
    }

    await _repository.deleteRule(ruleId);
    await _repository.deleteInstanceByRuleId(ruleId);
  }

  Future<List<PendingNotificationRequest>> _getPendingNotifications() async =>
      await _plugin.pendingNotificationRequests();

  Future<void> showNotification(NotificationPayload payload) async {
    await _plugin.show(
      payload.id,
      payload.title,
      payload.body,
      _notificationDetails,
    );
  }

  /// 언제 실행됨?:
  /// 1. 알림 규칙 생성 시
  /// 2. 앱 켜질 때
  /// 알림 규칙에 따라 알림을 생성하고 DB에 인스턴스 저장
  /// 알림 규칙에 따라 알림을 생성할 때 어디까지 생성할지 조건은 다음과 같다.
  /// 1. endDate까지 생성한다.
  /// 2. endDate가 아니더라도 _maxNotificationCount 갯수를 초과하면 생성하지 않는다
  Future<void> scheduleNotification(NotificationRule rule) async {
    final pendingNotifications = await _getPendingNotifications();
    final instances = await _repository.getInstancesByRuleId(rule.id);

    await _deleteExpiredNotifications(pendingNotifications, instances);

    final pendingInstances = await _getPendingInstances(rule.id);

    int createCount = _maxNotificationCount - pendingInstances.length;

    // 시작 시간 결정
    DateTime startTime;
    if (instances.isEmpty) {
      // 첫 알림인 경우 스케줄에 지정된 startDate 또는 DateTime.now() 중 더 먼저 오는 시간을 선택
      startTime = rule.startDate.isAfter(DateTime.now())
          ? rule.startDate
          : DateTime.now();
    } else {
      // 기존 알림이 있는 경우 가장 최신 알림 시간 + 1일 부터 시작
      startTime = instances
          .reduce((a, b) => a.scheduledTime.isAfter(b.scheduledTime) ? a : b)
          .scheduledTime;
      startTime = startTime.add(const Duration(days: 1));
    }

    final nextScheduledTimes =
        _findNextScheduledTimes(rule, startTime, createCount);

    for (final nextScheduledTime in nextScheduledTimes) {
      final notificationId = NotificationID(
        ruleId: rule.id,
        yyyyMMdd: nextScheduledTime.yyyyMMdd,
      );

      await _plugin.zonedSchedule(
        notificationId.id,
        rule.title,
        rule.description,
        _dateTimeToTZDateTime(nextScheduledTime),
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      await _repository.createInstance(NotificationInstanceCreateRequest(
        id: notificationId,
        ruleId: rule.id,
        description: rule.description,
        scheduledTime: nextScheduledTime,
      ));
    }
  }

  List<DateTime> _findNextScheduledTimes(
    NotificationRule rule,
    DateTime target,
    int count,
  ) {
    final nextScheduledTimes = <DateTime>[];
    // target 은 다음과 같이 초기화 될것임
    // 1. 알림 규칙 최초 생성이라 DateTime.now()
    // 2. 계속 늘리는 거라 현재까지 생성된 마지막 알림 시간

    int loopCount = 0;

    /// 알림규칙에 따라 생성 가능한 날짜인지 확인
    bool scheduledDow(DateTime date) {
      if (rule.weekdays.isEmpty) {
        return true;
      }

      if (rule.weekdays.contains(date.weekday)) {
        return true;
      }

      return false;
    }

    /// 알림은 현재 시간보다 이전이거나 같으면 생성 불가
    bool canSchedule(DateTime date) {
      final now = DateTime.now();

      if (date.isAtSameMomentAs(now)) {
        return false;
      }

      if (date.isBefore(now)) {
        return false;
      }

      return true;
    }

    DateTime startDate = target;

    while (true) {
      if (loopCount >= count) {
        break;
      }

      final nextScheduleTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        rule.timeOfDay.hour,
        rule.timeOfDay.minute,
      );

      // 현재 시간과 같으면 다음 시간으로 넘어간다
      if (!canSchedule(nextScheduleTime)) {
        startDate = startDate.add(const Duration(days: 1));
        continue;
      }

      if (scheduledDow(nextScheduleTime)) {
        nextScheduledTimes.add(nextScheduleTime);
        loopCount++;
      }
      startDate = startDate.add(const Duration(days: 1));
    }
    return nextScheduledTimes;
  }

  Future<List<NotificationInstance>> _getPendingInstances(int ruleId) async {
    final pendingNotifications = await _getPendingNotifications();
    final instances = await _repository.getInstancesByRuleId(ruleId);

    await _deleteExpiredNotifications(pendingNotifications, instances);
    return await _repository.getInstancesByRuleId(ruleId);
  }

  /// DB에 저장된 알림 인스턴스 중 현재 PendingNotificationRequest에 존재하지 않는 알림 인스턴스를 삭제한다.
  Future<void> _deleteExpiredNotifications(
    List<PendingNotificationRequest> pendingNotifications,
    List<NotificationInstance> instances,
  ) async {
    final pendingNotificationIds =
        pendingNotifications.map((e) => e.id).toList();

    for (final instance in instances) {
      if (!pendingNotificationIds.contains(instance.id.id)) {
        await _repository.deleteInstance(instance.id.id);
      }
    }
  }

  // Don't care about this

  NotificationDetails get _notificationDetails {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'push_channel',
      'Push Notifications',
      channelDescription: 'Push notifications channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  tz.TZDateTime _dateTimeToTZDateTime(DateTime dateTime) {
    final location = tz.getLocation('Asia/Seoul');
    return tz.TZDateTime.from(dateTime, location);
  }

  Future<List<NotificationRule>> getRules() async {
    return await _repository.getRules();
  }

  Future<List<NotificationInstance>> getInstances() async {
    return await _repository.getAllInstances();
  }

  Future<void> deleteAllRules() async {
    await _repository.deleteAllRules();
  }

  Future<void> deleteAllInstances() async {
    await _repository.deleteAllInstances();
  }
}

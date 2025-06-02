import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification_test/data/domain/notification_instance.dart';
import 'package:push_notification_test/data/domain/notification_rule.dart';
import 'package:push_notification_test/view/notification/notification_repository.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationScheduler {
  final FlutterLocalNotificationsPlugin _plugin;
  final NotificationRepository _repository;

  NotificationScheduler({
    required FlutterLocalNotificationsPlugin plugin,
    required NotificationRepository repository,
  })  : _plugin = plugin,
        _repository = repository;

  /// 1개의 규칙당 최대로 존재할 수 있는 알림 갯수
  static const _maxNotificationCount = 5;

  /// 최대 알림 규칙 갯수
  /// iOS의 알림 개수 제한은 64개이다
  /// 그런데 같은 알림 그룹당 최대 5개씩 미리 생성해두어야 하므로 12개가 최대이다
  static const _maxNotiRuleCount = 12;

  void scheduleNotiRule({
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
  }

  Future<List<PendingNotificationRequest>> _getPendingNotifications() async =>
      await _plugin.pendingNotificationRequests();

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
      // 첫 알림인 경우 현재 시간부터 시작
      startTime = DateTime.now();
    } else {
      // 기존 알림이 있는 경우 가장 최신 알림 시간부터 시작
      startTime = instances
          .reduce((a, b) => a.scheduledTime.isAfter(b.scheduledTime) ? a : b)
          .scheduledTime;
    }

    while (true) {
      if (createCount <= 0) {
        break;
      }

      // 생성
      final nextScheduledTime = _findNextScheduledTime(rule, startTime);

      if (nextScheduledTime.isAfter(rule.endDate)) {
        break;
      }

      await _plugin.zonedSchedule(
        nextScheduledTime.hashCode,
        rule.title,
        rule.description,
        _dateTimeToTZDateTime(nextScheduledTime),
        _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exact,
      );

      // 다음 반복을 위해 시작 시간 업데이트
      startTime = nextScheduledTime;
      createCount--;
    }
  }

  /// target을 기준으로 rule에 따라 다음 알림 시간을 가져온다
  /// 현재는 요일별 알림 규칙이므로 요일별로 알림 시간을 가져온다
  /// 예를들어 일, 수, 금 이렇게 알림이 설정되어있고 target이 월요일이라면 화요일이 아닌 수요일 알림을 가져온다
  DateTime _findNextScheduledTime(NotificationRule rule, DateTime target) {
    final nextDay = target.add(const Duration(days: 1));
    final nextWeekday = nextDay.weekday;

    if (rule.weekdays.contains(nextWeekday) || rule.weekdays.isEmpty) {
      return DateTime(
        nextDay.year,
        nextDay.month,
        nextDay.day,
        rule.timeOfDay.hour,
        rule.timeOfDay.minute,
      );
    }

    return _findNextScheduledTime(rule, nextDay);
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
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'push_channel',
      'Push Notifications',
      channelDescription: 'Push notifications channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  tz.TZDateTime _dateTimeToTZDateTime(DateTime dateTime) {
    final location = tz.getLocation('Asia/Seoul');
    return tz.TZDateTime.from(dateTime, location);
  }
}

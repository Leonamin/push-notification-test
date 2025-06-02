import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification_test/core/type/week_day.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationPayload {
  final String title;
  final String body;
  final String? payload;

  NotificationPayload({
    required this.title,
    required this.body,
    this.payload,
  });

  bool get isEmpty => title.isEmpty || body.isEmpty;
}

class NotificationViewModel extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ---

  TimeOfDay _timeOfDay = TimeOfDay.now();

  TimeOfDay get timeOfDay => _timeOfDay;

  set timeOfDay(TimeOfDay value) {
    _timeOfDay = value;
    notifyListeners();
  }

  final Map<WeekDay, bool> _weekdays = {
    WeekDay.sunday: false,
    WeekDay.monday: false,
    WeekDay.tuesday: false,
    WeekDay.wednesday: false,
    WeekDay.thursday: false,
    WeekDay.friday: false,
    WeekDay.saturday: false,
  };

  Map<WeekDay, bool> get weekdays => _weekdays;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  TextEditingController get titleController => _titleController;
  TextEditingController get bodyController => _bodyController;

  // ---

  void toggleWeekday(WeekDay weekDay) {
    _weekdays[weekDay] = !_weekdays[weekDay]!;
    notifyListeners();
  }

  // ---

  Future<void> init() async {
    await initTimeZone();
    await initializeNotifications();
  }

  Future<void> initTimeZone() async {
    try {
      tz.initializeTimeZones();
    } catch (e) {
      throw Exception('Failed to initialize time zones: $e');
    }
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

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

  int get _generateNotificationId =>
      DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Future<void> showNotification(NotificationPayload payload) async {
    final notificationId = _generateNotificationId;

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      payload.title,
      payload.body,
      _notificationDetails,
      payload: payload.payload,
    );
  }

  tz.TZDateTime _dateTimeToTZDateTime(DateTime dateTime) {
    final location = tz.getLocation('Asia/Seoul');
    return tz.TZDateTime.from(dateTime, location);
  }

  Future<void> scheduleNotification(
    NotificationPayload payload,
    DateTime scheduledTime,
  ) async {
    final notificationId = _generateNotificationId;
    final tzDateTime = _dateTimeToTZDateTime(scheduledTime);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      payload.title,
      payload.body,
      tzDateTime,
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  NotificationPayload get _notificationPayload => NotificationPayload(
        title: titleController.text,
        body: bodyController.text,
      );

  void showNotificationImmediately() {
    if (_notificationPayload.isEmpty) return;
    showNotification(_notificationPayload);
  }

  void showNotificationScheduled() {
    if (_notificationPayload.isEmpty) return;
    scheduleNotification(
      _notificationPayload,
      DateTime.now().add(Duration(seconds: 3)),
    );
  }
}

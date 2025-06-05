import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification_test/core/type/week_day.dart';
import 'package:push_notification_test/view/notification/0_components/notification_list_view.dart';
import 'package:push_notification_test/view/notification/0_components/notification_rule_list_view.dart';
import 'package:push_notification_test/view/notification/notification_scheduler.dart';

class NotificationPayload {
  final int id;
  final String title;
  final String body;
  final String? payload;

  NotificationPayload({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
  });

  bool get isEmpty => title.isEmpty || body.isEmpty;
}

class NotificationViewModel extends ChangeNotifier {
  final NotificationScheduler scheduler;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationViewModel({
    required this.scheduler,
  });

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
    await scheduler.initialize();
  }

  int get _generateNotificationId =>
      DateTime.now().millisecondsSinceEpoch ~/ 1000;

  NotificationPayload get _notificationPayload => NotificationPayload(
        id: _generateNotificationId,
        title: titleController.text,
        body: bodyController.text,
      );

  void showNotificationImmediately() async {
    if (_notificationPayload.isEmpty) return;

    await scheduler.showNotification(_notificationPayload);
  }

  void showNotificationScheduled() {
    if (_notificationPayload.isEmpty) return;

    final List<int> weekdays = _weekdays.entries
        .map((e) => e.value ? e.key.weekdayNumber : null)
        .nonNulls
        .toList();

    scheduler.scheduleNotiRule(
      title: _notificationPayload.title,
      description: _notificationPayload.body,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      timeOfDay: timeOfDay,
      weekdays: weekdays,
    );
  }

  // ---
  void showNotificationRules(BuildContext context) {
    scheduler.getRules().then((rules) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: NotificationRuleListView(items: rules),
            );
          },
        );
      }
    });
  }

  void showNotifications(BuildContext context) {
    scheduler.getInstances().then((instances) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: NotificationListView(items: instances),
            );
          },
        );
      }
    });
  }

  void deleteAllNotification() {
    flutterLocalNotificationsPlugin.cancelAll();
    scheduler.deleteAllRules();
    scheduler.deleteAllInstances();
  }
}

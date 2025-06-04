import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification_test/core/type/week_day.dart';
import 'package:push_notification_test/data/repository/notification_repository_impl.dart';
import 'package:push_notification_test/view/0_components/button/checkbox_button.dart';
import 'package:push_notification_test/view/0_components/picker/time_picker.dart';
import 'package:push_notification_test/view/notification/notification_scheduler.dart';
import 'package:push_notification_test/view/notification/notification_view_model.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  late final NotificationScheduler _scheduler = NotificationScheduler(
    plugin: FlutterLocalNotificationsPlugin(),
    repository: NotificationRepositoryImpl(),
  );
  late final NotificationViewModel _notificationViewModel;

  @override
  void initState() {
    super.initState();
    _notificationViewModel = NotificationViewModel(scheduler: _scheduler);
    _notificationViewModel.initializeNotifications();

    _notificationViewModel.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              children: [
                ScrollTimePicker(
                  initialTime: _notificationViewModel.timeOfDay,
                  minuteInterval: 1,
                  onTimeChanged: (time) {
                    _notificationViewModel.timeOfDay = time;
                  },
                ),
                _WeekdayCheckbox(
                  weekdays: _notificationViewModel.weekdays,
                  onChanged: (weekDay, isChecked) {
                    _notificationViewModel.toggleWeekday(weekDay);
                  },
                ),
                TextField(
                  controller: _notificationViewModel.titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                TextField(
                  controller: _notificationViewModel.bodyController,
                  decoration: InputDecoration(
                    labelText: 'Body',
                  ),
                ),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _notificationViewModel.showNotificationImmediately();
                      },
                      child: const Text('테스트 즉시 전송'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _notificationViewModel.showNotificationScheduled();
                      },
                      child: const Text('주기적으로 예약 전송'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _notificationViewModel.showNotificationRules(context);
                      },
                      child: const Text('예약 전송 목록 조회'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _notificationViewModel.showNotifications(context);
                      },
                      child: const Text('예약 목록 조회'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _notificationViewModel.deleteAllNotification();
                      },
                      child: const Text('DB 및 예약 알림 삭제'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekdayCheckbox extends StatelessWidget {
  /// key: 요일, value: 체크 여부
  final Map<WeekDay, bool> weekdays;

  final Function(WeekDay, bool) onChanged;

  const _WeekdayCheckbox({
    required this.weekdays,
    required this.onChanged,
  });

  bool _isChecked(WeekDay weekDay) {
    return weekdays[weekDay] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ...WeekDay.values.map(
          (weekDay) => Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onChanged(weekDay, !_isChecked(weekDay)),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  spacing: 16,
                  children: [
                    CheckBoxButton(
                      isChecked: _isChecked(weekDay),
                      onTap: () => onChanged(weekDay, !_isChecked(weekDay)),
                    ),
                    Text(weekDay.name),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

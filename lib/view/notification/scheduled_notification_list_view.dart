import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification_test/data/repository/notification_repository_impl.dart';
import 'package:push_notification_test/view/notification/notification_scheduler.dart';
import 'package:push_notification_test/view/notification/scheduled_notification_list_view_model.dart';

class ScheduledNotificationListView extends StatefulWidget {
  const ScheduledNotificationListView({super.key});

  @override
  State<ScheduledNotificationListView> createState() =>
      _ScheduledNotificationListViewState();
}

class _ScheduledNotificationListViewState
    extends State<ScheduledNotificationListView> {
  late final ScheduledNotificationListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ScheduledNotificationListViewModel(
      scheduler: NotificationScheduler(
        plugin: FlutterLocalNotificationsPlugin(),
        repository: NotificationRepositoryImpl(),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });

    _viewModel.addListener(() {
      if (!context.mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 목록'),
      ),
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _viewModel.rules.length,
            itemBuilder: (context, index) {
              final rule = _viewModel.rules[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                          const Icon(
                            Icons.alarm,
                            size: 32,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rule.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                rule.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              // 예약된 시간 TimeOfDay hh:mm
                              Text(
                                '${rule.timeOfDay.hour.toString().padLeft(2, '0')}:${rule.timeOfDay.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          _viewModel.deleteRule(rule);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 8);
            },
          ),
          if (_viewModel.isLoading) const _LoadingCoverScreen(),
        ],
      ),
    );
  }
}

class _LoadingCoverScreen extends StatelessWidget {
  const _LoadingCoverScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

import 'package:push_notification_test/core/id/notification_id.dart';

class NotificationInstance {
  /// 알림 자체 ID
  final NotificationID id;

  final int ruleId;
  final DateTime scheduledTime;

  NotificationInstance({
    required this.id,
    required this.ruleId,
    required this.scheduledTime,
  });
}

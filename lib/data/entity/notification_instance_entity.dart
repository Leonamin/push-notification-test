import 'package:push_notification_test/core/id/notification_id.dart';

class NotificationInstanceEntity {
  final NotificationID id;
  final int ruleId;
  final DateTime scheduledTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationInstanceEntity({
    required this.id,
    required this.ruleId,
    required this.scheduledTime,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id.id,
      'rule_id': ruleId,
      'scheduled_time': scheduledTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory NotificationInstanceEntity.fromJson(Map<String, dynamic> json) {
    return NotificationInstanceEntity(
      id: NotificationID.fromId(json['id'] as int),
      ruleId: json['rule_id'] as int,
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

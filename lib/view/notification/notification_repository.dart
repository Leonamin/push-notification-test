import 'package:flutter/material.dart';
import 'package:push_notification_test/core/id/notification_id.dart';
import 'package:push_notification_test/data/domain/notification_instance.dart';
import 'package:push_notification_test/data/domain/notification_rule.dart';

class NotificationRuleCreateRequest {
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay timeOfDay;
  final List<int> weekdays;

  NotificationRuleCreateRequest({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.timeOfDay,
    required this.weekdays,
  });
}

class NotificationInstanceCreateRequest {
  final NotificationID id;
  final int ruleId;
  final String description;
  final DateTime scheduledTime;

  NotificationInstanceCreateRequest({
    required this.id,
    required this.ruleId,
    required this.description,
    required this.scheduledTime,
  });
}

abstract class NotificationRepository {
  Future<NotificationRule> createRule(NotificationRuleCreateRequest request);

  Future<void> deleteAllRules();

  /// 알림 규칙 및 알림 인스턴스 모두 삭제
  Future<void> deleteRule(int id);

  Future<List<NotificationRule>> getRules();

  Future<void> createInstance(NotificationInstanceCreateRequest request);

  Future<void> deleteInstance(int id);

  Future<void> deleteAllInstances();

  Future<List<NotificationInstance>> getInstancesByRuleId(int ruleId);

  Future<List<NotificationInstance>> getAllInstances();
}

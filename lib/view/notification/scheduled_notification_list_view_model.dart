import 'package:flutter/material.dart';
import 'package:push_notification_test/data/domain/notification_rule.dart';
import 'package:push_notification_test/view/notification/notification_scheduler.dart';

class ScheduledNotificationListViewModel extends ChangeNotifier {
  final NotificationScheduler _scheduler;
  List<NotificationRule> _rules = [];

  List<NotificationRule> get rules => _rules;

  /// States
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  ScheduledNotificationListViewModel({
    required NotificationScheduler scheduler,
  }) : _scheduler = scheduler;

  Future<void> init() async {
    _rules = await _fetchRules();
    notifyListeners();
  }

  Future<List<NotificationRule>> _fetchRules() async {
    setIsLoading(true);
    final rules = await _scheduler.getRules();
    setIsLoading(false);
    return rules;
  }

  Future<void> deleteRule(NotificationRule rule) async {
    setIsLoading(true);

    await _scheduler.cancelRule(rule.id);
    _rules = await _fetchRules();
    setIsLoading(false);
  }

  void setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }
}

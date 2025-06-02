import 'package:flutter/material.dart';

class NotificationRule {
  final int id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay timeOfDay;

  /// 요일 모드일 때
  final List<int>
      weekdays; // 0: 일요일, 1: 월요일, 2: 화요일, 3: 수요일, 4: 목요일, 5: 금요일, 6: 토요일

  NotificationRule({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.timeOfDay,
    required this.weekdays,
  });
}

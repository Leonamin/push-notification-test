import 'package:flutter/material.dart';
import 'package:push_notification_test/core/extension/date_time_ext.dart';

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

  /// 알림 규칙 생성 시 startDate, endDate는 시간을 제외한 날짜만 저장한다.
  /// 시간은 timeOfDay에 저장한다.
  NotificationRule({
    required this.id,
    required this.title,
    required this.description,
    required DateTime startDate,
    required DateTime endDate,
    required this.timeOfDay,
    required this.weekdays,
  })  : startDate = startDate.toLocalize(),
        endDate = endDate.toLocalize();
}

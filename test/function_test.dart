import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_notification_test/data/domain/notification_rule.dart';

List<DateTime> _findNextScheduledTimes(
  NotificationRule rule,
  DateTime target,
  int count,
) {
  final nextScheduledTimes = <DateTime>[];
  // target 은 다음과 같이 초기화 될것임
  // 1. 알림 규칙 최초 생성이라 DateTime.now()
  // 2. 계속 늘리는 거라 현재까지 생성된 마지막 알림 시간

  int loopCount = 0;

  /// 알림규칙에 따라 생성 가능한 날짜인지 확인
  bool scheduledDow(DateTime date) {
    if (rule.weekdays.isEmpty) {
      return true;
    }

    if (rule.weekdays.contains(date.weekday)) {
      return true;
    }

    return false;
  }

  /// 알림은 현재 시간보다 이전이거나 같으면 생성 불가
  bool canSchedule(DateTime date) {
    final now = DateTime.now();

    if (date.isAtSameMomentAs(now)) {
      return false;
    }

    if (date.isBefore(now)) {
      return false;
    }

    return true;
  }

  DateTime startDate = target;

  while (true) {
    if (loopCount >= count) {
      break;
    }

    final nextScheduleTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      rule.timeOfDay.hour,
      rule.timeOfDay.minute,
    );

    // 현재 시간과 같으면 다음 시간으로 넘어간다
    if (!canSchedule(nextScheduleTime)) {
      startDate = startDate.add(const Duration(days: 1));
      continue;
    }

    if (scheduledDow(nextScheduleTime)) {
      nextScheduledTimes.add(nextScheduleTime);
      loopCount++;
    }
    startDate = startDate.add(const Duration(days: 1));
  }
  return nextScheduledTimes;
}

void main() {
  group('findNextScheduledTimes', () {
    DateTime now = DateTime.now();

    final rule = NotificationRule(
      id: 1,
      title: 'test',
      description: 'test',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 365)),
      timeOfDay: TimeOfDay(hour: now.hour + 1, minute: 0),
      weekdays: [1, 2, 3, 4, 5, 6, 7],
    );

    test('_findNextScheduledTimes target이 DateTime.now()일 때', () {
      final nextScheduledTimes =
          _findNextScheduledTimes(rule, DateTime.now(), 10);

      print('nextScheduledTimes: $nextScheduledTimes');

      expect(nextScheduledTimes.length, 10);
      expect(
          nextScheduledTimes.first,
          DateTime(now.year, now.month, now.day, rule.timeOfDay.hour,
              rule.timeOfDay.minute));
      expect(
          nextScheduledTimes.last,
          DateTime(now.year, now.month, now.day, rule.timeOfDay.hour,
                  rule.timeOfDay.minute)
              .add(const Duration(days: 9)));
    });

    test('_findNextScheduledTimes target이 오늘 지금 시간 이후의 지정날짜 + 시간일 때', () {
      final target = DateTime(now.year, now.month, now.day, rule.timeOfDay.hour,
          rule.timeOfDay.minute);
      final nextScheduledTimes = _findNextScheduledTimes(rule, target, 10);

      print('nextScheduledTimes: $nextScheduledTimes');

      expect(nextScheduledTimes.length, 10);
      expect(
          nextScheduledTimes.first,
          DateTime(now.year, now.month, now.day, rule.timeOfDay.hour,
              rule.timeOfDay.minute));
      expect(
          nextScheduledTimes.last,
          DateTime(now.year, now.month, now.day, rule.timeOfDay.hour,
                  rule.timeOfDay.minute)
              .add(const Duration(days: 9)));
    });

    test('_findNextScheduledTimes target이 오늘 지금 시간 이후의 지정날짜 + 시간일 때', () {
      final ruleBefore1Hour = NotificationRule(
        id: 1,
        title: 'test',
        description: 'test',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 365)),
        timeOfDay: TimeOfDay(hour: now.hour - 1, minute: 0),
        weekdays: [1, 2, 3, 4, 5, 6, 7],
      );

      final target = DateTime(
        now.year,
        now.month,
        now.day,
        ruleBefore1Hour.timeOfDay.hour,
        ruleBefore1Hour.timeOfDay.minute,
      );

      final nextScheduledTimes =
          _findNextScheduledTimes(ruleBefore1Hour, target, 10);

      print('nextScheduledTimes: $nextScheduledTimes');

      expect(nextScheduledTimes.length, 10);

      final expectedFirst = DateTime(
        now.year,
        now.month,
        now.day + 1,
        ruleBefore1Hour.timeOfDay.hour,
        ruleBefore1Hour.timeOfDay.minute,
      );
      expect(nextScheduledTimes.first, expectedFirst);

      final expectedLast = expectedFirst.add(const Duration(days: 9));
      expect(nextScheduledTimes.last, expectedLast);
    });
  });
}

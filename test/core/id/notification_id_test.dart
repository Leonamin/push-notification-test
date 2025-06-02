import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_notification_test/core/id/notification_id.dart';

void main() {
  group('NotificationId 생성 테스트', () {
    test('유효한 입력으로 NotificationId 생성', () {
      final notificationId = NotificationID(
        ruleId: 1,
        yyyyMMdd: '20240315',
      );

      debugPrint(notificationId.id.toString());
      debugPrint(notificationId.ruleId.toString());
      debugPrint(notificationId.yyyyMMdd);

      expect(notificationId.ruleId, 1);
      expect(notificationId.yyyyMMdd, '20240315');
    });

    test('최대 ruleId로 NotificationId 생성', () {
      final notificationId = NotificationID(
        ruleId: 2147,
        yyyyMMdd: '20240315',
      );

      expect(notificationId.ruleId, 2147);
      expect(notificationId.yyyyMMdd, '20240315');
    });

    test('날짜가 8자리가 아닌 경우 에러 발생', () {
      expect(
        () => NotificationID(ruleId: 1, yyyyMMdd: '2024031'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'yyyyMMdd는 8자리 문자열이어야 합니다.',
        )),
      );
    });

    test('ruleId가 범위를 벗어난 경우 에러 발생', () {
      expect(
        () => NotificationID(ruleId: 2148, yyyyMMdd: '20240315'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'ruleId는 1부터 2147 사이의 값이어야 합니다.',
        )),
      );

      expect(
        () => NotificationID(ruleId: 0, yyyyMMdd: '20240315'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'ruleId는 1부터 2147 사이의 값이어야 합니다.',
        )),
      );
    });

    test('유효하지 않은 날짜 형식 에러 발생', () {
      // 잘못된 월
      expect(
        () => NotificationID(ruleId: 1, yyyyMMdd: '20241315'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          '유효하지 않은 날짜 형식입니다.',
        )),
      );

      // 잘못된 일
      expect(
        () => NotificationID(ruleId: 1, yyyyMMdd: '20240332'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          '유효하지 않은 날짜 형식입니다.',
        )),
      );

      // // 잘못된 연도
      expect(
        () => NotificationID(ruleId: 1, yyyyMMdd: '19990315'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          '유효하지 않은 날짜 형식입니다.',
        )),
      );
    });

    test('숫자가 아닌 문자가 포함된 경우 에러 발생', () {
      expect(
        () => NotificationID(ruleId: 1, yyyyMMdd: '2024a315'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'yyyyMMdd는 숫자로만 구성되어야 합니다.',
        )),
      );
    });

    test('yyyyMMdd getter가 항상 8자리 문자열 반환', () {
      final notificationId = NotificationID(
        ruleId: 1,
        yyyyMMdd: '20240101',
      );

      expect(notificationId.yyyyMMdd.length, 8);
      expect(notificationId.yyyyMMdd, '20240101');
    });
  });
}

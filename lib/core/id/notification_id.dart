class NotificationID {
  late final int id;

  // 32비트 정수 최대값: 2,147,483,647
  // 2147 maxRuleId 2147
  // 483647 yymmdd 사용 무조건 2000년 이후, 48년 이전

  // 날짜 부분을 위해 1000000 (7자리) 사용
  // ruleId는 최대 2147까지 사용 가능
  static const _ruleIdMultiplier = 1000000;
  static const _maxRuleId = 2147;

  // 날짜 범위상으로는 2147까지 표현 가능하며 앞에 20을 제거하므로
  // 2000 ~ 2099년 사용 가능
  static const _maxYear = 2100;
  static const _minYear = 2000;

  NotificationID({
    required int ruleId,
    required String yyyyMMdd,
  }) {
    if (ruleId <= 0 || ruleId > _maxRuleId) {
      throw ArgumentError('ruleId는 1부터 $_maxRuleId 사이의 값이어야 합니다.');
    }

    if (yyyyMMdd.length != 8) {
      throw ArgumentError('yyyyMMdd는 8자리 문자열이어야 합니다.');
    }

    // 먼저 숫자로만 구성되어 있는지 확인
    try {
      int.parse(yyyyMMdd);
    } catch (e) {
      throw ArgumentError('yyyyMMdd는 숫자로만 구성되어야 합니다.');
    }

    // 날짜 형식 유효성 검사
    final year = int.parse(yyyyMMdd.substring(0, 4));
    final month = int.parse(yyyyMMdd.substring(4, 6));
    final day = int.parse(yyyyMMdd.substring(6, 8));

    if (year < _minYear ||
        year > _maxYear ||
        month < 1 ||
        month > 12 ||
        day < 1 ||
        day > 31) {
      throw ArgumentError('유효하지 않은 날짜 형식입니다.');
    }

    final dateValue = int.parse(yyyyMMdd) - _minYear * 10000;
    if (dateValue >= _ruleIdMultiplier) {
      throw ArgumentError('날짜 값이 너무 큽니다.');
    }

    id = ruleId * _ruleIdMultiplier + dateValue;
  }

  factory NotificationID.fromId(int id) {
    return NotificationID(
      ruleId: id ~/ _ruleIdMultiplier,
      yyyyMMdd: (id % _ruleIdMultiplier + _minYear * 10000)
          .toString()
          .padLeft(8, '0'),
    );
  }

  int get ruleId => id ~/ _ruleIdMultiplier;

  String get yyyyMMdd {
    final dateValue = id % _ruleIdMultiplier + _minYear * 10000;
    return dateValue.toString().padLeft(8, '0');
  }
}

extension DateTimeExt on DateTime {
  DateTime of({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
    );
  }

  DateTime toLocalize() => DateTime(year, month, day);

  String get yyyyMMdd =>
      '$year${month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}';
}

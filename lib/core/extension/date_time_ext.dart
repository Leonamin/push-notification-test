extension DateTimeExt on DateTime {
  String get yyyyMMdd => '$year${month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}';
}
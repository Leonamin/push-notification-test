import 'dart:convert';

class NotificationRuleEntity {
  final int id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int hour;
  final int minute;
  final List<int> weekdays;

  NotificationRuleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.hour,
    required this.minute,
    required this.weekdays,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'hour': hour,
      'minute': minute,
      'weekdays': jsonEncode(weekdays),
    };
  }

  factory NotificationRuleEntity.fromJson(Map<String, dynamic> json) {
    return NotificationRuleEntity(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      weekdays: List<int>.from(jsonDecode(json['weekdays'] as String)),
    );
  }
}

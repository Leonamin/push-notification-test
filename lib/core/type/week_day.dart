enum WeekDay {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday;

  String get name => switch (this) {
        sunday => '일요일',
        monday => '월요일',
        tuesday => '화요일',
        wednesday => '수요일',
        thursday => '목요일',
        saturday => '토요일',
        friday => '금요일',
      };

  String get shortName => switch (this) {
        sunday => '일',
        monday => '월',
        tuesday => '화',
        wednesday => '수',
        thursday => '목',
        saturday => '토',
        friday => '금',
      };
}

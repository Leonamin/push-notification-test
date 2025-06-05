enum WeekDay {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday;

  int get weekdayNumber => switch (this) {
        monday => 1,
        tuesday => 2,
        wednesday => 3,
        thursday => 4,
        friday => 5,
        saturday => 6,
        sunday => 7,
      };

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

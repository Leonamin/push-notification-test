import 'package:flutter/material.dart';
import 'package:push_notification_test/core/extension/int_ext.dart';
import 'package:push_notification_test/view/0_components/picker/number_picker.dart';
import 'package:push_notification_test/view/0_components/picker/scroll_picker.dart';

enum AmPm {
  am,
  pm,
}

extension AmPmExtension on AmPm {
  bool get isAm => this == AmPm.am;
  bool get isPm => this == AmPm.pm;

  String get text {
    switch (this) {
      case AmPm.am:
        return '오전';
      case AmPm.pm:
        return '오후';
    }
  }
}

class ScrollTimePicker extends StatefulWidget {
  const ScrollTimePicker({
    super.key,
    this.initialTime,
    this.minuteInterval = 10,
    this.is24HourFormat = false,
    this.onTimeChanged,
    this.itemHeight = 50,
    this.hourTransformer,
    this.minuteTransformer,
    this.ampmTransformer,
  });

  final TimeOfDay? initialTime;
  final int minuteInterval;
  final bool is24HourFormat;
  final double itemHeight;
  final Function(TimeOfDay)? onTimeChanged;

  final Transformer<int>? hourTransformer;
  final Transformer<int>? minuteTransformer;
  final Transformer<AmPm>? ampmTransformer;

  @override
  State<ScrollTimePicker> createState() => _ScrollTimePickerState();
}

class _ScrollTimePickerState extends State<ScrollTimePicker> {
  int _selectedhour = 0;
  int _selectedMinute = 0;
  AmPm _selectedAmPm = AmPm.am;

  // FIXME : 60분이 0으로 되면 1시간 증가가 안되는 문제있음
  int get _initialHour => widget.initialTime?.hour ?? TimeOfDay.now().hour;

  int get _initialMinute =>
      (widget.initialTime?.minute ?? TimeOfDay.now().minute)
          .roundToNearest(widget.minuteInterval);

  AmPm get _initialAmPm {
    if (_initialHour < 12) return AmPm.am;
    return AmPm.pm;
  }

  // 아이템 크기가 50이라서 150으로 맞춤 웬만하면 itemHeight * 3배로 하는게 좋을듯
  double get _pickerHeight => widget.itemHeight * 3;

  @override
  void initState() {
    super.initState();

    _selectedhour =
        (widget.is24HourFormat) ? _initialHour : _format24Hto12H(_initialHour);
    _selectedMinute = _initialMinute;
    _selectedAmPm = _initialAmPm;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _pickerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: [
            Expanded(
              child: _HourPicker(
                initHour: _selectedhour,
                is24HourFormat: widget.is24HourFormat,
                onChanged: _onHourChanged,
                itemHeight: widget.itemHeight,
                transformer: widget.hourTransformer,
              ),
            ),
            Expanded(
              child: _MinutePicker(
                initMinute: _selectedMinute,
                minuteInterval: widget.minuteInterval,
                onChanged: _onMinuteChanged,
                itemHeight: widget.itemHeight,
                transformer: widget.minuteTransformer,
              ),
            ),
            if (!widget.is24HourFormat)
              Expanded(
                child: _AmPmPicker(
                  initAmPm: _initialAmPm,
                  onChanged: _onAmPmChanged,
                  itemHeight: widget.itemHeight,
                  transformer: widget.ampmTransformer,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onHourChanged(int? hour) {
    _selectedhour = hour ?? _initialHour;
    _onTimeChanged();
  }

  // 24시간제를 12시간으로 변환
  int _format24Hto12H(int hour) {
    if (hour == 0 || hour == 12) return 12;
    return hour % 12;
  }

  // 12시간제를 24시간으로 변환
  int _format12Hto24H(int hour) {
    if (_selectedAmPm.isAm) {
      if (hour == 12) return 0;
      return hour;
    } else {
      if (hour == 12) return 12;
      return hour + 12;
    }
  }

  void _onMinuteChanged(int? minute) {
    _selectedMinute = minute ?? _initialMinute;
    _onTimeChanged();
  }

  void _onAmPmChanged(AmPm? ampm) {
    _selectedAmPm = ampm ?? AmPm.am;
    _onTimeChanged();
  }

  void _onTimeChanged() {
    late TimeOfDay time;
    if (widget.is24HourFormat) {
      time = TimeOfDay(hour: _selectedhour, minute: _selectedMinute);
    } else {
      time = TimeOfDay(
        hour: _format12Hto24H(_selectedhour),
        minute: _selectedMinute,
      );
    }

    widget.onTimeChanged?.call(time);
  }
}

class _HourPicker extends StatelessWidget {
  const _HourPicker({
    this.initHour,
    this.is24HourFormat = false,
    this.onChanged,
    this.transformer,
    this.itemHeight = 50,
  });

  final int? initHour;
  final bool is24HourFormat;
  final Function(int)? onChanged;
  final double itemHeight;

  final Transformer<int>? transformer;

  int? get _hour {
    if (initHour == null) return null;
    if (is24HourFormat) return initHour;
    return initHour! % 12 == 0 ? 12 : initHour! % 12;
  }

  int get _start => is24HourFormat ? 0 : 1;
  int get _end => is24HourFormat ? 23 : 12;

  @override
  Widget build(BuildContext context) {
    return NumberPicker(
      start: _start,
      end: _end,
      selectedItem: _hour,
      interval: 1,
      itemHeight: itemHeight,
      onChanged: onChanged,
      transformer: transformer ?? _hourToString,
    );
  }

  String? _hourToString(int hour) {
    return '$hour';
  }
}

class _MinutePicker extends StatelessWidget {
  const _MinutePicker({
    this.initMinute,
    this.minuteInterval = 10,
    this.onChanged,
    this.transformer,
    this.itemHeight = 50,
  });

  final int? initMinute;
  final int minuteInterval;
  final Function(int)? onChanged;
  final double itemHeight;

  final Transformer<int>? transformer;

  int get _minute => initMinute?.roundToNearest(minuteInterval) ?? 0;

  @override
  Widget build(BuildContext context) {
    return NumberPicker(
      start: 0,
      end: 59,
      selectedItem: _minute,
      interval: minuteInterval,
      onChanged: onChanged,
      itemHeight: itemHeight,
      transformer: transformer ?? _minuteToString,
    );
  }

  String? _minuteToString(int minute) {
    return minute.toStringAsFixed(0).padLeft(2, '0');
  }
}

class _AmPmPicker extends StatelessWidget {
  const _AmPmPicker({
    this.initAmPm,
    this.onChanged,
    this.transformer,
    this.itemHeight = 50,
  });

  final AmPm? initAmPm;
  final Function(AmPm)? onChanged;
  final double itemHeight;

  final Transformer<AmPm>? transformer;

  @override
  Widget build(BuildContext context) {
    return ScrollPicker<AmPm>(
      items: AmPm.values,
      selectedItem: initAmPm ?? AmPm.am,
      onChanged: (ampm) => onChanged?.call(ampm),
      itemHeight: itemHeight,
      transformer: transformer ?? _amPmToString,
    );
  }

  String? _amPmToString(AmPm ampm) => ampm.text;
}

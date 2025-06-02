import 'package:flutter/material.dart';
import 'package:push_notification_test/view/0_components/picker/scroll_picker.dart';

/// NumberPicker는 height와 width가 무한이므로 부모 위젯이 크기를 제한해야 합니다.
class NumberPicker extends StatelessWidget {
  const NumberPicker({
    super.key,
    this.start = 0,
    required this.end,
    required this.interval,
    this.selectedItem,
    this.onChanged,
    this.transformer,
    this.itemHeight,
    this.curve,
    this.duration,
    this.itemStyle,
    this.selectedStyle,
    this.itemBuilder,
    this.decorationBuilder,
  });

  /// 설정되어 있지 않으면 0부터 시작합니다.
  final int start;
  final int end;
  final int interval;

  final int? selectedItem;

  final Function(int)? onChanged;
  final Transformer<int>? transformer;

  /// 아이템의 높이를 지정합니다. 기본값은 50입니다.
  final double? itemHeight;

  /// 아이템을 클릭했을 때 스크롤 애니메이션의 curve를 지정합니다.
  final Curve? curve;

  /// 아이템을 클릭했을 때 스크롤 애니메이션의 duration을 지정합니다.
  final Duration? duration;

  /// 리스트에서 아이템 텍스트의 스타일을 지정합니다. itemBuilder가 있으면 무시됩니다.
  final TextStyle? itemStyle;

  /// 리스트에서 선택된 아이템 텍스트의 스타일을 지정합니다. itemBuilder가 있으면 무시됩니다.
  final TextStyle? selectedStyle;

  /// 직접 커스텀 아이템 위젯을 만들 수 있습니다.
  final NullableIndexedWidgetBuilder? itemBuilder;

  /// ScrollPicker의 선택영역을 커스텀할 수 있습니다.
  final WidgetBuilder? decorationBuilder;

  @override
  Widget build(BuildContext context) {
    return ScrollPicker<int>(
      items: _generateNumbers(),
      selectedItem: selectedItem ?? start,
      onChanged: (time) => onChanged?.call(time),
      transformer: transformer,
      itemHeight: itemHeight,
      curve: curve,
      duration: duration,
      itemStyle: itemStyle,
      selectedStyle: selectedStyle,
      itemBuilder: itemBuilder,
      decorationBuilder: decorationBuilder,
    );
  }

  List<int> _generateNumbers() {
    final numbers = <int>[];
    for (int i = start; i <= end; i += interval) {
      numbers.add(i);
    }
    return numbers;
  }
}

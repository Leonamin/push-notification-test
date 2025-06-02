import 'package:flutter/material.dart';

typedef Transformer<T> = String? Function(T item);

/// ScrollPicker는 height와 width가 무한이므로 부모 위젯이 크기를 제한해야 합니다.
class ScrollPicker<T> extends StatefulWidget {
  const ScrollPicker({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    this.transformer,
    this.itemHeight,
    this.curve,
    this.duration,
    this.itemStyle,
    this.selectedStyle,
    this.itemBuilder,
    this.decorationBuilder,
  });

  final ValueChanged<T> onChanged;

  final List<T> items;
  final T selectedItem;

  /// 아이템이 표시될 이름 없으면 item.toString()을 사용합니다.
  final Transformer<T>? transformer;

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
  State<ScrollPicker> createState() => _ScrollPickerState<T>();
}

class _ScrollPickerState<T> extends State<ScrollPicker<T>> {
  static const double defaultItemHeight = 50.0;

  late double _widgetHeight;

  late T _selectedItem;

  late ScrollController _scrollController;

  late final double _minScrollExtent = 0.0;
  late final double _maxScrollExtent = _itemHeight * widget.items.length;

  double get _itemHeight => widget.itemHeight ?? defaultItemHeight;

  TextStyle get _defaultItemStyle =>
      widget.itemStyle ??
      TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        color: Colors.grey[700],
      );

  TextStyle get _selectedStyle =>
      widget.selectedStyle ??
      TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      );

  @override
  void initState() {
    super.initState();

    _selectedItem = widget.selectedItem;

    int initialItem = widget.items.indexOf(_selectedItem);
    if (initialItem == -1) {
      initialItem = 0;
    }
    _scrollController = FixedExtentScrollController(initialItem: initialItem);
  }

  @override
  void didUpdateWidget(covariant ScrollPicker<T> oldWidget) {
    if (oldWidget.items.length != widget.items.length) {
      _selectedItem = widget.selectedItem;

      int initialItem = widget.items.indexOf(_selectedItem);
      if (initialItem == -1) {
        initialItem = 0;
      }

      _scrollController.animateTo(
        initialItem * _itemHeight,
        duration: widget.duration ?? const Duration(milliseconds: 100),
        curve: widget.curve ?? Curves.easeInOut,
      );
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _widgetHeight = constraints.maxHeight;

        return Stack(
          children: <Widget>[
            if (widget.decorationBuilder != null)
              Center(
                child: SizedBox(
                  height: _itemHeight,
                  child: widget.decorationBuilder!(context),
                ),
              ),
            GestureDetector(
              onTapUp: _itemTapped,
              child: ListWheelScrollView.useDelegate(
                childDelegate: ListWheelChildBuilderDelegate(
                  builder: (BuildContext context, int index) {
                    if (index < 0 || index > widget.items.length - 1) {
                      return null;
                    }

                    final item = widget.items[index];

                    final TextStyle itemStyle = (item == _selectedItem)
                        ? _selectedStyle
                        : _defaultItemStyle;

                    return widget.itemBuilder?.call(context, index) ??
                        Center(
                          child: Text(
                            widget.transformer?.call(item) ?? '$item',
                            style: itemStyle,
                          ),
                        );
                  },
                ),
                controller: _scrollController,
                itemExtent: _itemHeight,
                onSelectedItemChanged: _onSelectedItemChanged,
                physics: const FixedExtentScrollPhysics(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _itemTapped(TapUpDetails details) {
    Offset position = details.localPosition;
    double center = _widgetHeight / 2;
    double changeBy = position.dy - center;
    double newPosition = _scrollController.offset + changeBy;

    if (newPosition < _minScrollExtent) {
      newPosition = _minScrollExtent;
    } else if (newPosition > _maxScrollExtent) {
      newPosition = _maxScrollExtent;
    }

    _scrollController.animateTo(
      newPosition,
      duration: widget.duration ?? const Duration(milliseconds: 100),
      curve: widget.curve ?? Curves.easeInOut,
    );
  }

  void _onSelectedItemChanged(int index) {
    if (index < 0 || index > widget.items.length - 1) {
      return;
    }

    T newValue = widget.items[index];
    if (newValue != _selectedItem) {
      setState(() {
        _selectedItem = newValue;
      });
      widget.onChanged(newValue);
    }
  }
}

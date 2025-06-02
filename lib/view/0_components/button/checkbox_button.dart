import 'package:flutter/material.dart';

class CheckBoxButton extends StatefulWidget {
  const CheckBoxButton({
    super.key,
    required this.isChecked,
    this.onTap,
    this.size,
    this.margin,
    this.borderRadius,
    this.debounceTime,
  });

  final bool isChecked;
  final Function()? onTap;
  final double? size;
  final double? margin;
  final double? borderRadius;
  final int? debounceTime;

  factory CheckBoxButton.form({
    Key? key,
    required bool isChecked,
    Function()? onTap,
  }) {
    return CheckBoxButton(
      key: key,
      isChecked: isChecked,
      onTap: onTap,
      borderRadius: 0,
      size: 18,
    );
  }

  @override
  State<CheckBoxButton> createState() => _CheckBoxButtonState();
}

class _CheckBoxButtonState extends State<CheckBoxButton> {
  bool _isHover = false;
  bool get _isChecked => widget.isChecked;
  bool get _isDisabled => widget.onTap == null;

  // fill Color
  Color? get _fillColor {
    if (_isDisabled) return Colors.grey;
    if (_isChecked) return Colors.blue;
    return Colors.white;
  }

  // border
  Border? get _border {
    if (_isDisabled) return Border.all(color: Colors.grey);
    if (_isChecked) return Border.all(color: Colors.blue);
    if (_isHover) return Border.all(color: Colors.blue);
    return Border.all(color: Colors.grey);
  }

  // icon Color
  Color get _iconColor {
    if (_isDisabled) return Colors.grey;
    if (_isChecked) return Colors.blue;
    if (_isHover) return Colors.blue;
    return Colors.grey;
  }

  // boxShadow
  List<BoxShadow>? get _boxShadow {
    if (_isDisabled) return null;
    // if (_isChecked && _isHover) return BoxDecorations.activeShadow;
    // if (_isHover) return BoxDecorations.inActiveShadow;
    return null;
  }

  /// in milliseconds
  late int? debounceTime = widget.debounceTime ?? 600;
  DateTime? _lastClickTime;

  _debounceTap() {
    final now = DateTime.now();
    if (_lastClickTime == null) {
      _lastClickTime = now;
      _click();
    } else {
      if (now.difference(_lastClickTime!).inMilliseconds > debounceTime!) {
        _lastClickTime = now;
        _click();
      }
    }
  }

  void _click() {
    widget.onTap?.call();
  }

  double get _checkBoxSize => widget.size ?? 16;

  double get _iconSize => _checkBoxSize * 0.7;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _debounceTap,
      onTapDown: (_) => setState(() => _isHover = true),
      onTapUp: (_) => setState(() => _isHover = false),
      onTapCancel: () => setState(() => _isHover = false),
      child: Container(
        width: _checkBoxSize,
        height: _checkBoxSize,
        margin: EdgeInsets.all(widget.margin ?? 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 4),
          color: _fillColor,
          border: _border,
          boxShadow: _boxShadow,
        ),
        child: Icon(
          Icons.check,
          color: _iconColor,
          size: _iconSize,
        ),
        // child: SvgPicture.asset(
        //   NewSvgIconType.check.svgPath,
        //   colorFilter: ColorFilter.mode(
        //     _iconColor,
        //     BlendMode.srcIn,
        //   ),
        // ),
      ),
    );
  }
}

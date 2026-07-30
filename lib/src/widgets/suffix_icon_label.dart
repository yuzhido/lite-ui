import 'package:flutter/material.dart';

class SuffixIconLabel extends StatelessWidget {
  final String? selectedValue;
  final List<String>? selectedValues;
  final bool isExpanded;

  /// 有值时点击清除回调（点击 close 图标时触发）
  final VoidCallback? onClear;

  const SuffixIconLabel({super.key, this.selectedValue, this.selectedValues, this.isExpanded = false, this.onClear});

  bool get _hasValue => selectedValue != null || (selectedValues?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    final widget = Container(
      padding: const EdgeInsets.all(6),
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(color: _hasValue ? Colors.red.shade50 : Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
      child: Icon(
        _hasValue
            ? Icons.close
            : isExpanded
            ? Icons.keyboard_arrow_down_rounded
            : Icons.keyboard_arrow_right_rounded,
        size: 20,
        color: _hasValue ? Colors.red.shade400 : Colors.blue.shade600,
        weight: 2.5,
      ),
    );
    // 有值且传递了 onClear 时，包裹 GestureDetector 支持点击清除
    if (_hasValue && onClear != null) {
      return InkWell(onTap: onClear, child: widget);
    }
    return widget;
  }
}

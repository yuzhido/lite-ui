import 'package:flutter/material.dart';

class SuffixClearIcon extends StatelessWidget {
  final String? selectedValue;
  final List<String>? selectedValues;
  final bool hasValue;
  const SuffixClearIcon({super.key, this.selectedValue, this.selectedValues, this.hasValue = true});
  @override
  Widget build(BuildContext context) {
    return hasValue
        ? Container(
            padding: const EdgeInsets.all(5),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
            // decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
            child: Icon(Icons.close, size: 20),
            // Icon(
            //   selectedValue != null || (selectedValues?.isNotEmpty ?? false)
            //       ? Icons.close
            //       : isExpanded
            //       ? Icons.keyboard_arrow_down_rounded
            //       : Icons.keyboard_arrow_right_rounded,
            //   size: 20,
            //   color: selectedValue != null || (selectedValues?.isNotEmpty ?? false) ? Colors.red.shade400 : Colors.blue.shade600,
            //   weight: 2.5,
            // ),
          )
        : SizedBox.shrink();
  }
}

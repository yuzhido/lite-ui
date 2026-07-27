import 'package:flutter/material.dart';

class SuffixIconLabel extends StatelessWidget {
  final String? selectedValue;
  final List<String>? selectedValues;
  final bool isExpanded;
  const SuffixIconLabel({super.key, this.selectedValue, this.selectedValues, this.isExpanded = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: (selectedValue != null || (selectedValues?.isNotEmpty ?? false)) ? Colors.red.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        selectedValue != null || (selectedValues?.isNotEmpty ?? false)
            ? Icons.close
            : isExpanded
            ? Icons.keyboard_arrow_down_rounded
            : Icons.keyboard_arrow_right_rounded,
        size: 20,
        color: selectedValue != null || (selectedValues?.isNotEmpty ?? false) ? Colors.red.shade400 : Colors.blue.shade600,
        weight: 2.5,
      ),
    );
  }
}

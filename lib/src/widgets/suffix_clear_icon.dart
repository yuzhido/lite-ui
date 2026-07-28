import 'package:flutter/material.dart';

import '../input_text/models/enum.dart';

class SuffixClearIcon extends StatelessWidget {
  final String? selectedValue;
  final List<String>? selectedValues;
  final ValueChanged<SuffixIconEvent>? onTap;
  final bool hasValue;
  const SuffixClearIcon({super.key, this.selectedValue, this.selectedValues, this.onTap, this.hasValue = true});
  @override
  Widget build(BuildContext context) {
    return hasValue
        ? InkWell(
            onTap: () => onTap?.call(SuffixIconEvent.clear),
            child: Container(
              padding: const EdgeInsets.all(5),
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
              // decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
              child: Icon(Icons.close, size: 20),
            ),
          )
        : SizedBox.shrink();
  }
}

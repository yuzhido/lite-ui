import 'package:flutter/material.dart';

import '../models/enum.dart';

class ClearIcon extends StatelessWidget {
  final Widget? suffixIcon;
  final IconData? suffixIconData;
  final ValueChanged<SuffixIconEvent>? onTap;
  final bool hasValue;
  final bool password;
  final bool isShowPassword;

  const ClearIcon({super.key, this.onTap, this.hasValue = false, this.suffixIcon, this.suffixIconData, required this.password, required this.isShowPassword})
    : assert(suffixIcon == null || suffixIconData == null, 'suffixIcon 和 suffixIconData 不能同时传递！');
  @override
  Widget build(BuildContext context) {
    if (password) {
      return GestureDetector(
        onTap: () => onTap?.call(SuffixIconEvent.showPassword),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(isShowPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: const Color(0xFF94A3B8)),
        ),
      );
    }
    if (suffixIcon != null) {
      return InkWell(onTap: () => onTap?.call(SuffixIconEvent.onTap), child: suffixIcon);
    } else if (suffixIconData != null) {
      return InkWell(onTap: () => onTap?.call(SuffixIconEvent.onTap), child: Icon(suffixIconData));
    } else if (hasValue) {
      return InkWell(
        onTap: () => onTap?.call(SuffixIconEvent.clear),
        child: Container(
          padding: const EdgeInsets.all(5),
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
          // decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
          child: Icon(Icons.close, size: 20),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

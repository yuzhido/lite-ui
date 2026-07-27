import 'package:flutter/material.dart';

class PrefixIconLabel extends StatelessWidget {
  final String label;
  final bool required;
  final double? labelWidth;
  final Widget? prefixIcon;
  final IconData? prefixIconData;
  final Color? prefixIconColor;

  const PrefixIconLabel({required this.label, this.required = false, super.key, this.labelWidth, this.prefixIcon, this.prefixIconData, this.prefixIconColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 5),
      child: Stack(
        children: [
          // 主要内容
          Container(
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              spacing: 5,
              mainAxisSize: MainAxisSize.min,
              children: [
                prefixIcon ?? Icon(prefixIconData ?? Icons.edit_calendar_rounded, size: 20, color: prefixIconColor),
                SizedBox(
                  width: labelWidth ?? 65,
                  child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          // 是否必填
          if (required)
            Positioned(
              // top: 0,
              bottom: 0,
              child: Text(
                '*',
                strutStyle: StrutStyle(leading: 0, forceStrutHeight: true),
                style: TextStyle(color: Colors.red, fontSize: 16, height: 1),
              ),
            ),
        ],
      ),
    );
  }
}

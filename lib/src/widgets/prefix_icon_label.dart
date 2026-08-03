import 'package:flutter/material.dart';

class PrefixIconLabel extends StatelessWidget {
  final String? label;
  final bool required;
  final double? labelWidth;
  final Widget? prefixIcon;
  final IconData? prefixIconData;
  final Color? prefixIconColor;

  const PrefixIconLabel({this.label, this.required = false, super.key, this.labelWidth, this.prefixIcon, this.prefixIconData, this.prefixIconColor})
    : assert(prefixIcon == null || prefixIconData == null, 'prefixIcon 和 prefixIconData 只能传递其中一个');
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(left: 8),
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              spacing: 5,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (prefixIcon != null) prefixIcon! else if (prefixIconData != null) Icon(prefixIconData, size: 20, color: prefixIconColor),
                SizedBox(
                  width: labelWidth ?? ((label != null) ? 65 : null),
                  child: Text(label ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),

        // 是否必填
        if (required)
          Positioned(
            left: 4,
            bottom: 0,
            child: Text(
              '*',
              strutStyle: StrutStyle(leading: 0, forceStrutHeight: true),
              style: TextStyle(color: Colors.red, fontSize: 16, height: 1),
            ),
          ),
      ],
    );
  }
}

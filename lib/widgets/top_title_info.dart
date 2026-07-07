import 'package:flutter/material.dart';

class TopTitleInfo extends StatelessWidget {
  final String title;
  final String? subTitle;
  const TopTitleInfo({required this.title, this.subTitle, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
              ),
              if (subTitle != null)
                Text(
                  subTitle ?? '--',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF999999)),
                ),
            ],
          ),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.topRight,
              child: Icon(Icons.close_rounded, size: 24, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

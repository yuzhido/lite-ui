import 'package:flutter/material.dart';

class ChooseDefaultUi extends StatelessWidget {
  const ChooseDefaultUi({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                                  ],
              ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE2E8F0)),
            child: Icon(Icons.chevron_right, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

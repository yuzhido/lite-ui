import 'package:flutter/material.dart';

import '../wrapper_container/index.dart';

class DropdownChoose extends StatefulWidget {
  final String formLabel;
  const DropdownChoose({super.key, required this.formLabel});
  @override
  State<DropdownChoose> createState() => _DropdownChooseState();
}

class _DropdownChooseState extends State<DropdownChoose> {
  @override
  Widget build(BuildContext context) {
    return WrapperContainer(
      formLabel: widget.formLabel,
      onTap: () {
        print('点击了包装容器');
      },
    );
  }
}

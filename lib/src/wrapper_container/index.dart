import 'package:flutter/material.dart';
import 'package:lite_ui/src/widgets/prefix_icon_label.dart';
import 'package:lite_ui/src/widgets/suffix_icon_label.dart';

/// 包装容器
///
/// 用于包装其他组件，提供表单标签 + 值显示 + 后缀图标的统一布局
class WrapperContainer extends StatelessWidget {
  /// 点击回调
  final VoidCallback? onTap;

  /// 表单标签（左侧）
  final String? formLabel;

  /// 选中的值文本（中间显示，有值时高亮色）
  final String? valueText;

  /// 占位提示文字（无值时显示）
  final String? hintText;

  /// 是否必填
  final bool? required;

  const WrapperContainer({super.key, this.onTap, this.formLabel, this.valueText, this.hintText, this.required});

  @override
  Widget build(BuildContext context) {
    final hasValue = valueText != null && valueText!.isNotEmpty;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            PrefixIconLabel(required: required ?? false, label: formLabel ?? '表单标签'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(hasValue ? valueText! : (hintText ?? ''), style: TextStyle(fontSize: 16, color: hasValue ? Colors.black87 : Colors.black54)),
              ),
            ),
            SuffixIconLabel(),
          ],
        ),
      ),
    );
  }
}

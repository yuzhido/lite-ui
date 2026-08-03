import 'package:flutter/material.dart';

/// 三态选择指示器（纯 UI 组件）
///
/// 用于多选场景的选中状态展示（全图标实现）：
/// - [selected] = true：全选，check_circle 实心主色圆白勾
/// - [halfSelected] = true：半选，remove_circle 实心主色圆横线
/// - 两者均为 false：未选，radio_button_unchecked 灰色空心圆
class SelectIndicator extends StatelessWidget {
  /// 是否全选
  final bool selected;

  /// 是否半选（仅 selected 为 false 时生效）
  final bool halfSelected;

  /// 主色（全选/半选图标颜色）
  final Color color;

  /// 指示器尺寸
  final double size;

  const SelectIndicator({super.key, this.selected = false, this.halfSelected = false, this.color = const Color(0xFF007AFF), this.size = 22});

  @override
  Widget build(BuildContext context) {
    // 全选：实心主色圆 + 白色对勾
    if (selected) {
      return Icon(Icons.check_circle, size: size, color: color);
    }
    // 半选：实心主色圆 + 白色横线（部分选中语义）
    if (halfSelected) {
      return Icon(Icons.remove_circle, size: size, color: color);
    }
    // 未选：灰色空心圆环
    return Icon(Icons.radio_button_unchecked, size: size, color: Colors.grey.shade300);
  }
}

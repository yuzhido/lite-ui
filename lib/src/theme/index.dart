import 'package:flutter/material.dart';

/// LiteUI 主题数据
///
/// 承载库级别的默认颜色配置，使用方可在 App 层通过 [LiteUITheme] 包裹来自定义样式。
class LiteUIThemeData {
  /// 默认边框颜色
  final Color borderColor;

  /// 错误状态边框颜色
  final Color errorColor;

  /// 聚焦状态边框颜色（为 null 时使用系统主题色）
  final Color? focusBorderColor;

  /// 默认圆角半径
  final double borderRadius;

  /// 提示文字颜色
  final Color hintColor;

  /// 文字颜色
  ///
  /// 默认文字颜色  Colors.black87
  final Color textColor;

  /// 标签背景颜色（用于 tags / compact 显示模式）
  final Color tagColor;

  const LiteUIThemeData({
    this.borderColor = const Color(0xFFE2E8F0),
    this.errorColor = const Color(0xFFEF4444),
    this.focusBorderColor,
    this.borderRadius = 5,
    this.hintColor = const Color(0x61000000),
    this.textColor = Colors.black87,
    this.tagColor = const Color(0xFF64748B),
  });

  /// 默认主题数据
  static const LiteUIThemeData defaults = LiteUIThemeData();
}

/// LiteUI 主题 InheritedWidget
///
/// 通过 [LiteUITheme] 包裹 App 可全局自定义库内组件的默认颜色与样式：
///
/// ```dart
/// LiteUITheme(
///   data: LiteUIThemeData(
///     borderColor: Colors.blue,
///     errorColor: Colors.orange,
///     borderRadius: 8,
///   ),
///   child: MyApp(),
/// )
/// ```
class LiteUITheme extends InheritedWidget {
  /// 主题数据
  final LiteUIThemeData data;

  const LiteUITheme({super.key, required this.data, required super.child});

  /// 从 widget tree 中获取主题数据
  ///
  /// 若未找到 [LiteUITheme]，则返回默认主题 [LiteUIThemeData.defaults]
  static LiteUIThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<LiteUITheme>();
    return theme?.data ?? LiteUIThemeData.defaults;
  }

  @override
  bool updateShouldNotify(LiteUITheme oldWidget) {
    return data != oldWidget.data;
  }
}

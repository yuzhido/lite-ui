import 'package:flutter/material.dart';
import '../models/enum.dart';
import '../theme/index.dart';

/// 构建统一的 OutlineInputBorder 边框
///
/// [type] 边框类型（默认/启用/聚焦）
/// [borderRadius] 圆角半径，不传时从 [LiteUITheme] 读取
/// [borderColor] 默认边框颜色，不传时从 [LiteUITheme] 读取
/// [focusBorderColor] 聚焦时边框颜色，不传时从 [LiteUITheme] 读取，仍为 null 则使用系统主题色
/// [errorColor] 错误状态边框颜色，不传时从 [LiteUITheme] 读取
/// [hasError] 是否处于错误状态
InputBorder buildInputOutlineBorder({
  required BorderType type,
  double? borderRadius,
  Color? borderColor,
  Color? focusBorderColor,
  Color? errorColor,
  bool hasError = false,
  required BuildContext context,
}) {
  final theme = LiteUITheme.of(context);
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius ?? theme.borderRadius),
    borderSide: BorderSide(
      color: hasError
          ? (errorColor ?? theme.errorColor)
          : type == BorderType.focusedBorder
          ? focusBorderColor ?? theme.focusBorderColor ?? Theme.of(context).colorScheme.primary
          : (borderColor ?? theme.borderColor),
      width: 1.5,
    ),
  );
}

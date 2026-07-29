import 'package:flutter/services.dart';

import '../../utils/input_regex.dart';
import '../models/enum.dart';

/// 输入格式化器工厂
///
/// 提供各类输入类型的 [TextInputFormatter] 实例，
/// 用于 [InputText] 的 `inputFormatters` 参数，实时拦截非法字符。
class InputFormatters {
  InputFormatters._();

  /// 获取整数输入格式化器
  static List<TextInputFormatter> integer() {
    return [FilteringTextInputFormatter.digitsOnly];
  }

  /// 获取小数输入格式化器（只允许一个小数点）
  static List<TextInputFormatter> decimal() {
    return [
      TextInputFormatter.withFunction((oldValue, newValue) {
        final newText = newValue.text;

        // 如果新值为空（删除操作），直接允许
        if (newText.isEmpty) return newValue;

        // 检查是否只包含数字和小数点
        if (!InputRegex.decimalInput.hasMatch(newText)) {
          return oldValue;
        }

        // 检查小数点数量（最多1个）
        final dotCount = '.'.allMatches(newText).length;
        if (dotCount > 1) {
          return oldValue;
        }

        return newValue;
      }),
    ];
  }

  /// 获取中文输入格式化器
  static List<TextInputFormatter> chinese() {
    return [FilteringTextInputFormatter.allow(InputRegex.chinese)];
  }

  /// 获取英文输入格式化器
  static List<TextInputFormatter> english() {
    return [FilteringTextInputFormatter.allow(InputRegex.english)];
  }

  /// 获取单字符输入格式化器（ASCII 范围）
  static List<TextInputFormatter> char() {
    return [FilteringTextInputFormatter.allow(InputRegex.char)];
  }

  /// 获取普通文本输入格式化器（不限制）
  static List<TextInputFormatter> text() {
    return [];
  }
}

/// 输入格式化器路由
///
/// 根据 [InputType] 枚举获取对应的 [TextInputFormatter] 列表。
class InputFormat {
  InputFormat._();

  /// 根据 [InputType] 获取对应的输入格式化器列表
  static List<TextInputFormatter> getFormatters(InputType type) {
    switch (type) {
      case InputType.integer:
        return InputFormatters.integer();
      case InputType.decimal:
        return InputFormatters.decimal();
      case InputType.chinese:
        return InputFormatters.chinese();
      case InputType.english:
        return InputFormatters.english();
      case InputType.text:
        return InputFormatters.text();
      case InputType.char:
        return InputFormatters.char();
    }
  }
}

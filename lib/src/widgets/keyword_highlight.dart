import 'package:flutter/material.dart';

/// 关键字高亮样式配置
///
/// 用于控制搜索过滤时匹配文本的高亮显示效果。
///
/// - [enabled] 为 false 时关闭高亮，回退为普通文本
/// - [useThemeColor] 为 true 时强制使用 `Theme.of(context).colorScheme.primary` 作为高亮色，忽略 [color]
/// - [color] 默认琥珀黄（`Color(0xFFFF8F00)`），传入自定义颜色则按传入值显示
/// - [backgroundColor] 默认无背景
/// - [bold] 默认 true，匹配文本加粗显示
class KeywordHighlightStyle {
  /// 是否启用高亮，默认 true
  final bool enabled;

  /// 是否强制使用系统主题色（`Theme.of(context).colorScheme.primary`）作为高亮色
  ///
  /// 为 true 时忽略 [color]，默认 false
  final bool useThemeColor;

  /// 匹配文本的前景色，默认琥珀黄 `Color(0xFFFF8F00)`，可传入自定义颜色
  ///
  /// 当 [useThemeColor] 为 true 时此字段被忽略
  final Color color;

  /// 匹配文本的背景色，默认无背景
  final Color? backgroundColor;

  /// 匹配文本是否加粗，默认 true
  final bool bold;

  const KeywordHighlightStyle({this.enabled = true, this.useThemeColor = false, this.color = const Color(0xFFFF8F00), this.backgroundColor, this.bold = true});
}

/// 构建关键字高亮文本 Widget
///
/// 在 [text] 中查找 [keyword] 的匹配部分，并用高亮样式渲染。
/// 当 [keyword] 为空或 [highlightStyle] 禁用时，回退为普通 [Text]。
///
/// - [text]: 原始完整文本
/// - [keyword]: 搜索关键字
/// - [style]: 基础文本样式（非匹配部分使用）
/// - [highlightStyle]: 高亮配置，为 null 时使用默认配置（琥珀黄加粗）
/// - [caseSensitive]: 是否区分大小写，默认 false
/// - [maxLines]: 最大行数
/// - [overflow]: 文本溢出方式
Widget buildHighlightedText({
  required String text,
  required String keyword,
  TextStyle? style,
  KeywordHighlightStyle? highlightStyle,
  bool caseSensitive = false,
  int? maxLines,
  TextOverflow? overflow,
  TextAlign? textAlign,
}) {
  final effectiveStyle = highlightStyle ?? const KeywordHighlightStyle();

  // keyword 为空或高亮禁用时，直接返回普通 Text
  if (keyword.isEmpty || !effectiveStyle.enabled) {
    return Text(text, style: style, maxLines: maxLines, overflow: overflow, textAlign: textAlign);
  }

  // 构建正则，转义特殊字符
  final escaped = RegExp.escape(keyword);
  final regex = RegExp(escaped, caseSensitive: caseSensitive);
  final matches = regex.allMatches(text).toList();

  // 无匹配时返回普通 Text
  if (matches.isEmpty) {
    return Text(text, style: style, maxLines: maxLines, overflow: overflow, textAlign: textAlign);
  }

  final baseStyle = style ?? const TextStyle();

  return _HighlightedTextWidget(text: text, matches: matches, baseStyle: baseStyle, highlightStyle: effectiveStyle, maxLines: maxLines, overflow: overflow, textAlign: textAlign);
}

/// 内部高亮文本渲染组件
///
/// 使用 Builder 获取 Theme context 后构建 RichText
class _HighlightedTextWidget extends StatelessWidget {
  final String text;
  final List<RegExpMatch> matches;
  final TextStyle baseStyle;
  final KeywordHighlightStyle highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const _HighlightedTextWidget({required this.text, required this.matches, required this.baseStyle, required this.highlightStyle, this.maxLines, this.overflow, this.textAlign});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = highlightStyle.useThemeColor ? theme.colorScheme.primary : highlightStyle.color;
    final highlightTextStyle = baseStyle.copyWith(
      color: effectiveColor,
      backgroundColor: highlightStyle.backgroundColor,
      fontWeight: highlightStyle.bold ? FontWeight.w600 : baseStyle.fontWeight,
    );

    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      // 非匹配区间
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      // 匹配区间
      spans.add(TextSpan(text: text.substring(match.start, match.end), style: highlightTextStyle));
      lastEnd = match.end;
    }

    // 末尾剩余文本
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(style: baseStyle, children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      textAlign: textAlign ?? TextAlign.start,
    );
  }
}

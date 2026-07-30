import 'package:flutter/material.dart';
import 'package:lite_ui/src/models/enum.dart';
import 'package:lite_ui/src/theme/index.dart';

import 'content_tag.dart';

/// 值显示内容组件
///
/// 用于在表单容器中显示选中值的多种模式：
/// - [DisplayMode.text]：单行文本，顿号分隔
/// - [DisplayMode.tags]：每个值显示为 tag，横向滚动
/// - [DisplayMode.compact]：显示前 N 个 tag，剩余以 "+M" 显示
class ShowContent extends StatelessWidget {
  /// 错误提示文字（有值时优先显示）
  final String? errorText;

  /// 选中值的 label 列表
  final List<String>? valueLabels;

  /// 选中的值文本（无 labels 时使用）
  final String? valueText;

  /// 占位提示文字（无值时显示）
  final String? hintText;

  /// 表单标签（用于占位提示）
  final String? formLabel;

  /// 值显示模式，默认 [DisplayMode.text]
  final DisplayMode displayMode;

  /// compact 模式下最多显示的 tag 数，默认 3
  final int maxShowTags;

  /// 自定义值显示 Widget 构建器（优先级最高）
  ///
  /// 传入后忽略 [displayMode] 的默认逻辑，[labels] 为当前所有选中值的 label 列表。
  final Widget Function(List<String> labels)? valueBuilder;

  const ShowContent({
    super.key,
    this.errorText,
    this.valueLabels,
    this.valueText,
    this.hintText,
    this.formLabel,
    this.displayMode = DisplayMode.text,
    this.maxShowTags = 3,
    this.valueBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    // 1. 有值时优先显示值（验证失败但有值时仍显示选中内容，错误提示由边框/外部处理）
    final labels = valueLabels;
    if (labels != null && labels.isNotEmpty) {
      // 自定义构建器优先
      if (valueBuilder != null) return valueBuilder!(labels);

      final mode = displayMode;

      // text 模式
      if (mode == DisplayMode.text) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            labels.join('、'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, color: LiteUITheme.of(context).textColor),
          ),
        );
      }

      // tags / compact 模式
      final tagColor = LiteUITheme.of(context).tagColor;
      final tagTextColor = Colors.white;

      if (mode == DisplayMode.tags) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: labels.map((label) => ContentTag(label: label, bgColor: tagColor, textColor: tagTextColor)).toList(),
          ),
        );
      }

      if (mode == DisplayMode.compact) {
        if (labels.length <= maxShowTags) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: labels.map((label) => ContentTag(label: label, bgColor: tagColor, textColor: tagTextColor)).toList(),
            ),
          );
        }
        final visibleLabels = labels.sublist(0, maxShowTags);
        final remaining = labels.length - maxShowTags;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...visibleLabels.map((label) => ContentTag(label: label, bgColor: tagColor, textColor: tagTextColor)),
              ContentTag(label: '+$remaining', bgColor: tagColor.withValues(alpha: 0.6), textColor: tagTextColor),
            ],
          ),
        );
      }
    }

    // 2. 有 valueText 但无 labels
    if (valueText != null) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          valueText ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16, color: LiteUITheme.of(context).textColor),
        ),
      );
    }

    // 3. 无值但有错误时显示错误提示
    if (hasError) {
      return Text(errorText ?? '', style: TextStyle(fontSize: 16, color: LiteUITheme.of(context).errorColor));
    }

    // 4. 占位提示
    return Text(hintText ?? '请选择$formLabel', style: TextStyle(fontSize: 16, color: LiteUITheme.of(context).hintColor));
  }
}

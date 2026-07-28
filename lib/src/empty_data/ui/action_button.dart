import 'package:flutter/material.dart';

import '../models/index.dart';

/// EmptyData 操作按钮组件
///
/// 根据 [EmptyDataStyleParams] 中的 actionWidget 或 actionLabel
/// 渲染自定义操作区域或默认按钮。
class EmptyDataActionButton extends StatelessWidget {
  final EmptyDataStyleParams params;
  final EmptyConfig config;

  /// 是否使用紧凑尺寸（compact 风格使用更小的 padding 和字体）
  final bool compact;

  const EmptyDataActionButton({required this.params, required this.config, this.compact = false, super.key});

  @override
  Widget build(BuildContext context) {
    // 自定义操作区域：直接渲染
    if (params.actionWidget != null) {
      return params.actionWidget!;
    }

    // 默认按钮
    if (params.actionLabel != null) {
      final hPadding = compact ? 16.0 : 24.0;
      final vPadding = compact ? 8.0 : 10.0;
      final fontSize = compact ? 12.0 : 13.0;

      return Semantics(
        button: true,
        label: params.actionLabel,
        child: Material(
          color: config.actionColor,
          borderRadius: BorderRadius.circular(10),
          elevation: 0,
          child: InkWell(
            onTap: params.onAction,
            borderRadius: BorderRadius.circular(10),
            splashColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: config.actionColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Text(
                params.actionLabel ?? '--',
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: 0.2),
              ),
            ),
          ),
        ),
      );
    }

    // 无操作：返回空
    return const SizedBox.shrink();
  }
}

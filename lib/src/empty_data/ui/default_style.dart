import 'package:flutter/material.dart';

import '../models/index.dart';
import 'action_button.dart';

/// EmptyData 默认风格：居中圆形图标 + 文字
class EmptyDataDefaultStyle extends StatelessWidget {
  final EmptyDataStyleParams params;
  final EmptyConfig config;

  const EmptyDataDefaultStyle({required this.params, required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    final size = params.iconSize ?? 88;
    final resolvedBg = params.iconBackgroundColor ?? config.bgColor;

    return Semantics(
      label: '${params.title}, ${params.description}',
      child: Padding(
        padding: params.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 0,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: resolvedBg,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: config.iconColor.withValues(alpha: 0.12), blurRadius: size * 0.3, offset: Offset(0, size * 0.08))],
                ),
                child: Center(
                  child: params.icon ?? Icon(config.icon, size: size * 0.4, color: config.iconColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              flex: 0,
              child: Text(
                params.title,
                style: params.titleStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B), letterSpacing: -0.2),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              flex: 0,
              child: Text(
                params.description,
                style: params.descriptionStyle ?? const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Color(0xFF94A3B8), height: 1.5),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (params.actionLabel != null || params.actionWidget != null) ...[const SizedBox(height: 20), EmptyDataActionButton(params: params, config: config)],
          ],
        ),
      ),
    );
  }
}

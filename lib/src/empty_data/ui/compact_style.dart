import 'package:flutter/material.dart';

import '../models/index.dart';
import 'action_button.dart';

/// EmptyData 紧凑风格：横向小圆角图标 + 文字并排
class EmptyDataCompactStyle extends StatelessWidget {
  final EmptyDataStyleParams params;
  final EmptyConfig config;

  const EmptyDataCompactStyle({required this.params, required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    final size = params.iconSize ?? 48;
    final resolvedBg = params.iconBackgroundColor ?? config.bgColor;

    return Semantics(
      label: '${params.title}, ${params.description}',
      child: Padding(
        padding: params.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(color: resolvedBg, borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: params.icon ?? Icon(config.icon, size: size * 0.45, color: config.iconColor),
                  ),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        params.title,
                        style: params.titleStyle ?? const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        params.description,
                        style: params.descriptionStyle ?? const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (params.actionLabel != null || params.actionWidget != null) ...[const SizedBox(height: 20), EmptyDataActionButton(params: params, config: config, compact: true)],
          ],
        ),
      ),
    );
  }
}

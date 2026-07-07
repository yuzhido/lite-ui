import 'package:flutter/material.dart';

import '../model.dart';
import 'empty_data_action_button.dart';
import 'empty_data_style_params.dart';

/// EmptyData 极简风格：圆点装饰 + 纯文字 + 渐变分隔线
class EmptyDataMinimalStyle extends StatelessWidget {
  final EmptyDataStyleParams params;
  final EmptyConfig config;

  const EmptyDataMinimalStyle({required this.params, required this.config, super.key});

  @override
  Widget build(BuildContext context) {
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
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: config.iconColor.withValues(alpha: 0.4), shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: config.iconColor.withValues(alpha: 0.25), shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: config.iconColor.withValues(alpha: 0.4), shape: BoxShape.circle),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              params.title,
              style: params.titleStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Container(
              width: 32,
              height: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [const Color(0xFFE2E8F0).withValues(alpha: 0), const Color(0xFFE2E8F0), const Color(0xFFE2E8F0).withValues(alpha: 0)]),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            Text(
              params.description,
              style: params.descriptionStyle ?? const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (params.actionLabel != null || params.actionWidget != null) ...[
              const SizedBox(height: 20),
              EmptyDataActionButton(params: params, config: config),
            ],
          ],
        ),
      ),
    );
  }
}

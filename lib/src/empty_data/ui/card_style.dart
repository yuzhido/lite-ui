import 'package:flutter/material.dart';

import '../models/index.dart';
import 'action_button.dart';

/// EmptyData 卡片风格：带顶部渐变色带的装饰卡片
class EmptyDataCardStyle extends StatelessWidget {
  final EmptyDataStyleParams params;
  final EmptyConfig config;

  const EmptyDataCardStyle({required this.params, required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    final size = params.iconSize ?? 64;
    final resolvedBg = params.iconBackgroundColor ?? config.bgColor;

    return Semantics(
      label: '${params.title}, ${params.description}',
      child: Padding(
        padding: params.padding,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [config.iconColor.withValues(alpha: 0.08), config.iconColor.withValues(alpha: 0.01)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: resolvedBg,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: config.iconColor.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Center(
                        child: params.icon ?? Icon(config.icon, size: size * 0.4, color: config.iconColor),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      params.title,
                      style: params.titleStyle ?? const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      params.description,
                      style: params.descriptionStyle ?? const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.4),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (params.actionLabel != null || params.actionWidget != null) ...[const SizedBox(height: 20), EmptyDataActionButton(params: params, config: config)],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

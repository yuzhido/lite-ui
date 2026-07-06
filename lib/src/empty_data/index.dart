import 'package:flutter/material.dart';

/// 空状态场景类型
enum EmptyDataType {
  /// 默认空状态 — 列表/数据为空
  empty,

  /// 搜索无结果
  search,

  /// 网络异常
  noNetwork,

  /// 加载失败/错误
  error,

  /// 无访问权限
  noPermission,

  /// 暂无消息
  noMessage,

  /// 暂无订单
  noOrder,

  /// 系统维护中
  maintenance,
}

/// 空状态布局风格
enum EmptyDataStyle {
  /// 居中圆形图标 + 文字（默认）
  defaultStyle,

  /// 横向紧凑 — 小圆角图标 + 文字并排
  compact,

  /// 装饰卡片 — 带顶部色带的背景卡片
  card,

  /// 极简文字 — 圆点 + 纯文字 + 分隔线
  minimal,
}

/// 空状态数据展示组件
///
/// 当列表、页面或模块没有数据时显示的占位组件。
/// 支持 8 种场景类型 × 4 种布局风格，可自由组合。
///
/// 最简用法：
/// ```dart
/// EmptyData()
/// ```
///
/// 指定风格和场景：
/// ```dart
/// EmptyData(
///   style: EmptyDataStyle.compact,
///   type: EmptyDataType.noPermission,
/// )
/// ```
class EmptyData extends StatelessWidget {
  /// 预设场景类型，默认为 [EmptyDataType.empty]
  final EmptyDataType type;

  /// 布局风格，默认为 [EmptyDataStyle.defaultStyle]
  final EmptyDataStyle style;

  /// 主标题，不传则根据 [type] 使用默认文案
  final String? title;

  /// 描述文字，不传则根据 [type] 使用默认文案
  final String? description;

  /// 自定义图标 Widget，不传则使用 [type] 对应的内置图标
  final Widget? icon;

  /// 图标背景圆形颜色，不传则使用 [type] 对应的默认颜色
  final Color? iconBackgroundColor;

  /// 图标尺寸（宽高），默认 88（defaultStyle），其他风格有各自默认值
  final double? iconSize;

  /// 操作按钮文字，传 null 不显示按钮
  final String? actionLabel;

  /// 操作按钮点击回调
  final VoidCallback? onAction;

  /// 自定义操作区域 Widget（优先级高于 [actionLabel]）
  final Widget? actionWidget;

  /// 自定义标题样式
  final TextStyle? titleStyle;

  /// 自定义描述样式
  final TextStyle? descriptionStyle;

  /// 组件内边距
  final EdgeInsetsGeometry padding;

  const EmptyData({
    super.key,
    this.type = EmptyDataType.empty,
    this.style = EmptyDataStyle.defaultStyle,
    this.title,
    this.description,
    this.icon,
    this.iconBackgroundColor,
    this.iconSize,
    this.actionLabel,
    this.onAction,
    this.actionWidget,
    this.titleStyle,
    this.descriptionStyle,
    this.padding = const EdgeInsets.all(32),
  });

  // ===== 各类型默认配置 =====

  /// 获取指定类型的内置图标
  static IconData iconOf(EmptyDataType type) => _defaults[type]!.icon;

  /// 获取指定类型的内置背景色
  static Color bgColorOf(EmptyDataType type) => _defaults[type]!.bgColor;

  /// 获取指定类型的内置图标色
  static Color iconColorOf(EmptyDataType type) => _defaults[type]!.iconColor;

  static const Map<EmptyDataType, _EmptyConfig> _defaults = {
    EmptyDataType.empty: _EmptyConfig(
      title: '暂无数据',
      description: '当前列表没有内容',
      iconColor: Color(0xFF6366F1),
      bgColor: Color(0xFFF0F4FF),
      actionColor: Color(0xFF6366F1),
      icon: Icons.inbox_outlined,
    ),
    EmptyDataType.search: _EmptyConfig(
      title: '未找到相关结果',
      description: '换个关键词试试？',
      iconColor: Color(0xFF16A34A),
      bgColor: Color(0xFFF0FDF4),
      actionColor: Color(0xFF16A34A),
      icon: Icons.search_off_outlined,
    ),
    EmptyDataType.noNetwork: _EmptyConfig(
      title: '网络连接失败',
      description: '请检查网络设置后重新加载',
      iconColor: Color(0xFFDC2626),
      bgColor: Color(0xFFFEF2F2),
      actionColor: Color(0xFFDC2626),
      icon: Icons.wifi_off_outlined,
    ),
    EmptyDataType.error: _EmptyConfig(
      title: '加载失败',
      description: '出了点问题，请稍后重试',
      iconColor: Color(0xFFEA580C),
      bgColor: Color(0xFFFFF7ED),
      actionColor: Color(0xFFEA580C),
      icon: Icons.error_outline,
    ),
    EmptyDataType.noPermission: _EmptyConfig(
      title: '无访问权限',
      description: '请联系管理员开通权限',
      iconColor: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
      actionColor: Color(0xFFD97706),
      icon: Icons.lock_outline,
    ),
    EmptyDataType.noMessage: _EmptyConfig(
      title: '暂无消息',
      description: '还没有收到任何消息',
      iconColor: Color(0xFF7C3AED),
      bgColor: Color(0xFFEDE9FE),
      actionColor: Color(0xFF7C3AED),
      icon: Icons.chat_bubble_outline,
    ),
    EmptyDataType.noOrder: _EmptyConfig(
      title: '暂无订单',
      description: '还没有任何订单记录',
      iconColor: Color(0xFF0284C7),
      bgColor: Color(0xFFE0F2FE),
      actionColor: Color(0xFF0284C7),
      icon: Icons.receipt_long_outlined,
    ),
    EmptyDataType.maintenance: _EmptyConfig(
      title: '系统维护中',
      description: '功能暂时不可用，请稍后再来',
      iconColor: Color(0xFF475569),
      bgColor: Color(0xFFF1F5F9),
      actionColor: Color(0xFF475569),
      icon: Icons.settings_outlined,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final config = _defaults[type]!;
    switch (style) {
      case EmptyDataStyle.defaultStyle:
        return _buildDefault(config);
      case EmptyDataStyle.compact:
        return _buildCompact(config);
      case EmptyDataStyle.card:
        return _buildCard(config);
      case EmptyDataStyle.minimal:
        return _buildMinimal(config);
    }
  }

  // ===== 风格: default — 居中圆形图标 =====

  Widget _buildDefault(_EmptyConfig config) {
    final resolvedTitle = title ?? config.title;
    final resolvedDesc = description ?? config.description;
    final resolvedBg = iconBackgroundColor ?? config.bgColor;
    final size = iconSize ?? 88;

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(flex: 0, child: _buildCircleIcon(resolvedBg, config.iconColor, size)),
          const SizedBox(height: 16),
          Flexible(
            flex: 0,
            child: Text(
              resolvedTitle,
              style: titleStyle ??
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B), letterSpacing: -0.2),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            flex: 0,
            child: Text(
              resolvedDesc,
              style: descriptionStyle ??
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Color(0xFF94A3B8), height: 1.5),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ..._buildAction(config),
        ],
      ),
    );
  }

  // ===== 风格: compact — 横向紧凑 =====

  Widget _buildCompact(_EmptyConfig config) {
    final resolvedTitle = title ?? config.title;
    final resolvedDesc = description ?? config.description;
    final resolvedBg = iconBackgroundColor ?? config.bgColor;
    final size = iconSize ?? 48;

    return Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 圆角方形图标
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: resolvedBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: icon ?? Icon(config.icon, size: size * 0.45, color: config.iconColor),
            ),
          ),
          const SizedBox(width: 14),
          // 文字区域
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resolvedTitle,
                  style: titleStyle ??
                      const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  resolvedDesc,
                  style: descriptionStyle ??
                      const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== 风格: card — 装饰卡片 =====

  Widget _buildCard(_EmptyConfig config) {
    final resolvedTitle = title ?? config.title;
    final resolvedDesc = description ?? config.description;
    final resolvedBg = iconBackgroundColor ?? config.bgColor;
    final size = iconSize ?? 64;

    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // 顶部装饰色带
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                color: config.iconColor.withValues(alpha: 0.06),
              ),
            ),
            // 内容
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 带阴影的圆形图标
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: resolvedBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: config.iconColor.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: icon ?? Icon(config.icon, size: size * 0.4, color: config.iconColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    resolvedTitle,
                    style: titleStyle ??
                        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resolvedDesc,
                    style: descriptionStyle ??
                        const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ..._buildAction(config),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== 风格: minimal — 极简文字 =====

  Widget _buildMinimal(_EmptyConfig config) {
    final resolvedTitle = title ?? config.title;
    final resolvedDesc = description ?? config.description;

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 三个装饰圆点
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(config.iconColor.withValues(alpha: 0.4)),
              const SizedBox(width: 4),
              _dot(config.iconColor.withValues(alpha: 0.25)),
              const SizedBox(width: 4),
              _dot(config.iconColor.withValues(alpha: 0.4)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            resolvedTitle,
            style: titleStyle ??
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // 分隔线
          Container(
            width: 32,
            height: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          Text(
            resolvedDesc,
            style: descriptionStyle ??
                const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1)),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // ===== 公共: 圆形图标 =====

  Widget _buildCircleIcon(Color bgColor, Color iconColor, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(
        child: icon ?? Icon(configIcon(), size: size * 0.4, color: iconColor),
      ),
    );
  }

  /// 获取当前 type 的内置图标
  IconData configIcon() {
    return _defaults[type]!.icon;
  }

  // ===== 公共: 操作区域 =====

  List<Widget> _buildAction(_EmptyConfig config) {
    if (actionWidget != null) {
      return [const SizedBox(height: 20), actionWidget!];
    }
    if (actionLabel != null) {
      return [
        const SizedBox(height: 20),
        _DefaultActionButton(
          label: actionLabel!,
          color: config.actionColor,
          onPressed: onAction,
        ),
      ];
    }
    return [];
  }
}

/// 默认操作按钮
class _DefaultActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _DefaultActionButton({
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

/// 各类型默认配置（内部使用）
class _EmptyConfig {
  final String title;
  final String description;
  final Color iconColor;
  final Color bgColor;
  final Color actionColor;
  final IconData icon;

  const _EmptyConfig({
    required this.title,
    required this.description,
    required this.iconColor,
    required this.bgColor,
    required this.actionColor,
    required this.icon,
  });
}

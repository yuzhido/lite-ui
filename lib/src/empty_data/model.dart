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

/// 各类型默认配置
class EmptyConfig {
  final String title;
  final String description;
  final Color iconColor;
  final Color bgColor;
  final Color actionColor;
  final IconData icon;

  const EmptyConfig({required this.title, required this.description, required this.iconColor, required this.bgColor, required this.actionColor, required this.icon});
}

/// 各类型默认配置表
const Map<EmptyDataType, EmptyConfig> emptyDataDefaults = {
  EmptyDataType.empty: EmptyConfig(
    title: '暂无数据',
    description: '当前列表没有内容',
    iconColor: Color(0xFF6366F1),
    bgColor: Color(0xFFF0F4FF),
    actionColor: Color(0xFF6366F1),
    icon: Icons.inbox_outlined,
  ),
  EmptyDataType.search: EmptyConfig(
    title: '未找到相关结果',
    description: '换个关键词试试？',
    iconColor: Color(0xFF16A34A),
    bgColor: Color(0xFFF0FDF4),
    actionColor: Color(0xFF16A34A),
    icon: Icons.search_off_outlined,
  ),
  EmptyDataType.noNetwork: EmptyConfig(
    title: '网络连接失败',
    description: '请检查网络设置后重新加载',
    iconColor: Color(0xFFDC2626),
    bgColor: Color(0xFFFEF2F2),
    actionColor: Color(0xFFDC2626),
    icon: Icons.wifi_off_outlined,
  ),
  EmptyDataType.error: EmptyConfig(
    title: '加载失败',
    description: '出了点问题，请稍后重试',
    iconColor: Color(0xFFEA580C),
    bgColor: Color(0xFFFFF7ED),
    actionColor: Color(0xFFEA580C),
    icon: Icons.error_outline,
  ),
  EmptyDataType.noPermission: EmptyConfig(
    title: '无访问权限',
    description: '请联系管理员开通权限',
    iconColor: Color(0xFFD97706),
    bgColor: Color(0xFFFEF3C7),
    actionColor: Color(0xFFD97706),
    icon: Icons.lock_outline,
  ),
  EmptyDataType.noMessage: EmptyConfig(
    title: '暂无消息',
    description: '还没有收到任何消息',
    iconColor: Color(0xFF7C3AED),
    bgColor: Color(0xFFEDE9FE),
    actionColor: Color(0xFF7C3AED),
    icon: Icons.chat_bubble_outline,
  ),
  EmptyDataType.noOrder: EmptyConfig(
    title: '暂无订单',
    description: '还没有任何订单记录',
    iconColor: Color(0xFF0284C7),
    bgColor: Color(0xFFE0F2FE),
    actionColor: Color(0xFF0284C7),
    icon: Icons.receipt_long_outlined,
  ),
  EmptyDataType.maintenance: EmptyConfig(
    title: '系统维护中',
    description: '功能暂时不可用，请稍后再来',
    iconColor: Color(0xFF475569),
    bgColor: Color(0xFFF1F5F9),
    actionColor: Color(0xFF475569),
    icon: Icons.settings_outlined,
  ),
};

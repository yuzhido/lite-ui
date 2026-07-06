import 'package:flutter/material.dart';

import 'action_sheet_filterable.dart';
import 'action_sheet_local.dart';
import 'action_sheet_remote.dart';
import 'model.dart';

/// 底部弹窗显示数据操作
///
/// 支持多种内容类型：
/// - [ActionSheetType.local]：本地固定数据（标题+描述+操作项列表）
/// - [ActionSheetType.filterable]：可过滤选择器（本地过滤+动态数据合并）
/// - [ActionSheetType.remote]：远程搜索选择器（异步搜索）
/// - [ActionSheetType.custom]：自定义 Widget 内容
///
/// 该组件只负责弹窗壳子（showModalBottomSheet），
/// 不同模式内容渲染委托给对应的子组件。
class ActionSheet {
  /// 显示一个从底部向上弹出的 ActionSheet
  ///
  /// [type] 内容类型，默认为 [ActionSheetType.local]
  /// [title] 主标题
  /// [description] 副标题/描述
  /// [items] 操作项列表（local/filterable 模式）
  /// [customChild] 自定义内容 Widget（custom 模式）
  /// [cancelLabel] 取消按钮文字，默认为「取消」
  ///
  /// --- filterable / remote 通用参数 ---
  /// [multiple] 是否多选模式，默认 false（单选）
  /// [selectedValues] 初始选中项的 value 集合
  /// [onSelect] 单选回调
  /// [onConfirm] 多选确认回调
  /// [searchHint] 搜索框提示文字
  /// [confirmLabel] 确定按钮文字
  ///
  /// --- filterable 专属参数 ---
  /// [dynamicItems] 异步动态数据回调
  ///
  /// --- remote 专属参数 ---
  /// [onSearch] 远程搜索回调（必填）
  /// [initialItems] 初始数据
  /// [emptyText] 空状态提示文字
  static Future<T?> show<T>({
    required BuildContext context,
    ActionSheetType type = ActionSheetType.local,
    String? title,
    String? description,
    List<ActionSheetItem>? items,
    Widget? customChild,
    String cancelLabel = '取消',

    // filterable / remote 通用参数
    bool multiple = false,
    Set<String>? selectedValues,
    ValueChanged<ActionSheetItem>? onSelect,
    ValueChanged<List<ActionSheetItem>>? onConfirm,
    String searchHint = '搜索',
    String confirmLabel = '确定',

    // filterable 专属
    DynamicItemsCallback? dynamicItems,

    // remote 专属
    RemoteSearchCallback? onSearch,
    List<ActionSheetItem>? initialItems,
    String emptyText = '暂无数据',
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final screenHeight = MediaQuery.of(ctx).size.height;

        // filterable/remote 类型：高度限制在 50%~70%
        BoxConstraints constraints;
        if (type == ActionSheetType.filterable || type == ActionSheetType.remote) {
          constraints = BoxConstraints(minHeight: screenHeight * 0.60, maxHeight: screenHeight * 0.75);
        } else {
          // local/custom 类型：最大高度 70%，无最小高度限制
          constraints = BoxConstraints(maxHeight: screenHeight * 0.75);
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: ConstrainedBox(
              constraints: constraints,
              child: _buildContent<T>(
                type: type,
                title: title,
                description: description,
                items: items,
                customChild: customChild,
                cancelLabel: cancelLabel,
                multiple: multiple,
                selectedValues: selectedValues,
                onSelect: onSelect,
                onConfirm: onConfirm,
                searchHint: searchHint,
                confirmLabel: confirmLabel,
                dynamicItems: dynamicItems,
                onSearch: onSearch,
                initialItems: initialItems,
                emptyText: emptyText,
                ctx: ctx,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 根据 type 渲染不同的内容组件
  static Widget _buildContent<T>({
    required ActionSheetType type,
    required String? title,
    required String? description,
    required List<ActionSheetItem>? items,
    required Widget? customChild,
    required String cancelLabel,
    required bool multiple,
    required Set<String>? selectedValues,
    required ValueChanged<ActionSheetItem>? onSelect,
    required ValueChanged<List<ActionSheetItem>>? onConfirm,
    required String searchHint,
    required String confirmLabel,
    required DynamicItemsCallback? dynamicItems,
    required RemoteSearchCallback? onSearch,
    required List<ActionSheetItem>? initialItems,
    required String emptyText,
    required BuildContext ctx,
  }) {
    switch (type) {
      case ActionSheetType.local:
        // local 模式：未传数据时自动填充模拟内容
        final bool useMock = items == null || items.isEmpty;
        final mockTitle = title ?? '操作提示';
        final mockDesc = description ?? '这是一条模拟的描述内容，用于开发阶段预览弹窗效果。';
        final mockItems = (items != null && items.isNotEmpty) ? items : _defaultMockItems;

        return ActionSheetLocal(
          title: useMock ? mockTitle : title,
          description: useMock ? mockDesc : description,
          items: useMock ? mockItems : items,
          onSelect: (index) => Navigator.of(ctx).pop(index),
          cancelLabel: cancelLabel,
        );

      case ActionSheetType.filterable:
        // filterable 模式：未传数据时自动填充模拟内容
        final bool filterableUseMock = items == null || items.isEmpty;
        final filterableTitle = title ?? '可过滤选择';
        final filterableDesc = description ?? '输入关键字过滤列表数据，用于开发阶段预览弹窗效果。';
        final filterableItems = (items != null && items.isNotEmpty) ? items : _filterableMockItems;

        return ActionSheetFilterable(
          title: filterableUseMock ? filterableTitle : title,
          description: filterableUseMock ? filterableDesc : description,
          items: filterableItems,
          dynamicItems: dynamicItems,
          multiple: multiple,
          selectedValues: selectedValues,
          onSelect: onSelect,
          onConfirm: onConfirm,
          searchHint: searchHint,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
        );

      case ActionSheetType.remote:
        // remote 模式：未传 onSearch 时使用模拟搜索
        final remoteTitle = title ?? '远程搜索';
        final remoteDesc = description ?? '输入关键字远程搜索数据，用于开发阶段预览弹窗效果。';
        final remoteSearch = onSearch ?? _mockRemoteSearch;

        return ActionSheetRemote(
          title: title ?? remoteTitle,
          description: description ?? remoteDesc,
          onSearch: remoteSearch,
          initialItems: initialItems,
          multiple: multiple,
          selectedValues: selectedValues,
          onSelect: onSelect,
          onConfirm: onConfirm,
          searchHint: searchHint,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          emptyText: emptyText,
        );

      case ActionSheetType.custom:
        return customChild ?? const SizedBox.shrink();
    }
  }

  /// 开发阶段默认模拟操作项（20条，用于测试滚动效果）
  static const List<ActionSheetItem> _defaultMockItems = [
    ActionSheetItem(label: '拍照', subtitle: '使用相机拍摄照片'),
    ActionSheetItem(label: '从相册选择', subtitle: '从手机相册中选取图片'),
    ActionSheetItem(label: '拍摄视频', subtitle: '录制一段短视频'),
    ActionSheetItem(label: '文件'),
    ActionSheetItem(label: '收藏'),
    ActionSheetItem(label: '分享'),
    ActionSheetItem(label: '复制链接'),
    ActionSheetItem(label: '刷新', subtitle: '重新加载当前内容'),
    ActionSheetItem(label: '编辑', subtitle: '修改当前内容'),
    ActionSheetItem(label: '置顶', subtitle: '将内容置顶显示'),
    ActionSheetItem(label: '标记已读'),
    ActionSheetItem(label: '静音', subtitle: '关闭该会话的通知'),
    ActionSheetItem(label: '导出数据', subtitle: '导出为 CSV 或 Excel 格式'),
    ActionSheetItem(label: '打印', subtitle: '发送到打印机打印'),
    ActionSheetItem(label: '归档'),
    ActionSheetItem(label: '举报', subtitle: '提交违规内容举报'),
    ActionSheetItem(label: '拉黑用户', subtitle: '屏蔽该用户的所有消息'),
    ActionSheetItem(label: '清空记录', subtitle: '清除全部聊天记录'),
    ActionSheetItem(label: '切换账号', subtitle: '切换到其他账号登录'),
    ActionSheetItem(label: '删除', subtitle: '删除后不可恢复，请谨慎操作', textColor: Color(0xFFE53935)),
  ];

  /// filterable 模式模拟数据（城市列表，用于测试过滤效果）
  static const List<ActionSheetItem> _filterableMockItems = [
    ActionSheetItem(label: '北京', subtitle: 'Beijing', value: 'beijing'),
    ActionSheetItem(label: '上海', subtitle: 'Shanghai', value: 'shanghai'),
    ActionSheetItem(label: '广州', subtitle: 'Guangzhou', value: 'guangzhou'),
    ActionSheetItem(label: '深圳', subtitle: 'Shenzhen', value: 'shenzhen'),
    ActionSheetItem(label: '杭州', subtitle: 'Hangzhou', value: 'hangzhou'),
    ActionSheetItem(label: '成都', subtitle: 'Chengdu', value: 'chengdu'),
    ActionSheetItem(label: '武汉', subtitle: 'Wuhan', value: 'wuhan'),
    ActionSheetItem(label: '南京', subtitle: 'Nanjing', value: 'nanjing'),
    ActionSheetItem(label: '重庆', subtitle: 'Chongqing', value: 'chongqing'),
    ActionSheetItem(label: '西安', subtitle: "Xi'an", value: 'xian'),
    ActionSheetItem(label: '苏州', subtitle: 'Suzhou', value: 'suzhou'),
    ActionSheetItem(label: '天津', subtitle: 'Tianjin', value: 'tianjin'),
    ActionSheetItem(label: '长沙', subtitle: 'Changsha', value: 'changsha'),
    ActionSheetItem(label: '青岛', subtitle: 'Qingdao', value: 'qingdao'),
    ActionSheetItem(label: '大连', subtitle: 'Dalian', value: 'dalian'),
  ];

  /// remote 模式模拟搜索（从城市列表中按关键字过滤）
  static Future<List<ActionSheetItem>> _mockRemoteSearch(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (keyword.isEmpty) return _filterableMockItems;
    final kw = keyword.toLowerCase();
    return _filterableMockItems.where((item) {
      return item.label.toLowerCase().contains(kw) || (item.subtitle?.toLowerCase().contains(kw) ?? false) || (item.value?.toLowerCase().contains(kw) ?? false);
    }).toList();
  }
}

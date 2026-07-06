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
///
/// 泛型参数：
/// - [V] 选项 value 的类型
/// - [D] 选项 data 的类型（可选原始数据）
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
  /// [onSelect] 单选回调（返回 value 和 data）
  /// [onConfirm] 多选确认回调（返回 values 和 datas）
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
  static Future<V?> show<V, D>({
    required BuildContext context,
    ActionSheetType type = ActionSheetType.local,
    String? title,
    String? description,
    List<SelectItem<V, D>>? items,
    Widget? customChild,
    String cancelLabel = '取消',

    // filterable / remote 通用参数
    bool multiple = false,
    Set<V>? selectedValues,
    OnSelectChange<V, D>? onSelect,
    OnMultiSelectConfirm<V, D>? onConfirm,
    String searchHint = '搜索',
    String confirmLabel = '确定',

    // filterable 专属
    DynamicItemsCallback<V, D>? dynamicItems,

    // remote 专属
    RemoteSearchCallback<V, D>? onSearch,
    List<SelectItem<V, D>>? initialItems,
    String emptyText = '暂无数据',
  }) {
    return showModalBottomSheet<V>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final screenHeight = MediaQuery.of(ctx).size.height;

        // filterable/remote 类型：高度限制在 50%~70%
        BoxConstraints constraints;
        if (type == ActionSheetType.filterable || type == ActionSheetType.remote) {
          constraints =
              BoxConstraints(minHeight: screenHeight * 0.60, maxHeight: screenHeight * 0.75);
        } else {
          // local/custom 类型：最大高度 70%，无最小高度限制
          constraints = BoxConstraints(maxHeight: screenHeight * 0.75);
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: ConstrainedBox(
              constraints: constraints,
              child: _buildContent<V, D>(
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
  static Widget _buildContent<V, D>({
    required ActionSheetType type,
    required String? title,
    required String? description,
    required List<SelectItem<V, D>>? items,
    required Widget? customChild,
    required String cancelLabel,
    required bool multiple,
    required Set<V>? selectedValues,
    required OnSelectChange<V, D>? onSelect,
    required OnMultiSelectConfirm<V, D>? onConfirm,
    required String searchHint,
    required String confirmLabel,
    required DynamicItemsCallback<V, D>? dynamicItems,
    required RemoteSearchCallback<V, D>? onSearch,
    required List<SelectItem<V, D>>? initialItems,
    required String emptyText,
    required BuildContext ctx,
  }) {
    switch (type) {
      case ActionSheetType.local:
        // local 模式：未传数据时自动填充模拟内容
        final bool useMock = items == null || items.isEmpty;
        final mockTitle = title ?? '操作提示';
        final mockDesc = description ?? '这是一条模拟描述内容，用于开发阶段预览弹窗效果。';
        final mockItems =
            (items != null && items.isNotEmpty) ? items : _defaultMockItems as List<SelectItem<V, D>>;

        return ActionSheetLocal<V, D>(
          title: useMock ? mockTitle : title,
          description: useMock ? mockDesc : description,
          items: useMock ? mockItems : items,
          onSelect: (value, data) {
            onSelect?.call(value, data);
            Navigator.of(ctx).pop(value);
          },
          cancelLabel: cancelLabel,
        );

      case ActionSheetType.filterable:
        // filterable 模式：未传数据时自动填充模拟内容
        final bool filterableUseMock = items == null || items.isEmpty;
        final filterableTitle = title ?? '可过滤选择';
        final filterableDesc = description ?? '输入关键字过滤列表数据，用于开发阶段预览弹窗效果。';
        final filterableItems = (items != null && items.isNotEmpty)
            ? items
            : _filterableMockItems as List<SelectItem<V, D>>;

        return ActionSheetFilterable<V, D>(
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
        final remoteSearch =
            onSearch ?? ((keyword) => _mockRemoteSearch<V, D>(keyword));

        return ActionSheetRemote<V, D>(
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
  static const List<SelectItem<String, void>> _defaultMockItems = [
    SelectItem(label: '拍照', subtitle: '使用相机拍摄照片', value: 'camera'),
    SelectItem(label: '从相册选择', subtitle: '从手机相册中选取图片', value: 'album'),
    SelectItem(label: '拍摄视频', subtitle: '录制一段短视频', value: 'video'),
    SelectItem(label: '文件', value: 'file'),
    SelectItem(label: '收藏', value: 'favorite'),
    SelectItem(label: '分享', value: 'share'),
    SelectItem(label: '复制链接', value: 'copy_link'),
    SelectItem(label: '刷新', subtitle: '重新加载当前内容', value: 'refresh'),
    SelectItem(label: '编辑', subtitle: '修改当前内容', value: 'edit'),
    SelectItem(label: '置顶', subtitle: '将内容置顶显示', value: 'pin'),
    SelectItem(label: '标记已读', value: 'mark_read'),
    SelectItem(label: '静音', subtitle: '关闭该会话的通知', value: 'mute'),
    SelectItem(label: '导出数据', subtitle: '导出为 CSV 或 Excel 格式', value: 'export'),
    SelectItem(label: '打印', subtitle: '发送到打印机打印', value: 'print'),
    SelectItem(label: '归档', value: 'archive'),
    SelectItem(label: '举报', subtitle: '提交违规内容举报', value: 'report'),
    SelectItem(label: '拉黑用户', subtitle: '屏蔽该用户的所有消息', value: 'block'),
    SelectItem(label: '清空记录', subtitle: '清除全部聊天记录', value: 'clear'),
    SelectItem(label: '切换账号', subtitle: '切换到其他账号登录', value: 'switch_account'),
    SelectItem(label: '删除', subtitle: '删除后不可恢复，请谨慎操作', value: 'delete'),
  ];

  /// filterable 模式模拟数据（城市列表，用于测试过滤效果）
  static const List<SelectItem<String, void>> _filterableMockItems = [
    SelectItem(label: '北京', subtitle: 'Beijing', value: 'beijing'),
    SelectItem(label: '上海', subtitle: 'Shanghai', value: 'shanghai'),
    SelectItem(label: '广州', subtitle: 'Guangzhou', value: 'guangzhou'),
    SelectItem(label: '深圳', subtitle: 'Shenzhen', value: 'shenzhen'),
    SelectItem(label: '杭州', subtitle: 'Hangzhou', value: 'hangzhou'),
    SelectItem(label: '成都', subtitle: 'Chengdu', value: 'chengdu'),
    SelectItem(label: '武汉', subtitle: 'Wuhan', value: 'wuhan'),
    SelectItem(label: '南京', subtitle: 'Nanjing', value: 'nanjing'),
    SelectItem(label: '重庆', subtitle: 'Chongqing', value: 'chongqing'),
    SelectItem(label: '西安', subtitle: "Xi'an", value: 'xian'),
    SelectItem(label: '苏州', subtitle: 'Suzhou', value: 'suzhou'),
    SelectItem(label: '天津', subtitle: 'Tianjin', value: 'tianjin'),
    SelectItem(label: '长沙', subtitle: 'Changsha', value: 'changsha'),
    SelectItem(label: '青岛', subtitle: 'Qingdao', value: 'qingdao'),
    SelectItem(label: '大连', subtitle: 'Dalian', value: 'dalian'),
  ];

  /// remote 模式模拟搜索（从城市列表中按关键字过滤）
  static Future<List<SelectItem<V, D>>> _mockRemoteSearch<V, D>(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final mockItems = _filterableMockItems;
    if (keyword.isEmpty) return mockItems as List<SelectItem<V, D>>;
    final kw = keyword.toLowerCase();
    return mockItems.where((item) {
      return item.label.toLowerCase().contains(kw) ||
          (item.subtitle?.toLowerCase().contains(kw) ?? false) ||
          item.value.toString().toLowerCase().contains(kw);
    }).toList() as List<SelectItem<V, D>>;
  }
}

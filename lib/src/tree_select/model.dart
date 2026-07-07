// ── 数据模型 ──

import 'package:lite_ui/widgets/keyword_highlight.dart';

/// 树形结构数据模型
///
/// 用于 [TreeSelect] 的节点数据。
/// 纯数据结构，不包含 UI 逻辑。
///
/// 泛型 [T] 为节点 ID 类型，默认 `String`，也可使用 `int` 等类型。
class TreeNode<T extends Object> {
  /// 节点ID（唯一标识）
  final T id;

  /// 节点名称
  final String label;

  /// 父节点ID，根节点为 null
  final T? parentId;

  /// 子节点列表
  List<TreeNode<T>> children;

  /// 是否展开（用于UI状态）
  bool isExpanded;

  /// 是否为叶子节点（无子节点，不可展开）
  /// 当为 false 且 children 为空时，表示子节点尚未加载（懒加载场景）
  final bool isLeaf;

  /// 是否正在加载子节点（懒加载时显示 loading）
  bool isLoading;

  /// 附加数据
  final Map<String, dynamic>? data;

  TreeNode({
    required this.id,
    required this.label,
    this.parentId,
    this.children = const [],
    this.isExpanded = false,
    this.isLeaf = false,
    this.isLoading = false,
    this.data,
  });

  /// 是否有子节点（已加载的或待加载的都算）
  bool get hasChildren => children.isNotEmpty || (!isLeaf && children.isEmpty);

  /// 是否所有后代都已加载
  bool get isChildrenLoaded => isLeaf || children.isNotEmpty;
}

// ── 类型定义 ──

/// 单选节点点击回调
typedef TreeNodeTapCallback<T extends Object> = void Function(TreeNode<T> node);

/// 多选选中状态变化回调
typedef TreeNodeSelectCallback<T extends Object> = void Function(List<TreeNode<T>> selectedNodes);

/// 懒加载子节点回调
typedef TreeNodeLoadChildrenCallback<T extends Object> = Future<List<TreeNode<T>>> Function(TreeNode<T> parent);

// ── 配置类 ──

/// 树形选择器配置参数
class TreeSelectConfig<T extends Object> {
  /// 主标题
  final String title;

  /// 搜索框提示文字
  final String searchHint;

  /// 空状态提示
  final String emptyText;

  /// 是否显示搜索框
  final bool showSearch;

  /// 是否支持多选
  final bool multiple;

  /// 初始选中的节点ID列表
  final Set<T> selectedIds;

  /// 选中回调（单选）
  final TreeNodeTapCallback<T>? onSelect;

  /// 确认回调（多选）
  final TreeNodeSelectCallback<T>? onConfirm;

  /// 懒加载子节点回调
  final TreeNodeLoadChildrenCallback<T>? onLoadChildren;

  /// 取消按钮文字
  final String cancelLabel;

  /// 确定按钮文字
  final String confirmLabel;

  /// 关键字高亮样式配置
  /// 为 null 时使用默认高亮配置（蓝色加粗），传 KeywordHighlightStyle(enabled: false) 关闭
  final KeywordHighlightStyle? highlightStyle;

  const TreeSelectConfig({
    this.title = '请选择',
    this.searchHint = '搜索...',
    this.emptyText = '暂无数据',
    this.showSearch = true,
    this.multiple = false,
    this.selectedIds = const {},
    this.onSelect,
    this.onConfirm,
    this.onLoadChildren,
    this.cancelLabel = '取消',
    this.confirmLabel = '确定',
    this.highlightStyle,
  });
}

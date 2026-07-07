import 'model.dart';

/// 树形结构操作工具类
///
/// 提供对 [TreeNode] 树的纯函数操作，包括深拷贝、过滤、查找、
/// 选中状态计算等。所有方法均为静态方法，无状态依赖。
class TreeUtils {
  TreeUtils._();

  // ── 树结构操作 ──

  /// 深拷贝整棵树，避免修改原始数据
  static List<TreeNode<T>> cloneTree<T extends Object>(List<TreeNode<T>> nodes) {
    return nodes.map((node) {
      return TreeNode<T>(
        id: node.id,
        label: node.label,
        parentId: node.parentId,
        children: cloneTree(node.children),
        isExpanded: node.isExpanded,
        isLeaf: node.isLeaf,
        isLoading: node.isLoading,
        data: node.data,
      );
    }).toList();
  }

  /// 按关键词过滤树，匹配的节点及其祖先保留，搜索时自动展开
  static List<TreeNode<T>> filterTree<T extends Object>(List<TreeNode<T>> nodes, String keyword) {
    final List<TreeNode<T>> result = [];
    for (final node in nodes) {
      final matchesLabel = node.label.toLowerCase().contains(keyword);
      final filteredChildren = filterTree(node.children, keyword);
      if (matchesLabel || filteredChildren.isNotEmpty) {
        result.add(
          TreeNode<T>(
            id: node.id,
            label: node.label,
            parentId: node.parentId,
            children: filteredChildren,
            isExpanded: true,
            isLeaf: node.isLeaf,
            isLoading: node.isLoading,
            data: node.data,
          ),
        );
      }
    }
    return result;
  }

  /// 在树中按 id 查找节点
  static TreeNode<T>? findNode<T extends Object>(List<TreeNode<T>> nodes, T nodeId) {
    for (final node in nodes) {
      if (node.id == nodeId) return node;
      final found = findNode(node.children, nodeId);
      if (found != null) return found;
    }
    return null;
  }

  /// 设置指定节点的子节点
  static void setNodeChildren<T extends Object>(List<TreeNode<T>> nodes, T nodeId, List<TreeNode<T>> children) {
    for (final node in nodes) {
      if (node.id == nodeId) {
        node.children = children;
        return;
      }
      setNodeChildren(node.children, nodeId, children);
    }
  }

  /// 切换指定节点的展开/折叠状态，返回是否找到
  static bool toggleNodeInTree<T extends Object>(List<TreeNode<T>> nodes, T nodeId) {
    for (final node in nodes) {
      if (node.id == nodeId) {
        node.isExpanded = !node.isExpanded;
        return true;
      }
      if (toggleNodeInTree(node.children, nodeId)) {
        return true;
      }
    }
    return false;
  }

  // ── 统计 ──

  /// 统计节点的全部后代数量（递归）
  static int countDescendants<T extends Object>(TreeNode<T> node) {
    int count = node.children.length;
    for (final child in node.children) {
      count += countDescendants(child);
    }
    return count;
  }

  /// 统计节点已选中的后代数量
  static int countSelectedDescendants<T extends Object>(TreeNode<T> node, Set<T> selectedIds) {
    int count = 0;
    for (final child in node.children) {
      if (selectedIds.contains(child.id)) count++;
      count += countSelectedDescendants(child, selectedIds);
    }
    return count;
  }

  /// 获取树中所有选中的节点
  static List<TreeNode<T>> getSelectedNodes<T extends Object>(List<TreeNode<T>> nodes, Set<T> selectedIds) {
    final List<TreeNode<T>> result = [];
    for (final node in nodes) {
      if (selectedIds.contains(node.id)) {
        result.add(node);
      }
      result.addAll(getSelectedNodes(node.children, selectedIds));
    }
    return result;
  }

  // ── 选中状态判断 ──

  /// 节点是否完全选中（自身 + 所有后代都在 selectedIds 中）
  static bool isNodeFullySelected<T extends Object>(TreeNode<T> node, Set<T> selectedIds) {
    if (!selectedIds.contains(node.id)) return false;
    for (final child in node.children) {
      if (!isNodeFullySelected(child, selectedIds)) return false;
    }
    return true;
  }

  /// 节点是否半选（部分后代被选中，但非全选）
  static bool isNodeHalfSelected<T extends Object>(TreeNode<T> node, Set<T> selectedIds) {
    if (node.children.isEmpty) return false;
    if (isNodeFullySelected(node, selectedIds)) return false;
    return hasAnyDescendantSelected(node, selectedIds);
  }

  /// 是否有任何后代被选中
  static bool hasAnyDescendantSelected<T extends Object>(TreeNode<T> node, Set<T> selectedIds) {
    for (final child in node.children) {
      if (selectedIds.contains(child.id)) return true;
      if (hasAnyDescendantSelected(child, selectedIds)) return true;
    }
    return false;
  }

  // ── 批量选中/取消 ──

  /// 递归添加节点及所有后代到选中集合
  static void addNodeAndDescendants<T extends Object>(TreeNode<T> node, Set<T> selectedIds) {
    selectedIds.add(node.id);
    for (final child in node.children) {
      addNodeAndDescendants(child, selectedIds);
    }
  }

  /// 递归移除节点及所有后代从选中集合
  static void removeNodeAndDescendants<T extends Object>(TreeNode<T> node, Set<T> selectedIds) {
    selectedIds.remove(node.id);
    for (final child in node.children) {
      removeNodeAndDescendants(child, selectedIds);
    }
  }

  // ── 展开状态管理 ─

  /// 展开所有选中节点的祖先路径
  ///
  /// 遍历树结构，找到所有在 selectedIds 中的节点，并将其所有祖先节点的 isExpanded 设为 true。
  /// 这样当弹窗打开时，已选中的项会自动展开其父节点，方便用户查看当前选中状态。
  static void expandSelectedNodeAncestors<T extends Object>(List<TreeNode<T>> nodes, Set<T> selectedIds) {
    for (final node in nodes) {
      final hasSelectedDescendant = _hasSelectedDescendant(node, selectedIds);
      if (hasSelectedDescendant) {
        node.isExpanded = true;
      }
      expandSelectedNodeAncestors(node.children, selectedIds);
    }
  }

  /// 检查节点或其子树中是否有选中节点
  static bool _hasSelectedDescendant<T extends Object>(TreeNode<T> node, Set<T> selectedIds) {
    if (selectedIds.contains(node.id)) return true;
    for (final child in node.children) {
      if (_hasSelectedDescendant(child, selectedIds)) return true;
    }
    return false;
  }

  // ── 自动联动父节点链 ──

  /// 在树中查找指定节点的父节点（通过搜索树结构，不依赖 parentId 字段）
  static TreeNode<T>? findParentNode<T extends Object>(List<TreeNode<T>> roots, T nodeId) {
    for (final node in roots) {
      for (final child in node.children) {
        if (child.id == nodeId) return node;
      }
      final found = findParentNode(node.children, nodeId);
      if (found != null) return found;
    }
    return null;
  }

  /// 选中节点后向上联动：若祖先的所有直接子节点都已选中，自动将祖先加入 selectedIds
  ///
  /// 从 [node] 的父节点开始向上逐级检查，通过搜索树结构定位父节点，
  /// 不依赖 parentId 字段（兼容未设置 parentId 的场景）。
  static void autoSelectParentChain<T extends Object>(
    List<TreeNode<T>> roots,
    TreeNode<T> node,
    Set<T> selectedIds,
  ) {
    TreeNode<T>? current = node;
    while (current != null) {
      final parent = findParentNode(roots, current.id);
      if (parent == null) break;
      // 懒加载未完成的节点不参与联动
      if (!parent.isChildrenLoaded) break;
      // 检查所有直接子节点是否都已完全选中
      final allChildrenSelected = parent.children.every((child) => isNodeFullySelected(child, selectedIds));
      if (allChildrenSelected) {
        selectedIds.add(parent.id);
        current = parent; // 继续向上
      } else {
        break;
      }
    }
  }

  /// 取消节点后向上联动：若祖先不再完全选中，自动将祖先从 selectedIds 移除
  ///
  /// 从 [node] 的父节点开始向上逐级检查，通过搜索树结构定位父节点。
  static void autoDeselectParentChain<T extends Object>(
    List<TreeNode<T>> roots,
    TreeNode<T> node,
    Set<T> selectedIds,
  ) {
    TreeNode<T>? current = node;
    while (current != null) {
      final parent = findParentNode(roots, current.id);
      if (parent == null) break;
      if (selectedIds.contains(parent.id)) {
        selectedIds.remove(parent.id);
        current = parent; // 继续向上
      } else {
        break; // 祖先本来就没选中，无需继续
      }
    }
  }
}

import 'package:flutter/material.dart';

/// 已选项标签数据
class SelectedItemLabel<V> {
  final V value;
  final String label;
  const SelectedItemLabel({required this.value, required this.label});
}

/// 已选项查看弹窗（居中 Dialog）
///
/// 展示当前已选中的项目列表，支持逐项移除。
/// 内部维护列表状态，移除后自动刷新，全部移除后自动关闭。
class SelectedItemsDialog<V> extends StatefulWidget {
  /// 已选项列表
  final List<SelectedItemLabel<V>> items;

  /// 移除某项的回调（传入原始 value）
  final ValueChanged<V>? onRemove;

  const SelectedItemsDialog({required this.items, this.onRemove, super.key});

  /// 显示已选项弹窗
  static void show<V>({required BuildContext context, required List<SelectedItemLabel<V>> items, ValueChanged<V>? onRemove}) {
    showDialog(
      context: context,
      builder: (ctx) => SelectedItemsDialog<V>(items: items, onRemove: onRemove),
    );
  }

  @override
  State<SelectedItemsDialog<V>> createState() => _SelectedItemsDialogState<V>();
}

class _SelectedItemsDialogState<V> extends State<SelectedItemsDialog<V>> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<SelectedItemLabel<V>> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  void _handleRemove(V value) {
    final index = _items.indexWhere((item) => item.value == value);
    if (index == -1) return;

    final removed = _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: _SelectedItemRow(label: removed.label, primary: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 250),
    );
    setState(() {}); // 刷新标题计数
    widget.onRemove?.call(value);

    // 全部移除后自动关闭
    if (_items.isEmpty) {
      Future.delayed(const Duration(milliseconds: 260), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        clipBehavior: Clip.antiAlias,
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 340, maxHeight: 420),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: primary),
                        const SizedBox(width: 5),
                        Text(
                          '已选 ${_items.length} 项',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                        child: Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 列表
            Flexible(
              child: _items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                            child: Icon(Icons.inbox_outlined, size: 30, color: Colors.grey.shade400),
                          ),
                          const SizedBox(height: 12),
                          Text('暂无已选项', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  : AnimatedList(
                      key: _listKey,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      shrinkWrap: true,
                      initialItemCount: _items.length,
                      itemBuilder: (context, index, animation) {
                        final item = _items[index];
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            child: _SelectedItemRow(label: item.label, primary: primary, onRemove: () => _handleRemove(item.value)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单个已选项行
class _SelectedItemRow extends StatelessWidget {
  final String label;
  final Color primary;
  final VoidCallback? onRemove;

  const _SelectedItemRow({required this.label, required this.primary, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      margin: EdgeInsetsDirectional.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: primary.withValues(alpha: 0.10), shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, color: primary, size: 13),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: const Color(0xFF333333), fontWeight: FontWeight.w500),
            ),
          ),
          if (onRemove != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.delete_forever_outlined, size: 14, color: Colors.red.shade500),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

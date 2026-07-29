import 'package:flutter/material.dart';

/// 已选项标签数据
class SelectedItemLabel {
  final dynamic value;
  final String label;
  const SelectedItemLabel({required this.value, required this.label});
}

/// 已选项查看弹窗（居中 Dialog）
///
/// 展示当前已选中的项目列表，支持逐项移除。
/// 内部维护列表状态，移除后自动刷新，全部移除后自动关闭。
class SelectedItemsDialog extends StatefulWidget {
  /// 已选项列表
  final List<SelectedItemLabel> items;

  /// 移除某项的回调（传入原始 value）
  final ValueChanged<dynamic>? onRemove;

  const SelectedItemsDialog({required this.items, this.onRemove, super.key});

  /// 显示已选项弹窗
  static void show<V>({required BuildContext context, required List<SelectedItemLabel> items, ValueChanged<dynamic>? onRemove}) {
    showDialog(
      context: context,
      builder: (ctx) => SelectedItemsDialog(items: items, onRemove: onRemove),
    );
  }

  @override
  State<SelectedItemsDialog> createState() => _SelectedItemsDialogState();
}

class _SelectedItemsDialogState extends State<SelectedItemsDialog> {
  late List<SelectedItemLabel> _items;

  /// 记录正在执行移除动画的 value，用于淡出效果
  final Set<dynamic> _removingValues = {};

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  void _handleRemove(dynamic value) {
    // 先触发淡出动画
    setState(() => _removingValues.add(value));

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _items.removeWhere((item) => item.value == value);
        _removingValues.remove(value);
      });
      widget.onRemove?.call(value);

      // 全部移除后自动关闭
      if (_items.isEmpty) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 340, maxHeight: 420),
        decoration: BoxDecoration(
          color: theme.canvasColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 15, color: primary),
                        const SizedBox(width: 5),
                        Text(
                          '已选 ${_items.length} 项',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
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
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.close_rounded, size: 20, color: theme.hintColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.5)),

            // 列表
            Flexible(
              child: _items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: theme.hintColor.withValues(alpha: 0.06), shape: BoxShape.circle),
                            child: Icon(Icons.inbox_outlined, size: 32, color: theme.hintColor.withValues(alpha: 0.5)),
                          ),
                          const SizedBox(height: 12),
                          Text('暂无已选项', style: TextStyle(fontSize: 14, color: theme.hintColor)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      shrinkWrap: true,
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final isRemoving = _removingValues.contains(item.value);
                        return AnimatedOpacity(
                          opacity: isRemoving ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 220),
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: isRemoving
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3),
                                    child: _SelectedItemRow(label: item.label, primary: primary, onRemove: () => _handleRemove(item.value)),
                                  ),
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primary.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(color: primary.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, color: primary, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w500),
            ),
          ),
          if (onRemove != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade400),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

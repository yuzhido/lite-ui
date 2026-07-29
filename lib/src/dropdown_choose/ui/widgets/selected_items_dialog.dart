import 'package:flutter/material.dart';

/// 已选项标签数据
class SelectedItemLabel {
  final String value;
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

  /// 移除某项的回调（传入 value）
  final ValueChanged<String>? onRemove;

  const SelectedItemsDialog({
    required this.items,
    this.onRemove,
    super.key,
  });

  /// 显示已选项弹窗
  static void show<V>({
    required BuildContext context,
    required List<SelectedItemLabel> items,
    ValueChanged<String>? onRemove,
  }) {
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

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  void _handleRemove(String value) {
    setState(() {
      _items.removeWhere((item) => item.value == value);
    });
    widget.onRemove?.call(value);

    // 全部移除后自动关闭
    if (_items.isEmpty) {
      Navigator.of(context).pop();
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
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 340, maxHeight: 420),
        decoration: BoxDecoration(
          color: theme.canvasColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '已选 ${_items.length} 项',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.close, size: 20, color: theme.hintColor),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 列表
            Flexible(
              child: _items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 40, color: theme.hintColor.withValues(alpha: 0.4)),
                          const SizedBox(height: 8),
                          Text('暂无已选项', style: TextStyle(fontSize: 14, color: theme.hintColor)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _SelectedItemRow(
                          label: item.label,
                          primary: primary,
                          onRemove: () => _handleRemove(item.value),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 15)),
          ),
          if (onRemove != null)
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.cancel_outlined, size: 18, color: Colors.grey.shade400),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'suffix_clear_icon.dart';

/// 搜索输入框
///
/// 支持搜索图标、清除按钮、搜索按钮触发等功能。
/// 输入内容不会自动触发搜索，需点击搜索按钮。
class InputSearch extends StatefulWidget {
  /// 搜索框提示文字
  final String searchHint;

  /// 搜索控制器
  final TextEditingController searchController;

  /// 搜索按钮点击回调（点击搜索按钮时触发）
  final void Function(String keyword)? onSearch;

  /// 清除按钮点击回调
  ///
  /// 为 null 时不显示清除按钮
  final VoidCallback? onClear;

  /// 是否显示清除按钮，默认 true
  final bool showClearButton;

  /// 当前搜索关键字，用于控制清除按钮的显示
  final String? keyword;

  /// 是否正在加载中（加载时禁用搜索按钮）
  final bool isLoading;

  const InputSearch({
    required this.searchHint,
    required this.searchController,
    this.onSearch,
    this.onClear,
    this.showClearButton = true,
    this.keyword,
    this.isLoading = false,
    super.key,
  });

  @override
  State<InputSearch> createState() => _InputSearchState();
}

class _InputSearchState extends State<InputSearch> {
  /// 搜索按钮点击处理
  void _handleSearch() {
    if (widget.isLoading) return;
    widget.onSearch?.call(widget.searchController.text);
  }

  /// 清除按钮点击处理
  void _handleClear() {
    widget.searchController.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasKeyword = (widget.keyword ?? '').isNotEmpty;
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(5)),
              child: TextField(
                controller: widget.searchController,
                onSubmitted: (_) => _handleSearch(),
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Padding(
                    padding: EdgeInsetsGeometry.only(left: 10),
                    child: Icon(Icons.search_rounded, size: 20, color: Colors.grey.shade500),
                  ),
                  prefixIconConstraints: BoxConstraints(maxHeight: 30, maxWidth: 50),
                  suffixIcon: SuffixClearIcon(hasValue: hasKeyword, onTap: (_) => _handleClear()),
                  suffixIconConstraints: BoxConstraints(maxHeight: 30, maxWidth: 50),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Color(0xfff6f6f6), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Color(0xfff1f1f1), width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
              ),
            ),
          ),
          SizedBox(
            child: ElevatedButton.icon(
              icon: widget.isLoading
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary))
                  : Icon(Icons.search_rounded),
              onPressed: widget.isLoading ? null : _handleSearch,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                disabledBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                disabledForegroundColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.6),
                iconSize: 20,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              label: Text('搜索'),
            ),
          ),
        ],
      ),
    );
  }
}

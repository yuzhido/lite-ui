import 'package:flutter/material.dart';

import 'clear_icon.dart';

/// 搜索输入框
///
/// 支持搜索图标、清除按钮、搜索按钮触发等功能。
/// 输入内容不会自动触发搜索，需点击搜索按钮。
class InputSearch extends StatefulWidget {
  /// 搜索框提示文字
  final String? searchHint;

  /// 搜索控制器
  final TextEditingController? searchController;

  /// 搜索按钮点击回调（点击搜索按钮时触发）
  final void Function(String keyword)? onSearch;

  /// 清除按钮点击回调
  ///
  /// 为 null 时不显示清除按钮
  final VoidCallback? onClear;

  /// 是否显示清除按钮，默认 true
  final bool showClearButton;

  /// 是否正在加载中（加载时禁用搜索按钮）
  final bool isLoading;

  /// 搜索按钮背景色，不传则使用主题色
  final Color? searchButtonColor;

  /// 搜索按钮文字/图标颜色，不传则使用白色
  final Color? searchButtonTextColor;

  const InputSearch({
    this.searchHint,
    this.searchController,
    this.onSearch,
    this.onClear,
    this.showClearButton = true,
    this.isLoading = false,
    this.searchButtonColor,
    this.searchButtonTextColor,
    super.key,
  });

  @override
  State<InputSearch> createState() => _InputSearchState();
}

class _InputSearchState extends State<InputSearch> {
  late TextEditingController _searchController;
  bool hasValue = false;
  @override
  void initState() {
    super.initState();
    _searchController = widget.searchController ?? TextEditingController();
    _searchController.addListener(() {
      if (_searchController.text.trim().isNotEmpty) {
        hasValue = true;
      } else {
        hasValue = false;
      }
      setState(() {});
    });
  }

  /// 搜索按钮点击处理
  void _handleSearch() {
    if (widget.isLoading) return;
    widget.onSearch?.call(_searchController.text);
  }

  /// 清除按钮点击处理
  void _handleClear() {
    _searchController.clear();
    hasValue = false;
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final searchBg = widget.searchButtonColor ?? const Color(0xFF007AFF);
    final searchFg = widget.searchButtonTextColor ?? Colors.white;
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
                controller: _searchController,
                onSubmitted: (_) => _handleSearch(),
                decoration: InputDecoration(
                  hintText: widget.searchHint ?? '请输入关键字',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Padding(
                    padding: EdgeInsetsGeometry.only(left: 10),
                    child: Icon(Icons.search_rounded, size: 20, color: Colors.grey.shade500),
                  ),
                  prefixIconConstraints: BoxConstraints(minHeight: 30, minWidth: 30),
                  suffixIcon: ClearIcon(hasValue: hasValue, onTap: (_) => _handleClear()),
                  suffixIconConstraints: BoxConstraints(minHeight: 30, minWidth: 30),
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
              icon: widget.isLoading ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: searchFg)) : Icon(Icons.search_rounded),
              onPressed: widget.isLoading ? null : _handleSearch,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                backgroundColor: searchBg,
                foregroundColor: searchFg,
                disabledBackgroundColor: searchBg.withValues(alpha: 0.5),
                disabledForegroundColor: searchFg.withValues(alpha: 0.5),
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

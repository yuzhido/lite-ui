import 'package:flutter/material.dart';

/// 搜索输入框
///
/// 支持搜索图标、清除按钮、自定义样式等功能。
class InputSearch extends StatefulWidget {
  /// 搜索框提示文字
  final String searchHint;

  /// 搜索控制器
  final TextEditingController searchController;

  /// 搜索内容变化回调
  final void Function(String) applyFilter;

  /// 清除按钮点击回调
  ///
  /// 为 null 时不显示清除按钮
  final VoidCallback? onClear;

  /// 是否显示清除按钮，默认 true
  final bool showClearButton;

  /// 当前搜索关键字，用于控制清除按钮的显示
  final String? keyword;

  const InputSearch({required this.searchHint, required this.searchController, required this.applyFilter, this.onClear, this.showClearButton = true, this.keyword, super.key});

  @override
  State<InputSearch> createState() => _InputSearchState();
}

class _InputSearchState extends State<InputSearch> {
  @override
  Widget build(BuildContext context) {
    final showClear = widget.showClearButton && widget.onClear != null && (widget.keyword?.isNotEmpty ?? false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(10)),
        child: TextField(
          controller: widget.searchController,
          onChanged: widget.applyFilter,
          decoration: InputDecoration(
            hintText: widget.searchHint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, size: 20, color: Colors.grey.shade500),
            suffixIcon: showClear
                ? SizedBox(
                    width: 44,
                    height: 44,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.clear, size: 18, color: Colors.grey.shade500),
                      onPressed: widget.onClear,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
        ),
      ),
    );
  }
}

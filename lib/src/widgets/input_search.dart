import 'package:flutter/material.dart';

import 'suffix_clear_icon.dart';

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
                onChanged: widget.applyFilter,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Padding(
                    padding: EdgeInsetsGeometry.only(left: 10),
                    child: Icon(Icons.search_rounded, size: 20, color: Colors.grey.shade500),
                  ),
                  prefixIconConstraints: BoxConstraints(maxHeight: 30, maxWidth: 50),
                  suffixIcon: SuffixClearIcon(),
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
              icon: Icon(Icons.search_rounded),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
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

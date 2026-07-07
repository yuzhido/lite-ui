import 'package:flutter/material.dart';

class InputSearch extends StatefulWidget {
  final String searchHint;
  final TextEditingController searchController;
  final void Function(String) applyFilter;
  const InputSearch({required this.searchHint, required this.applyFilter, super.key, required this.searchController});
  @override
  State<InputSearch> createState() => _InputSearchState();
}

class _InputSearchState extends State<InputSearch> {
  @override
  Widget build(BuildContext context) {
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
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
        ),
      ),
    );
  }
}

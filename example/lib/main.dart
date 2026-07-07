import 'package:flutter/material.dart';
import 'pages/action_sheet_demo.dart';
import 'pages/dialog_action_demo.dart';
import 'pages/empty_data_demo.dart';
import 'pages/tree_select_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lite UI Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED)), useMaterial3: true),
      home: const HomePage(),
    );
  }
}

/// 首页 - 组件导航
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lite UI 组件库'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNavItem(context, icon: Icons.menu_open, title: 'ActionSheet', subtitle: '底部弹窗操作面板', page: const ActionSheetDemoPage()),
          _buildNavItem(context, icon: Icons.account_tree_rounded, title: 'TreeSelect', subtitle: '树形选择器（单选/多选）', page: const TreeSelectExamplePage()),
          _buildNavItem(context, icon: Icons.inbox_outlined, title: 'EmptyData', subtitle: '空状态数据展示组件', page: const EmptyDataDemoPage()),
          _buildNavItem(context, icon: Icons.open_in_browser, title: 'DialogAction', subtitle: '居中弹窗操作组件', page: const DialogActionDemoPage()),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String title, required String subtitle, required Widget page}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';
import 'pages/action_sheet_demo.dart';
import 'pages/dialog_action_demo.dart';
import 'pages/empty_data_demo.dart';
import 'pages/tree_select_example.dart';
import 'pages/action_sheet_new_features_demo.dart';
import 'pages/select_modal_demo.dart';
import 'pages/input_number_demo.dart';

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
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _gender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lite UI 组件库'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 10,
          children: [
            InputText(
              required: true,
              formLabel: '姓名',
              prefixIcon: Icon(Icons.person, color: Colors.green),
            ),
            InputText(
              formLabel: '年龄',
              prefixIcon: Icon(Icons.lock, color: Colors.red),
            ),
            InputText(
              formLabel: '家庭住址',
              prefixIcon: Icon(Icons.home, color: Colors.blue),
              prefixIconColor: Colors.blue,
            ),
            ActionSheet<String, int>(
              formLabel: '性别',
              title: '请选择性别',
              description: '请选择性别',
              hintText: '请选择',
              value: _gender,
              onSelect: (value, data) {
                setState(() => _gender = value);
              },
              items: [
                SelectItem(label: '男', value: '1', data: 1, icon: Icon(Icons.male)),
                SelectItem(label: '女', value: '2', data: 2, icon: Icon(Icons.female)),
              ],
            ),
            DropdownChoose(formLabel: '家庭住址'),
            // InputText(prefixText: '防守打法 SSD'),
            // InputText(prefixIcon: Icon(Icons.lock), hintText: '请输入密码', prefixText: '防守打法 SSD'),
            // InputText.multi(hintText: '请输入密码', prefixText: '防守打法 SSD'),
            _buildNavItem(context, icon: Icons.menu_open, title: 'ActionSheet', subtitle: '底部弹窗操作面板', page: const ActionSheetDemoPage()),
            _buildNavItem(context, icon: Icons.new_releases, title: 'ActionSheet 新功能', subtitle: '分组、图标、禁用状态', page: const ActionSheetNewFeaturesDemoPage()),
            _buildNavItem(context, icon: Icons.filter_list, title: 'SelectModal', subtitle: '可过滤/远程搜索选择器', page: const SelectModalDemoPage()),
            _buildNavItem(context, icon: Icons.account_tree_rounded, title: 'TreeSelect', subtitle: '树形选择器（单选/多选）', page: const TreeSelectExamplePage()),
            _buildNavItem(context, icon: Icons.inbox_outlined, title: 'EmptyData', subtitle: '空状态数据展示组件', page: const EmptyDataDemoPage()),
            _buildNavItem(context, icon: Icons.open_in_browser, title: 'DialogAction', subtitle: '居中弹窗操作组件', page: const DialogActionDemoPage()),
            _buildNavItem(context, icon: Icons.dialpad, title: 'InputNumber', subtitle: '数字加减输入组件', page: const InputNumberDemoPage()),
          ],
        ),
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

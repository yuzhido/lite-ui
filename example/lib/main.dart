import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ActionSheet Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED)),
        useMaterial3: true,
      ),
      home: const ActionSheetDemoPage(),
    );
  }
}

class ActionSheetDemoPage extends StatefulWidget {
  const ActionSheetDemoPage({super.key});

  @override
  State<ActionSheetDemoPage> createState() => _ActionSheetDemoPageState();
}

class _ActionSheetDemoPageState extends State<ActionSheetDemoPage> {
  String _selectedResult = '暂无选择';

  /// 示例数据 - 城市列表
  final List<ActionSheetItem> _cityItems = const [
    ActionSheetItem(label: '北京', subtitle: 'Beijing · 首都', value: 'beijing'),
    ActionSheetItem(label: '上海', subtitle: 'Shanghai · 经济中心', value: 'shanghai'),
    ActionSheetItem(label: '广州', subtitle: 'Guangzhou · 华南重镇', value: 'guangzhou'),
    ActionSheetItem(label: '深圳', subtitle: 'Shenzhen · 科技之城', value: 'shenzhen'),
    ActionSheetItem(label: '杭州', subtitle: 'Hangzhou · 互联网之都', value: 'hangzhou'),
    ActionSheetItem(label: '成都', subtitle: 'Chengdu · 天府之国', value: 'chengdu'),
    ActionSheetItem(label: '武汉', subtitle: 'Wuhan · 九省通衢', value: 'wuhan'),
    ActionSheetItem(label: '南京', subtitle: 'Nanjing · 六朝古都', value: 'nanjing'),
    ActionSheetItem(label: '重庆', subtitle: 'Chongqing · 山城', value: 'chongqing'),
    ActionSheetItem(label: '西安', subtitle: "Xi'an · 十三朝古都", value: 'xian'),
    ActionSheetItem(label: '苏州', subtitle: 'Suzhou · 人间天堂', value: 'suzhou'),
    ActionSheetItem(label: '天津', subtitle: 'Tianjin · 直辖市', value: 'tianjin'),
    ActionSheetItem(label: '长沙', subtitle: 'Changsha · 星城', value: 'changsha'),
    ActionSheetItem(label: '青岛', subtitle: 'Qingdao · 海滨城市', value: 'qingdao'),
    ActionSheetItem(label: '大连', subtitle: 'Dalian · 北方明珠', value: 'dalian'),
  ];

  /// 单选 Filterable 示例
  void _showFilterableSingle() async {
    final result = await ActionSheet.show(
      context: context,
      type: ActionSheetType.filterable,
      title: '选择城市',
      description: '本地过滤选择，点击即选中',
      items: _cityItems,
      searchHint: '输入城市名搜索',
    );
    if (result != null && result is ActionSheetItem) {
      setState(() => _selectedResult = '单选结果：${result.label}');
    }
  }

  /// 多选 Filterable 示例
  void _showFilterableMulti() async {
    final result = await ActionSheet.show(
      context: context,
      type: ActionSheetType.filterable,
      title: '选择多个城市',
      description: '支持多选，点击确认后返回',
      items: _cityItems,
      multiple: true,
      searchHint: '输入城市名搜索',
    );
    if (result != null && result is List<ActionSheetItem>) {
      final names = result.map((e) => e.label).join('、');
      setState(() => _selectedResult = '多选结果：$names');
    }
  }

  /// 远程搜索示例
  void _showRemoteSearch() async {
    final result = await ActionSheet.show(
      context: context,
      type: ActionSheetType.remote,
      title: '远程搜索城市',
      description: '模拟异步搜索，支持防抖',
      searchHint: '输入关键字远程搜索',
      onSearch: (keyword) async {
        // 模拟网络延迟
        await Future.delayed(const Duration(milliseconds: 500));
        if (keyword.isEmpty) return _cityItems;
        final kw = keyword.toLowerCase();
        return _cityItems.where((item) {
          return item.label.toLowerCase().contains(kw) ||
              (item.subtitle?.toLowerCase().contains(kw) ?? false);
        }).toList();
      },
    );
    if (result != null && result is ActionSheetItem) {
      setState(() => _selectedResult = '远程搜索结果：${result.label}');
    }
  }

  /// 本地操作列表示例
  void _showLocalActionSheet() async {
    final result = await ActionSheet.show(
      context: context,
      type: ActionSheetType.local,
      title: '操作菜单',
      description: '选择一个操作',
    );
    if (result != null && result is int) {
      setState(() => _selectedResult = '本地操作：选择了第 $result 项');
    }
  }

  /// 带动态数据的 Filterable 示例
  void _showFilterableWithDynamic() async {
    final result = await ActionSheet.show(
      context: context,
      type: ActionSheetType.filterable,
      title: '选择城市（含动态数据）',
      description: '输入关键字时会动态合并额外数据',
      items: _cityItems.sublist(0, 8), // 只显示前8个静态数据
      searchHint: '输入关键字搜索',
      dynamicItems: (keyword) async {
        // 模拟动态数据（如从接口获取）
        await Future.delayed(const Duration(milliseconds: 300));
        if (keyword.isEmpty) return [];
        return [
          ActionSheetItem(
            label: '动态: $keyword',
            subtitle: '这是动态生成的选项',
            value: 'dynamic_$keyword',
          ),
        ];
      },
    );
    if (result != null && result is ActionSheetItem) {
      setState(() => _selectedResult = '动态数据结果：${result.label}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ActionSheet 组件示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 结果显示卡片
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '选择结果',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedResult,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Filterable 单选
            Text('Filterable 模式', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildButton('单选 - 本地过滤选择', Icons.filter_list, _showFilterableSingle),
            const SizedBox(height: 8),
            _buildButton('多选 - 本地过滤选择', Icons.filter_list_outlined, _showFilterableMulti),
            const SizedBox(height: 8),
            _buildButton('带动态数据 - 输入时合并新选项', Icons.add_circle_outline, _showFilterableWithDynamic),
            const SizedBox(height: 24),

            // Remote 搜索
            Text('Remote 模式', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildButton('远程搜索 - 模拟异步请求', Icons.cloud, _showRemoteSearch),
            const SizedBox(height: 24),

            // Local 操作列表
            Text('Local 模式', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildButton('本地操作菜单', Icons.menu, _showLocalActionSheet),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}

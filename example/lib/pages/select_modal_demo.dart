import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';

import '../mock/select_modal_mock_data.dart';

class SelectModalDemoPage extends StatefulWidget {
  const SelectModalDemoPage({super.key});

  @override
  State<SelectModalDemoPage> createState() => _SelectModalDemoPageState();
}

class _SelectModalDemoPageState extends State<SelectModalDemoPage> {
  String _selectedResult = '暂无选择';

  /// 单选 Filterable 示例
  void _showFilterableSingle() async {
    await DropdownChoose.show<String, void>(
      context: context,
      type: SelectModalType.filterable,
      title: '选择城市',
      subTitle: '本地过滤选择，点击即选中',
      items: SelectModalMockData.cityItems,
      searchHint: '输入城市名搜索',
      onSelect: (value, data) {
        setState(() => _selectedResult = '单选结果：$value');
      },
    );
  }

  /// 多选 Filterable 示例
  void _showFilterableMulti() async {
    await DropdownChoose.show<String, void>(
      context: context,
      type: SelectModalType.filterable,
      title: '选择多个城市',
      subTitle: '支持多选，点击确认后返回',
      items: SelectModalMockData.cityItems,
      multiple: true,
      searchHint: '输入城市名搜索',
      onConfirm: (values, datas, _) {
        final names = values.join('、');
        setState(() => _selectedResult = '多选结果：$names');
      },
    );
  }

  /// 带初始选中项的 Filterable 示例
  void _showFilterableWithInitial() async {
    await DropdownChoose.show<String, void>(
      context: context,
      type: SelectModalType.filterable,
      title: '选择城市（带初始选中）',
      subTitle: '部分城市已预选',
      items: SelectModalMockData.cityItems,
      multiple: true,
      selectedValues: const {'beijing', 'shanghai'},
      searchHint: '输入城市名搜索',
      onConfirm: (values, datas, _) {
        final names = values.join('、');
        setState(() => _selectedResult = '带初始选中结果：$names');
      },
    );
  }

  /// 带图标的 Filterable 示例
  void _showFilterableWithIcon() async {
    await DropdownChoose.show<String, void>(
      context: context,
      type: SelectModalType.filterable,
      title: '选择操作',
      subTitle: '每个选项带有图标',
      items: SelectModalMockData.iconItems,
      searchHint: '输入关键字搜索',
      onSelect: (value, data) {
        setState(() => _selectedResult = '图标选择：$value');
      },
    );
  }

  /// 带禁用状态的 Filterable 示例
  void _showFilterableWithDisabled() async {
    final disabledItems = [
      SelectItem.withIcon(
        label: '拍照',
        value: 'camera',
        iconData: const IconData(0xe3ae, fontFamily: 'MaterialIcons'),
        iconColor: const Color(0xFF2196F3),
      ),
      SelectItem.withIcon(
        label: '从相册选择',
        value: 'album',
        iconData: const IconData(0xe39a, fontFamily: 'MaterialIcons'),
        iconColor: const Color(0xFF4CAF50),
        disabled: true,
        disabledLabel: '不可用',
      ),
      SelectItem.withIcon(
        label: '录制视频',
        value: 'video',
        iconData: const IconData(0xe3b1, fontFamily: 'MaterialIcons'),
        iconColor: const Color(0xFFF44336),
      ),
      SelectItem.withIcon(
        label: '文件管理器',
        value: 'files',
        iconData: const IconData(0xe2bc, fontFamily: 'MaterialIcons'),
        iconColor: const Color(0xFFFF9800),
        disabled: true,
        disabledLabel: '不可用',
      ),
      SelectItem.withIcon(
        label: '收藏夹',
        value: 'favorites',
        iconData: const IconData(0xe25b, fontFamily: 'MaterialIcons'),
        iconColor: const Color(0xFFFFC107),
      ),
    ];

    await DropdownChoose.show<String, void>(
      context: context,
      type: SelectModalType.filterable,
      title: '选择操作',
      subTitle: '部分操作不可用',
      items: disabledItems,
      searchHint: '输入关键字搜索',
      onSelect: (value, data) {
        setState(() => _selectedResult = '禁用状态选择：$value');
      },
    );
  }

  /// 远程搜索单选示例
  void _showRemoteSingle() async {
    await DropdownChoose.show<String, void>(
      context: context,
      type: SelectModalType.remote,
      title: '远程搜索城市',
      subTitle: '模拟异步搜索，支持防抖',
      searchHint: '输入关键字远程搜索',
      onRemoteSearch: (keyword) async {
        await Future.delayed(const Duration(milliseconds: 500));
        if (keyword.isEmpty) return SelectModalMockData.cityItems;
        final kw = keyword.toLowerCase();
        return SelectModalMockData.cityItems.where((item) {
          return item.label.toLowerCase().contains(kw) || (item.subtitle?.toLowerCase().contains(kw) ?? false);
        }).toList();
      },
      onSelect: (value, data) {
        setState(() => _selectedResult = '远程搜索结果：$value');
      },
    );
  }

  /// 远程搜索多选示例
  void _showRemoteMulti() async {
    await DropdownChoose.show<String, void>(
      context: context,
      type: SelectModalType.remote,
      title: '远程搜索多个城市',
      subTitle: '支持多选，点击确认后返回',
      searchHint: '输入关键字远程搜索',
      multiple: true,
      onRemoteSearch: (keyword) async {
        await Future.delayed(const Duration(milliseconds: 500));
        if (keyword.isEmpty) return SelectModalMockData.cityItems;
        final kw = keyword.toLowerCase();
        return SelectModalMockData.cityItems.where((item) {
          return item.label.toLowerCase().contains(kw) || (item.subtitle?.toLowerCase().contains(kw) ?? false);
        }).toList();
      },
      onConfirm: (values, datas, _) {
        final names = values.join('、');
        setState(() => _selectedResult = '远程多选结果：$names');
      },
    );
  }

  /// 带初始数据的远程搜索示例
  void _showRemoteWithInitial() async {
    await DropdownChoose.show<String, void>(
      context: context,
      type: SelectModalType.remote,
      title: '远程搜索城市（带初始数据）',
      subTitle: '打开时显示初始数据，搜索时远程获取',
      searchHint: '输入关键字远程搜索',
      items: SelectModalMockData.cityItems.sublist(0, 5),
      onRemoteSearch: (keyword) async {
        await Future.delayed(const Duration(milliseconds: 500));
        if (keyword.isEmpty) return SelectModalMockData.cityItems;
        final kw = keyword.toLowerCase();
        return SelectModalMockData.cityItems.where((item) {
          return item.label.toLowerCase().contains(kw) || (item.subtitle?.toLowerCase().contains(kw) ?? false);
        }).toList();
      },
      onSelect: (value, data) {
        setState(() => _selectedResult = '带初始数据结果：$value');
      },
    );
  }

  /// 带初始选中项的远程搜索示例
  void _showRemoteWithSelected() async {
    await DropdownChoose.show<String, void>(
      context: context,
      type: SelectModalType.remote,
      title: '远程搜索城市（带初始选中）',
      subTitle: '部分城市已预选',
      searchHint: '输入关键字远程搜索',
      multiple: true,
      selectedValues: const {'beijing', 'shanghai'},
      items: SelectModalMockData.cityItems,
      onRemoteSearch: (keyword) async {
        await Future.delayed(const Duration(milliseconds: 500));
        if (keyword.isEmpty) return SelectModalMockData.cityItems;
        final kw = keyword.toLowerCase();
        return SelectModalMockData.cityItems.where((item) {
          return item.label.toLowerCase().contains(kw) || (item.subtitle?.toLowerCase().contains(kw) ?? false);
        }).toList();
      },
      onConfirm: (values, datas, _) {
        final names = values.join('、');
        setState(() => _selectedResult = '带初始选中结果：$names');
      },
    );
  }

  /// 自定义空状态提示的远程搜索示例
  void _showRemoteCustomEmpty() async {
    await DropdownChoose.show<String, void>(
      context: context,
      type: SelectModalType.remote,
      title: '远程搜索城市',
      subTitle: '自定义空状态提示',
      searchHint: '输入关键字远程搜索',
      emptyText: '没有找到匹配的城市',
      onRemoteSearch: (keyword) async {
        await Future.delayed(const Duration(milliseconds: 500));
        if (keyword.isEmpty) return SelectModalMockData.cityItems;
        final kw = keyword.toLowerCase();
        return SelectModalMockData.cityItems.where((item) {
          return item.label.toLowerCase().contains(kw) || (item.subtitle?.toLowerCase().contains(kw) ?? false);
        }).toList();
      },
      onSelect: (value, data) {
        setState(() => _selectedResult = '自定义空状态结果：$value');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SelectModal 组件示例'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
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
                    Text('选择结果', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                    const SizedBox(height: 4),
                    Text(
                      _selectedResult,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Filterable 单选
            Text('SelectModalFilterable 单选模式', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildButton('基本单选 - 本地过滤选择', Icons.filter_list, _showFilterableSingle),
            const SizedBox(height: 8),
            _buildButton('带初始选中项', Icons.check_circle_outline, _showFilterableWithInitial),
            const SizedBox(height: 8),
            _buildButton('带图标选项', Icons.image, _showFilterableWithIcon),
            const SizedBox(height: 8),
            _buildButton('带禁用状态', Icons.block, _showFilterableWithDisabled),
            const SizedBox(height: 24),

            // Filterable 多选
            Text('SelectModalFilterable 多选模式', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildButton('基本多选 - 本地过滤选择', Icons.filter_list_outlined, _showFilterableMulti),
            const SizedBox(height: 24),

            // Remote 单选
            Text('SelectModalRemote 单选模式', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildButton('基本远程搜索', Icons.cloud, _showRemoteSingle),
            const SizedBox(height: 8),
            _buildButton('带初始数据', Icons.history, _showRemoteWithInitial),
            const SizedBox(height: 8),
            _buildButton('自定义空状态提示', Icons.info_outline, _showRemoteCustomEmpty),
            const SizedBox(height: 24),

            // Remote 多选
            Text('SelectModalRemote 多选模式', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildButton('远程搜索多选', Icons.cloud_queue, _showRemoteMulti),
            const SizedBox(height: 8),
            _buildButton('带初始选中项', Icons.check_circle, _showRemoteWithSelected),
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
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), alignment: Alignment.centerLeft),
    );
  }
}

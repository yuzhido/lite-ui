import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';

import '../mock/action_sheet_mock_data.dart';

class ActionSheetDemoPage extends StatefulWidget {
  const ActionSheetDemoPage({super.key});

  @override
  State<ActionSheetDemoPage> createState() => _ActionSheetDemoPageState();
}

class _ActionSheetDemoPageState extends State<ActionSheetDemoPage> {
  String _selectedResult = '暂无选择';

  /// 基本本地操作列表示例
  void _showLocalActionSheet() async {
    await ActionSheet.show<String, void>(
      context: context,
      type: ActionSheetType.local,
      title: '操作菜单',
      description: '选择一个操作',
      items: ActionSheetMockData.defaultItems,
      onSelect: (value, data) {
        setState(() => _selectedResult = '本地操作：选择了 $value');
      },
    );
  }

  /// 分组显示示例
  void _showSectionedExample() async {
    await ActionSheet.show<String, void>(
      context: context,
      type: ActionSheetType.local,
      title: '文件操作',
      description: '选择一个操作',
      sections: ActionSheetMockData.sectionedItems,
      onSelect: (value, data) {
        setState(() => _selectedResult = '分组选择：$value');
      },
    );
  }

  /// 带图标的列表项示例
  void _showIconExample() async {
    await ActionSheet.show<String, void>(
      context: context,
      type: ActionSheetType.local,
      title: '操作菜单',
      description: '每个操作项带有图标',
      items: ActionSheetMockData.iconItems,
      onSelect: (value, data) {
        setState(() => _selectedResult = '图标选择：$value');
      },
    );
  }

  /// 禁用状态示例
  void _showDisabledExample() async {
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

    await ActionSheet.show<String, void>(
      context: context,
      type: ActionSheetType.local,
      title: '操作菜单',
      description: '部分操作不可用',
      showDisabledBadge: true,
      items: disabledItems,
      onSelect: (value, data) {
        setState(() => _selectedResult = '禁用状态选择：$value');
      },
    );
  }

  /// 分组 + 图标 + 禁用状态组合示例
  void _showCombinedExample() async {
    await ActionSheet.show<String, void>(
      context: context,
      type: ActionSheetType.local,
      title: '完整功能示例',
      description: '分组 + 图标 + 禁用状态组合',
      showDisabledBadge: true,
      sections: [
        ActionSheetSection(
          title: '文件操作',
          items: [
            SelectItem.withIcon(
              label: '新建文档',
              value: 'new_doc',
              iconData: const IconData(0xe234, fontFamily: 'MaterialIcons'),
              iconColor: const Color(0xFF2196F3),
            ),
            SelectItem.withIcon(
              label: '新建文件夹',
              value: 'new_folder',
              iconData: const IconData(0xe2bc, fontFamily: 'MaterialIcons'),
              iconColor: const Color(0xFFFF9800),
            ),
            SelectItem.withIcon(
              label: '从剪贴板粘贴',
              value: 'paste',
              iconData: const IconData(0xe14e, fontFamily: 'MaterialIcons'),
              iconColor: const Color(0xFF4CAF50),
              disabled: true,
              disabledLabel: '不可用',
            ),
          ],
        ),
        ActionSheetSection(
          title: '分享选项',
          items: [
            SelectItem.withIcon(
              label: '微信好友',
              value: 'wechat',
              iconData: const IconData(0xe0a7, fontFamily: 'MaterialIcons'),
              iconColor: const Color(0xFF4CAF50),
            ),
            SelectItem.withIcon(
              label: '短信分享',
              value: 'sms',
              iconData: const IconData(0xe0d0, fontFamily: 'MaterialIcons'),
              iconColor: const Color(0xFF2196F3),
            ),
            SelectItem.withIcon(
              label: '复制链接',
              value: 'copy_link',
              iconData: const IconData(0xe157, fontFamily: 'MaterialIcons'),
              iconColor: const Color(0xFF9C27B0),
            ),
          ],
        ),
      ],
      onSelect: (value, data) {
        setState(() => _selectedResult = '组合功能选择：$value');
      },
    );
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

            // 基本功能
            Text('基本功能', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildButton('默认操作菜单', Icons.menu, _showLocalActionSheet),
            const SizedBox(height: 24),

            // 高级功能
            Text('高级功能', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildButton('分组显示 - 操作项分组', Icons.view_list, _showSectionedExample),
            const SizedBox(height: 8),
            _buildButton('图标支持 - 列表项带图标', Icons.image, _showIconExample),
            const SizedBox(height: 8),
            _buildButton('禁用状态 - 部分操作不可用', Icons.block, _showDisabledExample),
            const SizedBox(height: 8),
            _buildButton('组合功能 - 分组+图标+禁用', Icons.dynamic_feed, _showCombinedExample),
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

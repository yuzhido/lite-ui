import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';

class ActionSheetNewFeaturesDemoPage extends StatefulWidget {
  const ActionSheetNewFeaturesDemoPage({super.key});

  @override
  State<ActionSheetNewFeaturesDemoPage> createState() => _ActionSheetNewFeaturesDemoPageState();
}

class _ActionSheetNewFeaturesDemoPageState extends State<ActionSheetNewFeaturesDemoPage> {
  String _selectedResult = '暂无选择';

  /// 示例1：分组显示
  void _showSectionedExample() async {
    await ActionSheet.show<String, void>(
      context: context,
      title: '文件操作',
      description: '选择一个操作',
      sections: [
        SheetSection(
          title: '文件操作',
          items: [
            SelectItem(label: '新建文档', value: 'new_doc'),
            SelectItem(label: '新建文件夹', value: 'new_folder'),
            SelectItem(label: '从剪贴板粘贴', value: 'paste'),
          ],
        ),
        SheetSection(
          title: '分享选项',
          items: [
            SelectItem(label: '微信好友', value: 'wechat'),
            SelectItem(label: '短信分享', value: 'sms'),
            SelectItem(label: '复制链接', value: 'copy_link'),
          ],
        ),
      ],
      onSelect: (value, item, data) {
        setState(() => _selectedResult = '分组选择：$value');
      },
    );
  }

  /// 示例2：带图标的列表项
  void _showIconExample() async {
    await ActionSheet.show<String, void>(
      context: context,
      title: '操作菜单',
      description: '每个操作项带有图标',
      items: [
        SelectItem.withIcon(label: '拍照', value: 'camera', iconData: Icons.camera_alt, iconColor: Colors.blue),
        SelectItem.withIcon(label: '从相册选择', value: 'album', iconData: Icons.photo_library, iconColor: Colors.green),
        SelectItem.withIcon(label: '录制视频', value: 'video', iconData: Icons.videocam, iconColor: Colors.red),
        SelectItem.withIcon(label: '文件管理器', value: 'files', iconData: Icons.folder_open, iconColor: Colors.orange),
        SelectItem.withIcon(label: '收藏夹', value: 'favorites', iconData: Icons.star, iconColor: Colors.amber),
      ],
      onSelect: (value, item, data) {
        setState(() => _selectedResult = '图标选择：$value');
      },
    );
  }

  /// 示例3：禁用状态
  void _showDisabledExample() async {
    await ActionSheet.show<String, void>(
      context: context,
      title: '操作菜单',
      description: '部分操作不可用',
      showDisabledBadge: true,
      items: [
        SelectItem.withIcon(label: '拍照', value: 'camera', iconData: Icons.camera_alt, iconColor: Colors.blue),
        SelectItem.withIcon(label: '从相册选择', value: 'album', iconData: Icons.photo_library, iconColor: Colors.green, disabled: true, disabledLabel: '不可用'),
        SelectItem.withIcon(label: '录制视频', value: 'video', iconData: Icons.videocam, iconColor: Colors.red),
        SelectItem.withIcon(label: '文件管理器', value: 'files', iconData: Icons.folder_open, iconColor: Colors.orange, disabled: true, disabledLabel: '不可用'),
        SelectItem.withIcon(label: '收藏夹', value: 'favorites', iconData: Icons.star, iconColor: Colors.amber),
      ],
      onSelect: (value, item, data) {
        setState(() => _selectedResult = '禁用状态选择：$value');
      },
    );
  }

  /// 示例4：组合功能
  void _showCombinedExample() async {
    await ActionSheet.show<String, void>(
      context: context,
      title: '完整功能示例',
      description: '分组 + 图标 + 禁用状态组合',
      showDisabledBadge: true,
      sections: [
        SheetSection(
          title: '文件操作',
          items: [
            SelectItem.withIcon(label: '新建文档', value: 'new_doc', iconData: Icons.description, iconColor: Colors.blue),
            SelectItem.withIcon(label: '新建文件夹', value: 'new_folder', iconData: Icons.folder, iconColor: Colors.orange),
            SelectItem.withIcon(label: '从剪贴板粘贴', value: 'paste', iconData: Icons.content_paste, iconColor: Colors.green, disabled: true, disabledLabel: '不可用'),
          ],
        ),
        SheetSection(
          title: '分享选项',
          items: [
            SelectItem.withIcon(label: '微信好友', value: 'wechat', iconData: Icons.chat_bubble, iconColor: Colors.green),
            SelectItem.withIcon(label: '短信分享', value: 'sms', iconData: Icons.sms, iconColor: Colors.blue),
            SelectItem.withIcon(label: '复制链接', value: 'copy_link', iconData: Icons.link, iconColor: Colors.purple),
          ],
        ),
      ],
      onSelect: (value, item, data) {
        setState(() => _selectedResult = '组合功能选择：$value');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ActionSheet 新功能'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
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

            // 功能说明
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('新功能说明', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildFeatureItem('分组显示', '通过 SheetSection 实现操作项分组，每组有独立标题', Icons.view_list),
                    const SizedBox(height: 8),
                    _buildFeatureItem('图标支持', '通过 SelectItem.withIcon() 或 iconData 属性添加图标', Icons.image),
                    const SizedBox(height: 8),
                    _buildFeatureItem('禁用状态', '通过 disabled: true 禁用操作项，可选显示禁用标签', Icons.block),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 示例按钮
            Text('功能示例', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildButton('分组显示 - 操作项分组', Icons.view_list, _showSectionedExample),
            const SizedBox(height: 8),
            _buildButton('图标支持 - 列表项带图标', Icons.image, _showIconExample),
            const SizedBox(height: 8),
            _buildButton('禁用状态 - 部分操作不可用', Icons.block, _showDisabledExample),
            const SizedBox(height: 8),
            _buildButton('组合功能 - 分组+图标+禁用', Icons.dynamic_feed, _showCombinedExample),
            const SizedBox(height: 24),

            // 代码示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('代码示例', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: const Text('''ActionSheet.show<String, void>(
  context: context,
  title: '操作菜单',
  showDisabledBadge: true,
  sections: [
    SheetSection(
      title: '文件操作',
      items: [
        SelectItem.withIcon(
          label: '新建文档',
          value: 'new_doc',
          iconData: Icons.description,
          iconColor: Colors.blue,
        ),
        SelectItem.withIcon(
          label: '从剪贴板粘贴',
          value: 'paste',
          iconData: Icons.content_paste,
          iconColor: Colors.green,
          disabled: true,
          disabledLabel: '不可用',
        ),
      ],
    ),
  ],
  onSelect: (value, item, data) {
    print('选中: \$value');
  },
);''', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      ],
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

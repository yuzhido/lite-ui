import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';

class DialogActionDemoPage extends StatefulWidget {
  const DialogActionDemoPage({super.key});

  @override
  State<DialogActionDemoPage> createState() => _DialogActionDemoPageState();
}

class _DialogActionDemoPageState extends State<DialogActionDemoPage> {
  String _result = '暂无操作结果';

  /// Alert 提示弹窗（使用默认值，只需传 context 和 type）
  void _showAlertDefault() async {
    await DialogAction.show(context: context, type: DialogActionType.alert);
    setState(() => _result = 'Alert 默认弹窗已关闭');
  }

  /// Alert 提示弹窗（自定义覆盖）
  void _showAlert() async {
    await DialogAction.show(context: context, type: DialogActionType.alert, title: '操作成功', content: '数据已保存，请稍后查看详细信息。', confirmLabel: '知道了', presetIcon: DialogPresetIcon.success);
    setState(() => _result = 'Alert 弹窗已关闭');
  }

  /// Confirm 确认弹窗（使用默认值）
  void _showConfirmDefault() async {
    final result = await DialogAction.show<bool>(context: context, type: DialogActionType.confirm);
    setState(() => _result = 'Confirm 默认结果：$result');
  }

  /// Confirm 确认弹窗（自定义覆盖）
  void _showConfirm() async {
    final result = await DialogAction.show<bool>(
      context: context,
      type: DialogActionType.confirm,
      title: '确认删除',
      content: '删除后数据将无法恢复，是否继续？',
      confirmLabel: '删除',
      confirmStyle: DialogButtonStyle.destructive,
      presetIcon: DialogPresetIcon.warning,
    );
    setState(() => _result = 'Confirm 结果：$result');
  }

  /// Input 输入弹窗（使用默认值）
  void _showInputDefault() async {
    final result = await DialogAction.show<String>(context: context, type: DialogActionType.input);
    setState(() => _result = 'Input 默认结果：${result ?? '未输入'}');
  }

  /// Input 输入弹窗（自定义覆盖）
  void _showInput() async {
    final result = await DialogAction.show<String>(
      context: context,
      type: DialogActionType.input,
      title: '重命名',
      content: '请输入新的名称',
      hintText: '请输入名称',
      initialValue: '默认名称',
      maxLength: 20,
    );
    setState(() => _result = 'Input 结果：${result ?? '未输入'}');
  }

  /// MultiAction 多操作弹窗
  void _showMultiAction() async {
    final result = await DialogAction.show<String>(
      context: context,
      type: DialogActionType.multiAction,
      title: '选择操作',
      content: '请选择你要执行的操作',
      actions: [
        const DialogActionButton<String>(label: '拍照', value: 'camera', style: DialogButtonStyle.primary),
        const DialogActionButton<String>(label: '从相册选择', value: 'album', style: DialogButtonStyle.primary),
        const DialogActionButton<String>(label: '拍摄视频', value: 'video'),
        const DialogActionButton<String>(label: '文件', value: 'file'),
        const DialogActionButton<String>(label: '取消', value: 'cancel', style: DialogButtonStyle.normal),
      ],
    );
    setState(() => _result = 'MultiAction 结果：${result ?? '未选择'}');
  }

  /// Custom 自定义内容弹窗
  void _showCustom() async {
    await DialogAction.show(
      context: context,
      type: DialogActionType.custom,
      customChild: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text('操作完成', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('自定义内容弹窗可以放置任意 Widget', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('关闭')),
          ],
        ),
      ),
    );
    setState(() => _result = 'Custom 弹窗已关闭');
  }

  /// 自定义图标弹窗
  void _showCustomIcon() async {
    await DialogAction.show(
      context: context,
      type: DialogActionType.alert,
      title: '网络错误',
      content: '请检查网络连接后重试',
      confirmLabel: '重试',
      icon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
        child: Icon(Icons.wifi_off_rounded, color: Colors.red.shade400, size: 32),
      ),
    );
    setState(() => _result = '自定义图标弹窗已关闭');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DialogAction 组件示例'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
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
                    Text('操作结果', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                    const SizedBox(height: 4),
                    Text(
                      _result,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Alert 模式
            Text('Alert 模式', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildButton('默认提示弹窗（只传 type）', Icons.info, _showAlertDefault),
            const SizedBox(height: 8),
            _buildButton('自定义提示弹窗（覆盖默认）', Icons.info_outline, _showAlert),
            const SizedBox(height: 8),
            _buildButton('自定义图标弹窗', Icons.image_outlined, _showCustomIcon),
            const SizedBox(height: 24),

            // Confirm 模式
            Text('Confirm 模式', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildButton('默认确认弹窗（只传 type）', Icons.help_outline, _showConfirmDefault),
            const SizedBox(height: 8),
            _buildButton('自定义确认弹窗（覆盖默认）', Icons.warning_outlined, _showConfirm),
            const SizedBox(height: 24),

            // Input 模式
            Text('Input 模式', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildButton('默认输入弹窗（只传 type）', Icons.text_fields, _showInputDefault),
            const SizedBox(height: 8),
            _buildButton('自定义输入弹窗（覆盖默认）', Icons.edit_outlined, _showInput),
            const SizedBox(height: 24),

            // MultiAction 模式
            Text('MultiAction 模式', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildButton('多操作弹窗', Icons.list_alt, _showMultiAction),
            const SizedBox(height: 24),

            // Custom 模式
            Text('Custom 模式', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildButton('自定义内容弹窗', Icons.widgets_outlined, _showCustom),
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

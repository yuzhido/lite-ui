import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';

class EmptyDataDemoPage extends StatefulWidget {
  const EmptyDataDemoPage({super.key});

  @override
  State<EmptyDataDemoPage> createState() => _EmptyDataDemoPageState();
}

class _EmptyDataDemoPageState extends State<EmptyDataDemoPage> {
  bool _hasData = false;
  bool _isNetworkError = false;
  bool _animateEnabled = true;
  int _animationMs = 400;
  EmptyDataType _selectedType = EmptyDataType.empty;
  EmptyDataStyle _selectedStyle = EmptyDataStyle.defaultStyle;
  int _animKey = 0; // 用于触发动画重播

  void _toggleData() {
    setState(() {
      _hasData = !_hasData;
      if (_hasData) _isNetworkError = false;
    });
  }

  void _simulateNetworkError() {
    setState(() {
      _isNetworkError = true;
      _hasData = false;
    });
  }

  void _replayAnimation() {
    setState(() => _animKey++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EmptyData 组件示例'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== 8 种场景类型 =====
            Text('场景类型 (8种)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final t in EmptyDataType.values) _buildTypeChip(context, t)]),
            const SizedBox(height: 24),

            // ===== 4 种布局风格 =====
            Text('布局风格 (4种)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildStyleCard(context, 'defaultStyle — 居中圆形图标', EmptyDataStyle.defaultStyle),
            const SizedBox(height: 8),
            _buildStyleCard(context, 'compact — 横向紧凑', EmptyDataStyle.compact),
            const SizedBox(height: 8),
            _buildStyleCard(context, 'card — 装饰卡片', EmptyDataStyle.card),
            const SizedBox(height: 8),
            _buildStyleCard(context, 'minimal — 极简文字', EmptyDataStyle.minimal),
            const SizedBox(height: 24),

            // ===== 预设场景卡片 =====
            Text('预设场景', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildTypeCard(context, '默认空状态', EmptyDataType.empty),
            const SizedBox(height: 8),
            _buildTypeCard(context, '搜索无结果', EmptyDataType.search),
            const SizedBox(height: 8),
            _buildTypeCard(context, '网络异常', EmptyDataType.noNetwork),
            const SizedBox(height: 8),
            _buildTypeCard(context, '加载失败', EmptyDataType.error),
            const SizedBox(height: 8),
            _buildTypeCard(context, '无访问权限', EmptyDataType.noPermission),
            const SizedBox(height: 8),
            _buildTypeCard(context, '暂无消息', EmptyDataType.noMessage),
            const SizedBox(height: 8),
            _buildTypeCard(context, '暂无订单', EmptyDataType.noOrder),
            const SizedBox(height: 8),
            _buildTypeCard(context, '系统维护中', EmptyDataType.maintenance),
            const SizedBox(height: 24),

            // ===== 动画控制 =====
            Text('动画控制', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 开关
                    Row(
                      children: [
                        const Text('入场动画', style: TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Switch(value: _animateEnabled, onChanged: (v) => setState(() => _animateEnabled = v)),
                      ],
                    ),
                    // 时长滑块
                    Row(
                      children: [
                        const Text('时长', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Slider(
                            value: _animationMs.toDouble(),
                            min: 100,
                            max: 1200,
                            divisions: 11,
                            label: '${_animationMs}ms',
                            onChanged: (v) => setState(() => _animationMs = v.round()),
                          ),
                        ),
                        Text('${_animationMs}ms', style: const TextStyle(fontSize: 13, fontFamily: 'monospace')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 重播按钮
                    Center(
                      child: OutlinedButton.icon(onPressed: _replayAnimation, icon: const Icon(Icons.replay, size: 18), label: const Text('重播动画')),
                    ),
                    const SizedBox(height: 16),
                    // 预览
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 180),
                      child: Center(
                        child: EmptyData(
                          key: ValueKey(_animKey),
                          type: _selectedType,
                          style: _selectedStyle,
                          animate: _animateEnabled,
                          animationDuration: Duration(milliseconds: _animationMs),
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 类型/风格选择
                    Row(
                      children: [
                        const Text('类型', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<EmptyDataType>(
                            initialValue: _selectedType,
                            isDense: true,
                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), border: OutlineInputBorder()),
                            items: [
                              for (final t in EmptyDataType.values)
                                DropdownMenuItem(
                                  value: t,
                                  child: Text(t.name, style: const TextStyle(fontSize: 12)),
                                ),
                            ],
                            onChanged: (v) => setState(() => _selectedType = v ?? EmptyDataType.empty),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('风格', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<EmptyDataStyle>(
                            initialValue: _selectedStyle,
                            isDense: true,
                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), border: OutlineInputBorder()),
                            items: [
                              for (final s in EmptyDataStyle.values)
                                DropdownMenuItem(
                                  value: s,
                                  child: Text(s.name, style: const TextStyle(fontSize: 12)),
                                ),
                            ],
                            onChanged: (v) => setState(() => _selectedStyle = v ?? EmptyDataStyle.defaultStyle),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ===== 带操作按钮 =====
            Text('带操作按钮', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EmptyData(
                  type: EmptyDataType.empty,
                  actionLabel: '添加数据',
                  onAction: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('点击了「添加数据」')));
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EmptyData(
                  type: EmptyDataType.noOrder,
                  style: EmptyDataStyle.card,
                  actionLabel: '去下单',
                  onAction: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('点击了「去下单」')));
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ===== 实际使用模拟 =====
            Text('实际使用模拟', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: FilledButton(onPressed: _toggleData, child: Text(_hasData ? '清空数据' : '加载数据')),
                        ),
                        Expanded(
                          child: OutlinedButton(onPressed: _simulateNetworkError, child: const Text('模拟网络错误')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(constraints: const BoxConstraints(minHeight: 250), child: _buildSimulatedList()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ===== 禁用动画 =====
            Text('禁用动画', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EmptyData(
                  type: EmptyDataType.search,
                  style: EmptyDataStyle.card,
                  animate: false, // 禁用动画，直接显示
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ===== 完全自定义 =====
            Text('完全自定义', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EmptyData(
                  icon: const Icon(Icons.emoji_emotions_outlined, size: 40, color: Color(0xFFF59E0B)),
                  iconBackgroundColor: const Color(0xFFFEF3C7),
                  title: '这里空空如也~',
                  description: '暂时没有内容，去别处看看吧',
                  titleStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                  descriptionStyle: const TextStyle(fontSize: 13, color: Color(0xFFB45309)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 场景类型标签
  Widget _buildTypeChip(BuildContext context, EmptyDataType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: EmptyData.bgColorOf(type), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(EmptyData.iconOf(type), size: 14, color: EmptyData.iconColorOf(type)),
          const SizedBox(width: 6),
          Text(
            type.name,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: EmptyData.iconColorOf(type)),
          ),
        ],
      ),
    );
  }

  /// 风格卡片
  Widget _buildStyleCard(BuildContext context, String label, EmptyDataStyle style) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 12),
            SizedBox(
              height: style == EmptyDataStyle.compact ? 60 : 180,
              child: Center(
                child: EmptyData(type: EmptyDataType.empty, style: style, padding: EdgeInsets.zero),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建类型预览卡片
  Widget _buildTypeCard(BuildContext context, String label, EmptyDataType type) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 左侧小预览
            SizedBox(
              width: 120,
              height: 150,
              child: EmptyData(type: type, iconSize: 52, padding: EdgeInsets.zero),
            ),
            const SizedBox(width: 16),
            // 右侧说明
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    'EmptyDataType.${type.name}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 4),
                  Text('EmptyData(type: EmptyDataType.${type.name})', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 模拟数据列表 / 空状态切换
  Widget _buildSimulatedList() {
    if (_isNetworkError) {
      return EmptyData(
        type: EmptyDataType.noNetwork,
        actionLabel: '重新加载',
        onAction: () {
          setState(() {
            _isNetworkError = false;
            _hasData = true;
          });
        },
      );
    }
    if (!_hasData) {
      return const EmptyData(type: EmptyDataType.empty);
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text('数据项 ${index + 1}'),
          subtitle: const Text('这是加载后的列表数据'),
        );
      },
    );
  }
}

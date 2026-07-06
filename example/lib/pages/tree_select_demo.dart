import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';

class TreeSelectDemoPage extends StatefulWidget {
  const TreeSelectDemoPage({super.key});

  @override
  State<TreeSelectDemoPage> createState() => _TreeSelectDemoPageState();
}

class _TreeSelectDemoPageState extends State<TreeSelectDemoPage> {
  String _selectedResult = '暂无选择';

  // ─── 本地树形数据 ───

  final List<TreeSelectItem<String, void>> _deptItems = const [
    TreeSelectItem(
      label: '技术部',
      value: 'tech',
      children: [
        TreeSelectItem(label: '前端组', value: 'frontend', subtitle: '8 人'),
        TreeSelectItem(label: '后端组', value: 'backend', subtitle: '12 人'),
        TreeSelectItem(label: '测试组', value: 'qa', subtitle: '5 人'),
        TreeSelectItem(label: '运维组', value: 'ops', subtitle: '3 人'),
      ],
    ),
    TreeSelectItem(
      label: '产品部',
      value: 'product',
      children: [
        TreeSelectItem(label: '产品设计', value: 'pd', subtitle: '4 人'),
        TreeSelectItem(label: '产品运营', value: 'po', subtitle: '6 人'),
        TreeSelectItem(label: '数据分析', value: 'data', subtitle: '3 人'),
      ],
    ),
    TreeSelectItem(
      label: '设计部',
      value: 'design',
      children: [
        TreeSelectItem(label: 'UI 设计', value: 'ui', subtitle: '5 人'),
        TreeSelectItem(label: 'UX 设计', value: 'ux', subtitle: '3 人'),
        TreeSelectItem(label: '视觉设计', value: 'visual', subtitle: '2 人'),
      ],
    ),
    TreeSelectItem(label: '人事部', value: 'hr', subtitle: '6 人'),
    TreeSelectItem(label: '财务部', value: 'finance', subtitle: '4 人'),
  ];

  // ─── 地区级联数据 ───

  final List<TreeSelectItem<String, void>> _regionItems = const [
    TreeSelectItem(
      label: '广东省',
      value: 'gd',
      children: [
        TreeSelectItem(
          label: '深圳市',
          value: 'sz',
          children: [
            TreeSelectItem(label: '南山区', value: 'ns'),
            TreeSelectItem(label: '福田区', value: 'ft'),
            TreeSelectItem(label: '罗湖区', value: 'lh'),
            TreeSelectItem(label: '宝安区', value: 'ba'),
            TreeSelectItem(label: '龙华区', value: 'lha'),
          ],
        ),
        TreeSelectItem(
          label: '广州市',
          value: 'gz',
          children: [
            TreeSelectItem(label: '天河区', value: 'th'),
            TreeSelectItem(label: '越秀区', value: 'yx'),
            TreeSelectItem(label: '海珠区', value: 'hz'),
            TreeSelectItem(label: '白云区', value: 'by'),
          ],
        ),
        TreeSelectItem(
          label: '东莞市',
          value: 'dg',
          children: [
            TreeSelectItem(label: '南城街道', value: 'nc'),
            TreeSelectItem(label: '东城街道', value: 'dc'),
            TreeSelectItem(label: '莞城街道', value: 'gc'),
          ],
        ),
      ],
    ),
    TreeSelectItem(
      label: '浙江省',
      value: 'zj',
      children: [
        TreeSelectItem(
          label: '杭州市',
          value: 'hz_city',
          children: [
            TreeSelectItem(label: '西湖区', value: 'xh'),
            TreeSelectItem(label: '滨江区', value: 'bj'),
            TreeSelectItem(label: '余杭区', value: 'yh'),
          ],
        ),
        TreeSelectItem(
          label: '宁波市',
          value: 'nb',
          children: [
            TreeSelectItem(label: '海曙区', value: 'hs'),
            TreeSelectItem(label: '鄞州区', value: 'yz'),
          ],
        ),
      ],
    ),
    TreeSelectItem(
      label: '江苏省',
      value: 'js',
      children: [
        TreeSelectItem(
          label: '南京市',
          value: 'nj',
          children: [
            TreeSelectItem(label: '玄武区', value: 'xw'),
            TreeSelectItem(label: '鼓楼区', value: 'gl'),
            TreeSelectItem(label: '建邺区', value: 'jy'),
          ],
        ),
        TreeSelectItem(
          label: '苏州市',
          value: 'suzhou',
          children: [
            TreeSelectItem(label: '姑苏区', value: 'gs'),
            TreeSelectItem(label: '吴中区', value: 'wz'),
          ],
        ),
      ],
    ),
  ];

  // ─── 示例方法 ───

  /// 竖向单选
  void _showVerticalSingle() async {
    await TreeSelect.show<String, void>(
      context: context,
      layout: TreeLayout.vertical,
      title: '选择部门',
      subtitle: '竖向缩进 · 单选模式',
      items: _deptItems,
      searchHint: '搜索部门...',
      onSelect: (value, data) {
        setState(() => _selectedResult = '单选：$value');
      },
    );
  }

  /// 竖向多选（父子联动）
  void _showVerticalMulti() async {
    await TreeSelect.show<String, void>(
      context: context,
      layout: TreeLayout.vertical,
      title: '选择部门（多选）',
      subtitle: '父子联动 · 多选模式',
      items: _deptItems,
      multiple: true,
      searchHint: '搜索部门...',
      onConfirm: (values, datas) {
        setState(() => _selectedResult = '多选：${values.join("、")}');
      },
    );
  }

  /// 竖向多选（父子独立）
  void _showVerticalMultiIndependent() async {
    await TreeSelect.show<String, void>(
      context: context,
      layout: TreeLayout.vertical,
      title: '选择部门（独立多选）',
      subtitle: '父子独立 · 不联动',
      items: _deptItems,
      multiple: true,
      checkStrictly: false,
      searchHint: '搜索部门...',
      onConfirm: (values, datas) {
        setState(() => _selectedResult = '独立多选：${values.join("、")}');
      },
    );
  }

  /// 横向级联单选
  void _showCascadeSingle() async {
    await TreeSelect.show<String, void>(
      context: context,
      layout: TreeLayout.cascade,
      title: '选择地区',
      subtitle: '横向级联 · 三级联动',
      items: _regionItems,
      cascadeLevels: ['省份', '城市', '区县'],
      onSelect: (value, data) {
        setState(() => _selectedResult = '级联选择：$value');
      },
    );
  }

  /// 横向级联多选
  void _showCascadeMulti() async {
    await TreeSelect.show<String, void>(
      context: context,
      layout: TreeLayout.cascade,
      title: '选择配送区域（多选）',
      items: _regionItems,
      cascadeLevels: ['省份', '城市'],
      multiple: true,
      onConfirm: (values, datas) {
        setState(() => _selectedResult = '级联多选：${values.join("、")}');
      },
    );
  }

  /// 远程搜索 + 懒加载
  void _showRemoteSearch() async {
    await TreeSelect.show<String, void>(
      context: context,
      layout: TreeLayout.vertical,
      title: '搜索员工',
      subtitle: '远程搜索 + 懒加载',
      items: _deptItems,
      searchHint: '输入关键字搜索...',
      onLoadChildren: (parent) async {
        // 模拟懒加载
        await Future.delayed(const Duration(seconds: 1));
        return [
          TreeSelectItem<String, void>(
              label: '${parent.label} - 子项 A', value: '${parent.value}_a'),
          TreeSelectItem<String, void>(
              label: '${parent.label} - 子项 B', value: '${parent.value}_b'),
        ];
      },
      onSearch: (keyword) async {
        // 模拟远程搜索
        await Future.delayed(const Duration(milliseconds: 800));
        if (keyword.isEmpty) return [];
        return [
          TreeSearchResult(
            item: TreeSelectItem(
                label: '前端开发工程师', value: 'fe_dev'),
            path: ['技术部', '前端组'],
          ),
          TreeSearchResult(
            item: TreeSelectItem(
                label: '高级前端工程师', value: 'fe_senior'),
            path: ['技术部', '前端组'],
          ),
          TreeSearchResult(
            item: TreeSelectItem(
                label: '后端开发工程师', value: 'be_dev'),
            path: ['技术部', '后端组'],
          ),
        ].where((r) => r.item.label.contains(keyword)).toList();
      },
      onSelect: (value, data) {
        setState(() => _selectedResult = '搜索结果：$value');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TreeSelect 树形选择器'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 结果展示
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '选择结果',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedResult,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // ─── 竖向布局 ───
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '竖向缩进布局',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          _buildDemoButton(
            icon: Icons.account_tree,
            title: '竖向单选',
            subtitle: '本地树形数据，点击即选中',
            onTap: _showVerticalSingle,
          ),
          _buildDemoButton(
            icon: Icons.check_box,
            title: '竖向多选（父子联动）',
            subtitle: '选中父节点自动全选子节点',
            onTap: _showVerticalMulti,
          ),
          _buildDemoButton(
            icon: Icons.check_box_outline_blank,
            title: '竖向多选（父子独立）',
            subtitle: '父子选中状态不联动',
            onTap: _showVerticalMultiIndependent,
          ),

          const SizedBox(height: 20),

          // ─── 横向级联 ───
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '横向级联布局',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          _buildDemoButton(
            icon: Icons.view_column,
            title: '横向级联单选',
            subtitle: '三级联动：省 → 市 → 区',
            onTap: _showCascadeSingle,
          ),
          _buildDemoButton(
            icon: Icons.view_column_outlined,
            title: '横向级联多选',
            subtitle: '多选多个省份/城市',
            onTap: _showCascadeMulti,
          ),

          const SizedBox(height: 20),

          // ─── 远程搜索 ───
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '远程搜索 & 懒加载',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          _buildDemoButton(
            icon: Icons.cloud_download,
            title: '远程搜索 + 懒加载',
            subtitle: '异步搜索带面包屑路径，展开节点懒加载',
            onTap: _showRemoteSearch,
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}

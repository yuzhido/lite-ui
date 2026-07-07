import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';

/// 树形选择器完整使用示例
class TreeSelectExample extends StatefulWidget {
  const TreeSelectExample({super.key});

  @override
  State<TreeSelectExample> createState() => _TreeSelectExampleState();
}

class _TreeSelectExampleState extends State<TreeSelectExample> {
  String _selectedResult = '';

  // 模拟部门树形数据（3级）
  final List<TreeNode> _departmentTree = [
    TreeNode(
      id: 'dept_tech',
      label: '技术部',
      children: [
        TreeNode(
          id: 'tech_frontend',
          label: '前端开发组',
          children: [
            TreeNode(id: 'tech_flutter', label: 'Flutter工程师'),
            TreeNode(id: 'tech_react', label: 'React工程师'),
            TreeNode(id: 'tech_vue', label: 'Vue工程师'),
          ],
        ),
        TreeNode(
          id: 'tech_backend',
          label: '后端开发组',
          children: [
            TreeNode(id: 'tech_go', label: 'Go工程师'),
            TreeNode(id: 'tech_java', label: 'Java工程师'),
            TreeNode(id: 'tech_python', label: 'Python工程师'),
          ],
        ),
        TreeNode(
          id: 'tech_mobile',
          label: '移动端开发组',
          children: [
            TreeNode(id: 'tech_ios', label: 'iOS工程师'),
            TreeNode(id: 'tech_android', label: 'Android工程师'),
          ],
        ),
      ],
    ),
    TreeNode(
      id: 'dept_product',
      label: '产品部',
      children: [
        TreeNode(id: 'product_pm', label: '产品经理'),
        TreeNode(id: 'product_design', label: '产品设计'),
        TreeNode(id: 'product_ux', label: '用户体验研究'),
      ],
    ),
    TreeNode(
      id: 'dept_design',
      label: '设计部',
      children: [
        TreeNode(
          id: 'design_ui',
          label: 'UI设计组',
          children: [
            TreeNode(id: 'ui_web', label: 'Web UI设计师'),
            TreeNode(id: 'ui_app', label: 'App UI设计师'),
          ],
        ),
        TreeNode(id: 'design_ux', label: 'UX设计师'),
        TreeNode(id: 'design_motion', label: '动效设计师'),
      ],
    ),
    TreeNode(
      id: 'dept_market',
      label: '市场部',
      children: [
        TreeNode(id: 'market_online', label: '线上推广'),
        TreeNode(id: 'market_offline', label: '线下活动'),
        TreeNode(id: 'market_brand', label: '品牌营销'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TreeSelect 树形选择器'), backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0.5),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 结果显示卡片
          Card(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '选中结果',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 8),
                        Text(_selectedResult.isEmpty ? '暂无选择' : _selectedResult, style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 标题
          Text('基础用法', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // 示例 1：单选（父节点可选）
          _buildDemoCard(
            //
            context,
            num: '1',
            title: '单选模式（父节点可选）',
            subtitle: '箭头展开/折叠，点击文本区域选中（父节点也可选）',
            icon: Icons.radio_button_checked_rounded,
            onTap: _demoSingleSelect,
          ),

          // 示例 2：多选（父子联动）
          _buildDemoCard(
            //
            context,
            num: '2',
            title: '多选模式（父子联动）',
            subtitle: '选父节点自动全选子节点，半选状态可视化',
            icon: Icons.checklist_rounded,
            onTap: _demoMultiSelect,
          ),

          // 示例 3：带初始值
          _buildDemoCard(
            //
            context,
            num: '3',
            title: '预设选中值',
            subtitle: '打开时已有默认选中项',
            icon: Icons.star_rounded,
            onTap: _demoWithInitialValue,
          ),

          const SizedBox(height: 24),

          // 标题
          Text('高级用法', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // 示例 4：自定义标题
          _buildDemoCard(
            //
            context,
            num: '4',
            title: '自定义配置',
            subtitle: '自定义标题、搜索提示等参数',
            icon: Icons.settings_rounded,
            onTap: _demoCustomConfig,
          ),

          // 示例 5：深层嵌套
          _buildDemoCard(
            //
            context,
            num: '5',
            title: '多层级展开',
            subtitle: '支持无限层级嵌套，自动计算子节点数量',
            icon: Icons.account_tree_rounded,
            onTap: _demoDeepNesting,
          ),

          // 示例 6：懒加载
          _buildDemoCard(
            //
            context,
            num: '6',
            title: '懒加载模式',
            subtitle: '先加载父节点，点击展开时异步加载子节点',
            icon: Icons.cloud_download_rounded,
            onTap: _demoLazyLoad,
          ),

          const SizedBox(height: 16),

          // 使用说明
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, size: 20, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Text(
                        '使用提示',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.amber.shade900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem('• 左侧箭头点击展开/折叠，右侧文本区点击选中'),
                  _buildTipItem('• 父节点也可以被选中（单选直接返回，多选联动子节点）'),
                  _buildTipItem('• 多选时父节点显示三态：未选 ○ / 半选 ◑ / 全选 ●'),
                  _buildTipItem('• 搜索框输入关键字可过滤匹配的节点'),
                  _buildTipItem('• 右侧 badge 显示子节点总数（多选时显示已选/总数）'),
                  _buildTipItem('• 支持懒加载：展开时异步加载子节点，显示 loading 指示器'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoCard(BuildContext context, {required String num, required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            num,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Icon(icon, color: Theme.of(context).colorScheme.primary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
    );
  }

  // ─── Demo 方法 ─────────────────────────────────────────────

  /// 示例 1：单选模式
  void _demoSingleSelect() async {
    final result = await TreeSelectHelper.show(
      context: context,
      treeData: _departmentTree,
      title: '选择部门',
      searchHint: '搜索部门...',
      onSelect: (node) {
        debugPrint('选中节点: ${node.label}, ID: ${node.id}');
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedResult = '${result.label}\nID: ${result.id}';
      });
    }
  }

  /// 示例 2：多选模式
  void _demoMultiSelect() async {
    final result = await TreeSelectHelper.showMultiple(
      context: context,
      treeData: _departmentTree,
      title: '选择多个部门',
      searchHint: '搜索部门...',
      selectedIds: const {'tech_flutter', 'design_ui'},
      onConfirm: (nodes) {
        debugPrint('选中了 ${nodes.length} 个节点');
        for (final node in nodes) {
          debugPrint(' - ${node.label} (${node.id})');
        }
      },
    );

    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _selectedResult = '已选 ${result.length} 项:\n${result.map((n) => '• ${n.label}').join('\n')}';
      });
    }
  }

  /// 示例 3：带初始选中值
  void _demoWithInitialValue() async {
    final result = await TreeSelectHelper.show(
      context: context,
      treeData: _departmentTree,
      title: '当前所在部门',
      searchHint: '搜索...',
      selectedIds: const {'tech_flutter'},
      onSelect: (node) {
        debugPrint('切换部门: ${node.label}');
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedResult = '切换到: ${result.label}\nID: ${result.id}';
      });
    }
  }

  /// 示例 4：自定义配置
  void _demoCustomConfig() async {
    final result = await TreeSelectHelper.show(
      context: context,
      treeData: _departmentTree,
      title: '请选择目标部门',
      searchHint: '输入关键字筛选...',
      emptyText: '没有找到匹配的部门',
      showSearch: true,
      cancelLabel: '关闭',
      confirmLabel: '确认选择',
      onSelect: (node) {
        debugPrint('自定义配置 - 选中: ${node.label}');
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedResult = '[自定义配置]\n选中: ${result.label}';
      });
    }
  }

  /// 示例 5：深层嵌套测试
  void _demoDeepNesting() async {
    final result = await TreeSelectHelper.show(
      context: context,
      treeData: _departmentTree,
      title: '多层级选择',
      searchHint: '搜索...',
      onSelect: (node) {
        debugPrint('深层嵌套 - 选中: ${node.label}');
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedResult = '[多层级]\n选中: ${result.label}\nID: ${result.id}';
      });
    }
  }

  /// 示例 6：懒加载模式
  void _demoLazyLoad() async {
    // 懒加载数据源：只有父节点，子节点按需加载
    final lazyTree = [
      TreeNode(id: 'lazy_beijing', label: '北京总部'),
      TreeNode(id: 'lazy_shanghai', label: '上海分公司'),
      TreeNode(id: 'lazy_shenzhen', label: '深圳分公司'),
      TreeNode(id: 'lazy_chengdu', label: '成都分公司'),
      TreeNode(id: 'lazy_hangzhou', label: '杭州分公司'),
    ];

    final result = await TreeSelectHelper.show(
      context: context,
      treeData: lazyTree,
      title: '选择办公地点（懒加载）',
      searchHint: '搜索办公地点...',
      onLoadChildren: (parent) async {
        // 模拟网络请求延迟
        await Future.delayed(const Duration(milliseconds: 800));
        debugPrint('懒加载: 正在加载 ${parent.label} 的子节点...');

        // 根据父节点返回不同的子节点
        switch (parent.id) {
          case 'lazy_beijing':
            return [
              TreeNode(id: 'bj_tech', label: '技术部', isLeaf: true),
              TreeNode(id: 'bj_product', label: '产品部', isLeaf: true),
              TreeNode(id: 'bj_hr', label: '人力资源部', isLeaf: true),
              TreeNode(id: 'bj_finance', label: '财务部', isLeaf: true),
            ];
          case 'lazy_shanghai':
            return [
              TreeNode(id: 'sh_sales', label: '销售部', isLeaf: true),
              TreeNode(id: 'sh_market', label: '市场部', isLeaf: true),
              TreeNode(id: 'sh_ops', label: '运营部', isLeaf: true),
            ];
          case 'lazy_shenzhen':
            return [TreeNode(id: 'sz_rd', label: '研发中心', isLeaf: true), TreeNode(id: 'sz_qa', label: '质量部', isLeaf: true)];
          case 'lazy_chengdu':
            return [TreeNode(id: 'cd_support', label: '客户支持', isLeaf: true), TreeNode(id: 'cd_training', label: '培训中心', isLeaf: true)];
          case 'lazy_hangzhou':
            return [
              TreeNode(id: 'hz_ecommerce', label: '电商事业部', isLeaf: true),
              TreeNode(id: 'hz_logistics', label: '物流部', isLeaf: true),
              TreeNode(id: 'hz_cloud', label: '云计算部', isLeaf: true),
            ];
          default:
            return [];
        }
      },
      onSelect: (node) {
        debugPrint('懒加载 - 选中: ${node.label}');
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedResult = '[懒加载]\n选中: ${result.label}\nID: ${result.id}';
      });
    }
  }
}

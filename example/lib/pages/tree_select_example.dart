import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';

class TreeSelectExamplePage extends StatefulWidget {
  const TreeSelectExamplePage({super.key});
  @override
  State<TreeSelectExamplePage> createState() => _TreeSelectExamplePageState();
}

class _TreeSelectExamplePageState extends State<TreeSelectExamplePage> {
  // ── 单选结果展示 ──
  String _singleResult1 = '未选择';
  String? _singleSelectedId1;
  String _singleResult2 = '未选择';
  String? _singleSelectedId2;

  // ── 多选结果展示 ──
  String _multiResult1 = '未选择';
  List<String> _multiSelectedIds1 = [];
  String _multiResult2 = '未选择';
  List<String> _multiSelectedIds2 = [];

  // ── 懒加载结果展示 ──
  String _lazyResult1 = '未选择';
  String? _lazySelectedId1;
  String _lazyResult2 = '未选择';
  List<String> _lazySelectedIds2 = [];

  // ── 模拟树数据 ──
  List<TreeNode<String>> _buildTreeData() {
    return [
      TreeNode<String>(
        id: '1',
        label: '技术中心',
        children: [
          TreeNode<String>(
            id: '1-1',
            label: '前端组',
            children: [
              TreeNode<String>(id: '1-1-1', label: '张三', isLeaf: true),
              TreeNode<String>(id: '1-1-2', label: '李四', isLeaf: true),
              TreeNode<String>(id: '1-1-3', label: '王五', isLeaf: true),
            ],
          ),
          TreeNode<String>(
            id: '1-2',
            label: '后端组',
            children: [
              TreeNode<String>(id: '1-2-1', label: '赵六', isLeaf: true),
              TreeNode<String>(id: '1-2-2', label: '孙七', isLeaf: true),
            ],
          ),
          TreeNode<String>(
            id: '1-3',
            label: '测试组',
            children: [
              TreeNode<String>(id: '1-3-1', label: '周八', isLeaf: true),
              TreeNode<String>(id: '1-3-2', label: '吴九', isLeaf: true),
            ],
          ),
        ],
      ),
      TreeNode<String>(
        id: '2',
        label: '产品中心',
        children: [
          TreeNode<String>(
            id: '2-1',
            label: '产品设计',
            children: [
              TreeNode<String>(id: '2-1-1', label: '郑十', isLeaf: true),
              TreeNode<String>(id: '2-1-2', label: '刘一', isLeaf: true),
            ],
          ),
          TreeNode<String>(
            id: '2-2',
            label: '产品运营',
            children: [
              TreeNode<String>(id: '2-2-1', label: '陈二', isLeaf: true),
            ],
          ),
        ],
      ),
      TreeNode<String>(
        id: '3',
        label: '市场中心',
        children: [
          TreeNode<String>(id: '3-1', label: '品牌推广', isLeaf: true),
          TreeNode<String>(id: '3-2', label: '渠道合作', isLeaf: true),
        ],
      ),
    ];
  }

  // ── 懒加载树数据（初始只有根节点）──
  List<TreeNode<String>> _buildLazyTreeData() {
    return [
      TreeNode<String>(id: 'L1', label: '浙江省', isLeaf: false),
      TreeNode<String>(id: 'L2', label: '江苏省', isLeaf: false),
      TreeNode<String>(id: 'L3', label: '广东省', isLeaf: false),
    ];
  }

  // ── 模拟懒加载回调 ──
  Future<List<TreeNode<String>>> _loadChildren(TreeNode<String> parent) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (parent.id == 'L1') {
      return [
        TreeNode<String>(id: 'L1-1', label: '杭州市', parentId: 'L1', isLeaf: false),
        TreeNode<String>(id: 'L1-2', label: '宁波市', parentId: 'L1', isLeaf: false),
        TreeNode<String>(id: 'L1-3', label: '温州市', parentId: 'L1', isLeaf: true),
      ];
    } else if (parent.id == 'L2') {
      return [
        TreeNode<String>(id: 'L2-1', label: '南京市', parentId: 'L2', isLeaf: false),
        TreeNode<String>(id: 'L2-2', label: '苏州市', parentId: 'L2', isLeaf: false),
      ];
    } else if (parent.id == 'L3') {
      return [
        TreeNode<String>(id: 'L3-1', label: '广州市', parentId: 'L3', isLeaf: false),
        TreeNode<String>(id: 'L3-2', label: '深圳市', parentId: 'L3', isLeaf: true),
      ];
    } else if (parent.id == 'L1-1') {
      return [
        TreeNode<String>(id: 'L1-1-1', label: '西湖区', parentId: 'L1-1', isLeaf: true),
        TreeNode<String>(id: 'L1-1-2', label: '滨江区', parentId: 'L1-1', isLeaf: true),
      ];
    } else if (parent.id == 'L1-2') {
      return [
        TreeNode<String>(id: 'L1-2-1', label: '海曙区', parentId: 'L1-2', isLeaf: true),
        TreeNode<String>(id: 'L1-2-2', label: '鄞州区', parentId: 'L1-2', isLeaf: true),
      ];
    } else if (parent.id == 'L2-1') {
      return [
        TreeNode<String>(id: 'L2-1-1', label: '玄武区', parentId: 'L2-1', isLeaf: true),
        TreeNode<String>(id: 'L2-1-2', label: '鼓楼区', parentId: 'L2-1', isLeaf: true),
      ];
    } else if (parent.id == 'L2-2') {
      return [
        TreeNode<String>(id: 'L2-2-1', label: '姑苏区', parentId: 'L2-2', isLeaf: true),
        TreeNode<String>(id: 'L2-2-2', label: '吴中区', parentId: 'L2-2', isLeaf: true),
      ];
    } else if (parent.id == 'L3-1') {
      return [
        TreeNode<String>(id: 'L3-1-1', label: '天河区', parentId: 'L3-1', isLeaf: true),
        TreeNode<String>(id: 'L3-1-2', label: '越秀区', parentId: 'L3-1', isLeaf: true),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TreeSelect 树形选择器')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 单选 ──
          _buildSectionTitle('一、单选模式'),
          _buildCard(
            title: '1. 父节点不可选（默认）',
            subtitle: '点击父节点仅展开/折叠，只能选叶子节点',
            result: _singleResult1,
            onTap: () async {
              final result = await TreeSelectHelper.show<String>(
                context: context,
                treeData: _buildTreeData(),
                title: '选择人员',
                parentSelectable: false,
                selectedId: _singleSelectedId1,
              );
              if (result != null) {
                setState(() {
                  _singleSelectedId1 = result.id;
                  _singleResult1 = '${result.label}（id: ${result.id}）';
                });
              }
            },
          ),
          const SizedBox(height: 12),
          _buildCard(
            title: '2. 父节点可选',
            subtitle: '点击父节点可直接选中该节点',
            result: _singleResult2,
            onTap: () async {
              final result = await TreeSelectHelper.show<String>(
                context: context,
                treeData: _buildTreeData(),
                title: '选择部门/人员',
                parentSelectable: true,
                selectedId: _singleSelectedId2,
              );
              if (result != null) {
                setState(() {
                  _singleSelectedId2 = result.id;
                  _singleResult2 = '${result.label}（id: ${result.id}）';
                });
              }
            },
          ),
          const Divider(height: 32),

          // ── 多选 ──
          _buildSectionTitle('二、多选模式'),
          _buildCard(
            title: '3. 父节点不可选（默认）',
            subtitle: '只能选叶子节点，父节点自动联动',
            result: _multiResult1,
            onTap: () async {
              final result = await TreeSelectHelper.showMultiple<String>(
                context: context,
                treeData: _buildTreeData(),
                title: '选择人员（多选）',
                parentSelectable: false,
                selectedIds: _multiSelectedIds1,
              );
              if (result != null && result.isNotEmpty) {
                setState(() {
                  _multiSelectedIds1 = result.map((e) => e.id).toList();
                  _multiResult1 = result.map((e) => e.label).join('、');
                });
              }
            },
          ),
          const SizedBox(height: 12),
          _buildCard(
            title: '4. 父节点可选',
            subtitle: '点击父节点可联动选中父+子节点',
            result: _multiResult2,
            onTap: () async {
              final result = await TreeSelectHelper.showMultiple<String>(
                context: context,
                treeData: _buildTreeData(),
                title: '选择部门/人员（多选）',
                parentSelectable: true,
                selectedIds: _multiSelectedIds2,
              );
              if (result != null && result.isNotEmpty) {
                setState(() {
                  _multiSelectedIds2 = result.map((e) => e.id).toList();
                  _multiResult2 = result.map((e) => e.label).join('、');
                });
              }
            },
          ),
          const Divider(height: 32),

          // ── 懒加载 ──
          _buildSectionTitle('三、懒加载模式'),
          _buildCard(
            title: '5. 懒加载 + 父节点不可选',
            subtitle: '逐层加载子节点，只能选叶子',
            result: _lazyResult1,
            onTap: () async {
              final result = await TreeSelectHelper.show<String>(
                context: context,
                treeData: _buildLazyTreeData(),
                title: '选择地区',
                parentSelectable: false,
                selectedId: _lazySelectedId1,
                onLoadChildren: _loadChildren,
              );
              if (result != null) {
                setState(() {
                  _lazySelectedId1 = result.id;
                  _lazyResult1 = '${result.label}（id: ${result.id}）';
                });
              }
            },
          ),
          const SizedBox(height: 12),
          _buildCard(
            title: '6. 懒加载 + 父节点可选',
            subtitle: '逐层加载子节点，父节点可直接选中',
            result: _lazyResult2,
            onTap: () async {
              final result = await TreeSelectHelper.showMultiple<String>(
                context: context,
                treeData: _buildLazyTreeData(),
                title: '选择地区（多选）',
                parentSelectable: true,
                selectedIds: _lazySelectedIds2,
                onLoadChildren: _loadChildren,
              );
              if (result != null && result.isNotEmpty) {
                setState(() {
                  _lazySelectedIds2 = result.map((e) => e.id).toList();
                  _lazyResult2 = result.map((e) => e.label).join('、');
                });
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required String result,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '已选：$result',
                  style: TextStyle(
                    fontSize: 14,
                    color: result == '未选择' ? Colors.grey[500] : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

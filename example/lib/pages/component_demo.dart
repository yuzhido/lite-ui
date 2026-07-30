import 'package:example/mock/area_list.dart';
import 'package:example/mock/brand_list.dart';
import 'package:example/mock/category_list.dart';
import 'package:example/mock/product_list.dart';
import 'package:example/mock/spec_list.dart';
import 'package:example/mock/unit_list.dart';
import 'package:example/mock/user_list.dart';
import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';

class ComponentDemoPage extends StatefulWidget {
  const ComponentDemoPage({super.key});

  @override
  State<ComponentDemoPage> createState() => _ComponentDemoPageState();
}

class _ComponentDemoPageState extends State<ComponentDemoPage> {
  final _formKey = GlobalKey<FormState>();

  // 远程搜索单选 — 城市
  int? _citySingle;
  SelectItem<int, AreaInfo>? _citySingleItem;

  // 远程搜索多选 — 城市
  Set<int> _citiesMulti = {};

  // 同步单选 — 商品分类
  int? _category;
  SelectItem<int, CategoryInfo>? _categoryItem;

  // 远程搜索单选 — 品牌
  int? _brand;
  SelectItem<int, BrandInfo>? _brandItem;

  // 同步多选 — 规格
  Set<int> _specs = {};

  // 同步单选 — 计量单位
  int? _unit;
  SelectItem<int, UnitInfo>? _unitItem;

  // 远程搜索单选 — 用户
  int? _user;
  SelectItem<int, UserInfo>? _userItem;

  // 远程搜索多选 — 商品
  Set<int> _products = {};

  @override
  void initState() {
    super.initState();
    _citiesMulti = {1918475623301, 1918475623303};
  }

  void _onReset() {
    _formKey.currentState?.reset();
    setState(() {
      _citySingle = null;
      _citySingleItem = null;
      _citiesMulti = {};
      _category = null;
      _categoryItem = null;
      _brand = null;
      _brandItem = null;
      _specs = {};
      _unit = null;
      _unitItem = null;
      _user = null;
      _userItem = null;
      _products = {};
    });
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('表单验证通过')));
    }
  }

  /// 通用新增弹窗
  Future<String?> _showAddDialog(String label, String keyword) async {
    final controller = TextEditingController(text: keyword);
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('新增$label'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: '请输入$label名称'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(controller.text), child: const Text('确定')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DropdownChoose 使用示例')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 远程搜索 ──
              const Text(' 远程搜索模式', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 1),

              const Text('远程搜索 + 单选 + 新增', style: TextStyle(fontSize: 13, color: Colors.grey)),
              DropdownChoose<int, AreaInfo>(
                required: true,
                formLabel: '城市',
                value: _citySingle,
                selectedItems: _citySingleItem != null ? [_citySingleItem!] : null,
                type: SelectModalType.remote,
                prefixIcon: const Icon(Icons.location_on),
                showAdd: true,
                addLabel: '新增城市',
                onClear: () => debugPrint('城市已清除'),
                onAdd: (keyword) async {
                  final result = await _showAddDialog('城市', keyword);
                  if (result != null && result.isNotEmpty) {
                    addMockArea(name: result);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已新增城市: $result')));
                    }
                  }
                },
                onSaved: (v) => debugPrint('城市: $v'),
                onSelect: (value, data) {
                  setState(() {
                    _citySingle = value;
                    _citySingleItem = SelectItem(label: data?.name ?? '', value: value, data: data);
                  });
                },
                onRemoteSearch: (keyword) async => getAsyncData(keyword: keyword),
              ),

              const Text('远程搜索 + 多选 + tags 模式', style: TextStyle(fontSize: 13, color: Colors.grey)),
              DropdownChoose<int, AreaInfo>(
                required: true,
                formLabel: '配送城市',
                multiple: true,
                type: SelectModalType.remote,
                displayMode: DisplayMode.tags,
                selectedValues: _citiesMulti,
                maxShowTags: 2,
                onSaved: (v) => debugPrint('配送城市: $v'),
                onConfirm: (values, datas, items) {
                  setState(() => _citiesMulti = values.toSet());
                },
                onRemoteSearch: (keyword) async => getAsyncData(keyword: keyword),
              ),

              const Text('远程搜索 + 单选', style: TextStyle(fontSize: 13, color: Colors.grey)),
              DropdownChoose<int, BrandInfo>(
                required: true,
                formLabel: '品牌',
                value: _brand,
                selectedItems: _brandItem != null ? [_brandItem!] : null,
                type: SelectModalType.remote,
                prefixIcon: const Icon(Icons.bookmark_outline),
                onClear: () => debugPrint('品牌已清除'),
                onSaved: (v) => debugPrint('品牌: $v'),
                onSelect: (value, data) {
                  setState(() {
                    _brand = value;
                    _brandItem = SelectItem(label: data?.name ?? '', value: value, data: data);
                  });
                },
                onRemoteSearch: (keyword) async => getBrandAsyncData(keyword: keyword),
              ),

              const Text('远程搜索 + 单选', style: TextStyle(fontSize: 13, color: Colors.grey)),
              DropdownChoose<int, UserInfo>(
                formLabel: '负责人',
                value: _user,
                selectedItems: _userItem != null ? [_userItem!] : null,
                type: SelectModalType.remote,
                prefixIcon: const Icon(Icons.person_outline),
                hintText: '搜索用户名或部门',
                onClear: () => debugPrint('负责人已清除'),
                onSaved: (v) => debugPrint('负责人: $v'),
                onSelect: (value, data) {
                  setState(() {
                    _user = value;
                    _userItem = SelectItem(label: data?.name ?? '', value: value, data: data);
                  });
                },
                onRemoteSearch: (keyword) async => getUserAsyncData(keyword: keyword),
              ),

              const Text('远程搜索 + 多选 + compact 模式', style: TextStyle(fontSize: 13, color: Colors.grey)),
              DropdownChoose<int, ProductInfo>(
                required: true,
                formLabel: '商品',
                multiple: true,
                type: SelectModalType.remote,
                displayMode: DisplayMode.compact,
                maxShowTags: 3,
                selectedValues: _products,
                prefixIcon: const Icon(Icons.shopping_cart_outlined),
                hintText: '搜索商品名称',
                onSaved: (v) => debugPrint('商品: $v'),
                onConfirm: (values, datas, items) {
                  setState(() => _products = values.toSet());
                },
                onRemoteSearch: (keyword) async => getProductAsyncData(keyword: keyword),
              ),

              const SizedBox(height: 8),
              // ── 同步数据 ──
              const Text(' 同步数据模式', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 1),

              const Text('同步数据 + 单选', style: TextStyle(fontSize: 13, color: Colors.grey)),
              DropdownChoose<int, CategoryInfo>(
                required: true,
                formLabel: '商品分类',
                value: _category,
                selectedItems: _categoryItem != null ? [_categoryItem!] : null,
                prefixIcon: const Icon(Icons.category_outlined),
                onClear: () => debugPrint('分类已清除'),
                onSaved: (v) => debugPrint('分类: $v'),
                onSelect: (value, data) {
                  setState(() {
                    _category = value;
                    _categoryItem = SelectItem(label: data?.name ?? '', value: value, data: data);
                  });
                },
                items: getCategorySyncData(),
              ),

              const Text('同步数据 + 多选 + tags 模式', style: TextStyle(fontSize: 13, color: Colors.grey)),
              DropdownChoose<int, SpecInfo>(
                required: true,
                formLabel: '规格',
                multiple: true,
                displayMode: DisplayMode.tags,
                selectedValues: _specs,
                maxShowTags: 3,
                prefixIcon: const Icon(Icons.straighten),
                onClear: () => debugPrint('规格已清除'),
                onSaved: (v) => debugPrint('规格: $v'),
                onConfirm: (values, datas, items) {
                  setState(() => _specs = values.toSet());
                },
                items: getSpecSyncData(),
              ),

              const Text('同步数据 + 单选', style: TextStyle(fontSize: 13, color: Colors.grey)),
              DropdownChoose<int, UnitInfo>(
                formLabel: '计量单位',
                value: _unit,
                selectedItems: _unitItem != null ? [_unitItem!] : null,
                prefixIcon: const Icon(Icons.balance),
                hintText: '请选择单位',
                onClear: () => debugPrint('单位已清除'),
                onSaved: (v) => debugPrint('单位: $v'),
                onSelect: (value, data) {
                  setState(() {
                    _unit = value;
                    _unitItem = SelectItem(label: data?.name ?? '', value: value, data: data);
                  });
                },
                items: getUnitSyncData(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          spacing: 16,
          children: [
            Expanded(
              child: OutlinedButton(onPressed: _onReset, child: const Text('重置')),
            ),
            Expanded(
              child: ElevatedButton(onPressed: _onSubmit, child: const Text('提交')),
            ),
          ],
        ),
      ),
    );
  }
}

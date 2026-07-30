import 'package:example/mock/area_list.dart';
import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';

/// InputText 校验规则与输入类型使用示例
class ComponentDemoPage extends StatefulWidget {
  const ComponentDemoPage({super.key});

  @override
  State<ComponentDemoPage> createState() => _ComponentDemoPageState();
}

class _ComponentDemoPageState extends State<ComponentDemoPage> {
  final _formKey = GlobalKey<FormState>();

  // 选择型组件状态
  String? _gender;
  String? _region;
  int? _singleCity;
  SelectItem<int, AreaInfo>? _singleCityItem;
  Set<int> _remoteCities = {1918475623301, 1918475623303, 1918475623307, 1918475623312, 1918475623320};
  List<SelectItem<int, AreaInfo>> _remoteCitiesItems = [
    SelectItem(
      label: '太原市',
      value: 1918475623307,
      data: AreaInfo(id: 1918475623307, name: '太原市', code: '140100', description: '山西省省会'),
    ),
    SelectItem(
      label: '大同市',
      value: 1918475623308,
      data: AreaInfo(id: 1918475623308, name: '大同市', code: '140200', description: '山西省'),
    ),
    SelectItem(
      label: '呼和浩特市',
      value: 1918475623309,
      data: AreaInfo(id: 1918475623309, name: '呼和浩特市', code: '150100', description: '内蒙古自治区首府'),
    ),
  ];
  Set<String> _cities = {};
  Set<String> _citiesTags = {};
  Set<String> _citiesCompact = {};

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('表单验证通过')));
    }
  }

  @override
  void initState() {
    super.initState();

    _remoteCities.addAll([1918475623301, 1918475623303, 1918475623307, 1918475623312, 1918475623320]);
  }

  void _onReset() {
    _formKey.currentState?.reset();
    setState(() {
      _gender = null;
      _region = null;
      _singleCity = null;
      _singleCityItem = null;
      _remoteCities = {};
      _remoteCitiesItems = [];
      _cities = {};
      _citiesTags = {};
      _citiesCompact = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InputText 校验规则示例')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(' 基础校验', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 1),
              // 0-1. 测试远程搜索 + 单选 + 新增功能
              DropdownChoose<int, AreaInfo>(
                required: true,
                formLabel: '城市单选',
                value: _singleCity,
                selectedItems: _singleCityItem != null ? [_singleCityItem!] : null,
                type: SelectModalType.remote,
                prefixIcon: const Icon(Icons.location_on),
                showAdd: true,
                addLabel: '新增城市',
                onAdd: (keyword) async {
                  final controller = TextEditingController(text: keyword);
                  final result = await showDialog<String>(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: const Text('新增城市'),
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(hintText: '请输入城市名称'),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.of(ctx).pop(controller.text), child: const Text('确定')),
                        ],
                      );
                    },
                  );
                  if (result != null && result.isNotEmpty) {
                    addMockArea(name: result);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已新增城市: $result，列表已自动刷新')));
                    }
                  }
                },
                onSaved: (v) => debugPrint('城市(单选): $v'),
                onSelect: (value, data) {
                  setState(() {
                    _singleCity = value;
                    _singleCityItem = SelectItem(label: data?.name ?? '', value: value, data: data);
                  });
                },
                onRemoteSearch: (keyword) async {
                  return getAsyncData(keyword: keyword);
                },
              ),
              // 0-2. 测试远程搜索模式（不传 items，通过 onRemoteSearch 异步获取）
              DropdownChoose<int, AreaInfo>(
                required: true,
                formLabel: '城市',
                multiple: true,
                selectedValues: _remoteCities,
                // selectedItems: _remoteCitiesItems,
                type: SelectModalType.remote,
                displayMode: DisplayMode.tags,
                showAdd: true,
                maxCount: 5,
                maxShowTags: 1,
                addLabel: '新增城市',
                onRemoteSearch: (keyword) async {
                  return getAsyncData(keyword: keyword);
                },
                // items: [],
                onAdd: (keyword) async {
                  final controller = TextEditingController(text: keyword);
                  final result = await showDialog<String>(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: const Text('新增城市'),
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(hintText: '请输入城市名称'),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.of(ctx).pop(controller.text), child: const Text('确定')),
                        ],
                      );
                    },
                  );
                  if (result != null && result.isNotEmpty) {
                    addMockArea(name: result);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已新增城市: $result，列表已自动刷新')));
                    }
                  }
                },
                onSaved: (v) => debugPrint('城市: $v'),
                onConfirm: (List<int> values, List<AreaInfo?> datas, List<SelectItem<int, AreaInfo>> items) {
                  print('多选最后结果开始33333333333333');
                  print(values);
                  print(datas);
                  print('多选最后结果结束33333333333333');
                  setState(() {
                    _remoteCities = values.toSet();
                    _remoteCitiesItems = items;
                  });
                },
              ),
              // 1. 仅必填
              InputText(
                required: true,
                formLabel: '姓名',
                prefixIcon: const Icon(Icons.person, color: Colors.blue),
                onSaved: (v) => debugPrint('姓名: $v'),
              ),

              // 2. 必填 + 数字格式
              InputText(
                required: true,
                validRuleType: ValidRuleType.numeric,
                formLabel: '年龄',
                inputType: InputType.integer,
                prefixIcon: const Icon(Icons.numbers, color: Colors.green),
                onSaved: (v) => debugPrint('年龄: $v'),
              ),

              // 3. 必填 + 密码规则（6位+大写字母）
              InputText(
                required: true,
                validRuleType: ValidRuleType.password,
                formLabel: '密码',
                password: true,
                prefixIcon: const Icon(Icons.lock, color: Colors.red),
                onSaved: (v) => debugPrint('密码: $v'),
              ),

              const SizedBox(height: 8),
              const Text(' 输入类型限制', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 1),

              // 4. 只能输入小数
              InputText(
                required: true,
                validRuleType: ValidRuleType.decimal,
                formLabel: '价格',
                inputType: InputType.decimal,
                hintText: '如 99.99',
                prefixIcon: const Icon(Icons.attach_money, color: Colors.orange),
                onSaved: (v) => debugPrint('价格: $v'),
              ),

              // 5. 只能输入中文
              InputText(
                required: true,
                validRuleType: ValidRuleType.chineseName,
                formLabel: '中文名',
                inputType: InputType.chinese,
                prefixIcon: const Icon(Icons.language, color: Colors.purple),
                onSaved: (v) => debugPrint('中文名: $v'),
              ),

              // 6. 只能输入英文
              InputText(
                required: true,
                formLabel: '英文名',
                inputType: InputType.english,
                prefixIcon: const Icon(Icons.translate, color: Colors.teal),
                onSaved: (v) => debugPrint('英文名: $v'),
              ),

              // 7. 单字符（验证码）
              InputText(
                required: true,
                formLabel: '验证码',
                inputType: InputType.char,
                maxLen: 6,
                minLen: 6,
                hintText: '6位验证码',
                prefixIcon: const Icon(Icons.security, color: Colors.indigo),
                onSaved: (v) => debugPrint('验证码: $v'),
              ),

              const SizedBox(height: 8),
              const Text('📱 格式校验', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 1),

              // 8. 手机号
              InputText(
                required: true,
                validRuleType: ValidRuleType.phone,
                formLabel: '手机号',
                inputType: InputType.integer,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone, color: Colors.cyan),
                onSaved: (v) => debugPrint('手机号: $v'),
              ),

              // 9. 邮箱
              InputText(
                required: true,
                validRuleType: ValidRuleType.email,
                formLabel: '邮箱',
                inputType: InputType.text,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email, color: Colors.deepPurple),
                onSaved: (v) => debugPrint('邮箱: $v'),
              ),

              const SizedBox(height: 8),
              const Text('🎯 选择型组件', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 1),

              // 10. ActionSheet
              ActionSheet<String, int>(
                required: true,
                formLabel: '性别',
                title: '请选择性别',
                value: _gender,
                onSaved: (v) => debugPrint('性别: $v'),
                onSelect: (value, data) {
                  setState(() => _gender = value);
                },
                items: const [
                  SelectItem(label: '男', value: '1', data: 1, icon: Icon(Icons.male)),
                  SelectItem(label: '女', value: '2', data: 2, icon: Icon(Icons.female)),
                ],
              ),

              // 11. DropdownChoose 单选
              DropdownChoose<String, int>(
                required: true,
                formLabel: '所在区域',
                value: _region,
                onSaved: (v) => debugPrint('区域: $v'),
                selectedItems: const [
                  SelectItem(label: '北京', value: 'bj', data: 1),
                  SelectItem(label: '上海', value: 'sh', data: 2),
                  SelectItem(label: '广州', value: 'gz', data: 3),
                ],
                onSelect: (value, data) {
                  setState(() => _region = value);
                },
                items: const [
                  SelectItem(label: '北京', value: 'bj', data: 1),
                  SelectItem(label: '上海', value: 'sh', data: 2),
                  SelectItem(label: '广州', value: 'gz', data: 3),
                  SelectItem(label: '深圳', value: 'sz', data: 4),
                ],
              ),

              // 12. DropdownChoose 多选（text 模式）
              DropdownChoose<String, int>(
                required: true,
                formLabel: '城市',
                multiple: true,
                // selectedValues: _cities,
                onSaved: (v) => debugPrint('城市: $v'),
                selectedItems: const [
                  SelectItem(label: '北京', value: 'bj', data: 1),
                  SelectItem(label: '上海', value: 'sh', data: 2),
                ],
                onConfirm: (values, datas, _) {
                  setState(() => _cities = values.toSet());
                },
                items: const [
                  SelectItem(label: '北京', value: 'bj', data: 1),
                  SelectItem(label: '上海', value: 'sh', data: 2),
                  SelectItem(label: '广州', value: 'gz', data: 3),
                  SelectItem(label: '深圳', value: 'sz', data: 4),
                  SelectItem(label: '杭州', value: 'hz', data: 5),
                  SelectItem(label: '广西', value: 'gx', data: 6),
                  SelectItem(label: '成都', value: 'cd', data: 7),
                  SelectItem(label: '西藏', value: 'xz', data: 8),
                  SelectItem(label: '云南', value: 'yn', data: 9),
                  SelectItem(label: '福建', value: 'fj', data: 10),
                  SelectItem(label: '贵州', value: 'gz2', data: 11),
                ],
              ),

              // 13. DropdownChoose 多选（tags 模式）
              DropdownChoose<String, int>(
                required: true,
                formLabel: '城市',
                multiple: true,
                displayMode: DisplayMode.tags,
                selectedValues: _citiesTags,
                onSaved: (v) => debugPrint('城市tags: $v'),
                onConfirm: (values, datas, _) {
                  setState(() => _citiesTags = values.toSet());
                },
                items: const [
                  SelectItem(label: '北京', value: 'bj', data: 1),
                  SelectItem(label: '上海', value: 'sh', data: 2),
                  SelectItem(label: '广州', value: 'gz', data: 3),
                  SelectItem(label: '深圳', value: 'sz', data: 4),
                  SelectItem(label: '杭州', value: 'hz', data: 5),
                ],
              ),

              // 14. DropdownChoose 多选（compact 模式）
              DropdownChoose<String, int>(
                required: true,
                formLabel: '城市',
                multiple: true,
                displayMode: DisplayMode.compact,
                maxShowTags: 2,
                selectedValues: _citiesCompact,
                onSaved: (v) => debugPrint('城市compact: $v'),
                onConfirm: (values, datas, _) {
                  setState(() => _citiesCompact = values.toSet());
                },
                items: const [
                  SelectItem(label: '北京', value: 'bj', data: 1),
                  SelectItem(label: '上海', value: 'sh', data: 2),
                  SelectItem(label: '广州', value: 'gz', data: 3),
                  SelectItem(label: '深圳', value: 'sz', data: 4),
                  SelectItem(label: '杭州', value: 'hz', data: 5),
                  SelectItem(label: '广西', value: 'gx', data: 6),
                  SelectItem(label: '成都', value: 'cd', data: 7),
                  SelectItem(label: '西藏', value: 'xz', data: 8),
                ],
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

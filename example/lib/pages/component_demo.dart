import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';

class ComponentDemoPage extends StatefulWidget {
  const ComponentDemoPage({super.key});
  @override
  State<ComponentDemoPage> createState() => _ComponentDemoPageState();
}

class _ComponentDemoPageState extends State<ComponentDemoPage> {
  final _formKey = GlobalKey<FormState>();
  String? _gender;
  String? _region;

  /// 各字段验证结果：字段名 -> 是否通过
  Map<String, bool> _validationResults = {};

  /// 是否已执行过验证
  bool _hasValidated = false;

  /// 各字段当前值（通过 onSaved 收集）
  final Map<String, String?> _fieldValues = {};

  /// 表单字段配置：[字段名, 是否必填]
  static const _fields = [
    ['姓名', true],
    ['年龄', false],
    ['家庭住址', false],
    ['性别', true],
    ['所在区域', true],
  ];

  void _onSubmit() {
    // 先收集各字段值
    _formKey.currentState?.save();
    final isValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _hasValidated = true;
      final results = <String, bool>{};
      for (final field in _fields) {
        final name = field[0] as String;
        final required = field[1] as bool;
        final value = _fieldValues[name];
        final hasValue = value != null && value.isNotEmpty;
        // 必填项无值则失败，非必填始终通过
        results[name] = required ? hasValue : true;
      }
      _validationResults = results;
    });

    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('表单验证通过')));
    }
  }

  void _onReset() {
    _formKey.currentState?.reset();
    setState(() {
      _gender = null;
      _region = null;
      _fieldValues.clear();
      _validationResults = {};
      _hasValidated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导航栏标题')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            spacing: 10,
            children: [
              InputText(
                required: true,
                formLabel: '姓名',
                prefixIcon: Icon(Icons.person, color: Colors.green),
                onSaved: (v) => _fieldValues['姓名'] = v,
              ),
              InputText(
                required: true,
                formLabel: '年龄',
                prefixIcon: Icon(Icons.lock, color: Colors.red),
                onSaved: (v) => _fieldValues['年龄'] = v,
              ),
              InputText(
                formLabel: '家庭住址',
                prefixIcon: Icon(Icons.home, color: Colors.blue),
                prefixIconColor: Colors.blue,
                onSaved: (v) => _fieldValues['家庭住址'] = v,
              ),
              ActionSheet<String, int>(
                required: true,
                formLabel: '性别',
                title: '请选择性别',
                description: '请选择性别',
                hintText: '请选择',
                value: _gender,
                onSaved: (v) => _fieldValues['性别'] = v,
                onSelect: (value, data) {
                  setState(() => _gender = value);
                },
                items: [
                  SelectItem(label: '男', value: '1', data: 1, icon: Icon(Icons.male)),
                  SelectItem(label: '女', value: '2', data: 2, icon: Icon(Icons.female)),
                ],
              ),
              DropdownChoose<String, int>(
                required: true,
                formLabel: '所在区域',
                hintText: '请选择区域',
                value: _region,
                onSaved: (v) => _fieldValues['所在区域'] = v,
                onSelect: (value, data) {
                  setState(() => _region = value);
                },
                items: [
                  SelectItem(label: '北京', value: 'bj', data: 1),
                  SelectItem(label: '上海', value: 'sh', data: 2),
                  SelectItem(label: '广州', value: 'gz', data: 3),
                  SelectItem(label: '深圳', value: 'sz', data: 4),
                ],
              ),

              // 验证结果
              if (_hasValidated) ...[
                const Divider(),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('验证结果', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                ..._fields.map((field) {
                  final name = field[0] as String;
                  final passed = _validationResults[name] ?? true;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: passed ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: passed ? Colors.green.shade200 : Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(passed ? Icons.check_circle : Icons.cancel, color: passed ? Colors.green : Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Text('$name：${passed ? '验证通过' : '验证失败'}', style: TextStyle(color: passed ? Colors.green.shade800 : Colors.red.shade800, fontSize: 14)),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(15),
        child: Row(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: OutlinedButton(onPressed: _onReset, child: Text('重置')),
            ),
            Expanded(
              child: ElevatedButton(onPressed: _onSubmit, child: Text('提交')),
            ),
          ],
        ),
      ),
    );
  }
}

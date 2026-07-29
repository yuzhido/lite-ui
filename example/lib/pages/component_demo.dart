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

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('表单验证通过')),
      );
    }
  }

  void _onReset() {
    _formKey.currentState?.reset();
    setState(() {
      _gender = null;
      _region = null;
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

              // 11. DropdownChoose
              DropdownChoose<String, int>(
                required: true,
                formLabel: '所在区域',
                value: _region,
                onSaved: (v) => debugPrint('区域: $v'),
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
              child: OutlinedButton(
                onPressed: _onReset,
                child: const Text('重置'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: _onSubmit,
                child: const Text('提交'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

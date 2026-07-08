import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';

class InputNumberDemoPage extends StatefulWidget {
  const InputNumberDemoPage({super.key});

  @override
  State<InputNumberDemoPage> createState() => _InputNumberDemoPageState();
}

class _InputNumberDemoPageState extends State<InputNumberDemoPage> {
  int _quantity = 1;
  int _score = 50;
  int _limitedValue = 0;
  double _weight = 65.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InputNumber 数字输入'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 基础用法（默认小数）
          _buildSection(
            title: '基础用法（默认小数）',
            subtitle: '默认 type = decimal，decimalPlaces = 2',
            child: InputNumber(value: 1.00, onChanged: (v) {}),
          ),

          // 整数输入
          _buildSection(
            title: '整数输入',
            subtitle: 'type = integer，最小值 0，步长 1',
            child: InputNumber(value: _quantity, type: InputNumberType.integer, onChanged: (v) => setState(() => _quantity = v.toInt())),
          ),

          // 自定义范围
          _buildSection(
            title: '自定义范围',
            subtitle: '最小值 0，最大值 100，当前值 $_score',
            child: InputNumber(value: _score, type: InputNumberType.integer, minValue: 0, maxValue: 100, onChanged: (v) => setState(() => _score = v.toInt())),
          ),

          // 自定义步长
          _buildSection(
            title: '自定义步长（每次 ±5）',
            subtitle: '步长 step = 5，当前值 $_limitedValue',
            child: InputNumber(
              value: _limitedValue,
              type: InputNumberType.integer,
              minValue: 0,
              maxValue: 50,
              step: 5,
              onChanged: (v) => setState(() => _limitedValue = v.toInt()),
            ),
          ),

          // 禁用状态
          _buildSection(
            title: '禁用状态',
            subtitle: '组件不可交互',
            child: InputNumber(value: 10, type: InputNumberType.integer, disabled: true),
          ),

          // 自定义尺寸
          _buildSection(
            title: '自定义尺寸',
            subtitle: '更大的按钮和输入框',
            child: InputNumber(value: _quantity, type: InputNumberType.integer, buttonSize: 44, inputWidth: 100, onChanged: (v) => setState(() => _quantity = v.toInt())),
          ),

          // 小数输入
          _buildSection(
            title: '小数输入（体重）',
            subtitle: 'decimalPlaces = 1，step = 0.5，当前值 $_weight kg',
            child: InputNumber(value: _weight, minValue: 30, maxValue: 200, step: 0.5, decimalPlaces: 1, onChanged: (v) => setState(() => _weight = v.toDouble())),
          ),

          // 实际场景：购物车数量
          const SizedBox(height: 16),
          _buildCartExample(),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String subtitle, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildCartExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.shopping_bag_outlined, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('商品名称', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  SizedBox(height: 4),
                  Text(
                    '¥ 29.90',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            InputNumber(value: _quantity, type: InputNumberType.integer, minValue: 0, onChanged: (v) => setState(() => _quantity = v.toInt())),
          ],
        ),
      ),
    );
  }
}

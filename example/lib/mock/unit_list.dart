import 'package:lite_ui/lite_ui.dart';

class UnitInfo {
  final String name;
  final int id;
  final String? symbol;
  final String? category;

  UnitInfo({required this.name, required this.id, this.symbol, this.category});

  factory UnitInfo.fromJson(Map<String, dynamic> json) {
    return UnitInfo(id: json['id'] as int, name: json['name'] as String, symbol: json['symbol'] as String?, category: json['category'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, if (symbol != null) 'symbol': symbol, if (category != null) 'category': category};
  }
}

/// 模拟后端返回的 JSON 字符串
final List<Map<String, dynamic>> mockUnitJson = [
  {"id": 701, "name": "个", "symbol": "个", "category": "计数"},
  {"id": 702, "name": "件", "symbol": "件", "category": "计数"},
  {"id": 703, "name": "只", "symbol": "只", "category": "计数"},
  {"id": 704, "name": "条", "symbol": "条", "category": "计数"},
  {"id": 705, "name": "包", "symbol": "包", "category": "计数"},
  {"id": 706, "name": "袋", "symbol": "袋", "category": "计数"},
  {"id": 707, "name": "瓶", "symbol": "瓶", "category": "计数"},
  {"id": 708, "name": "盒", "symbol": "盒", "category": "计数"},
  {"id": 709, "name": "箱", "symbol": "箱", "category": "计数"},
  {"id": 710, "name": "套", "symbol": "套", "category": "计数"},
  {"id": 711, "name": "双", "symbol": "双", "category": "计数"},
  {"id": 712, "name": "克", "symbol": "g", "category": "重量"},
  {"id": 713, "name": "千克", "symbol": "kg", "category": "重量"},
  {"id": 714, "name": "斤", "symbol": "斤", "category": "重量"},
  {"id": 715, "name": "毫升", "symbol": "ml", "category": "容量"},
  {"id": 716, "name": "升", "symbol": "L", "category": "容量"},
  {"id": 717, "name": "米", "symbol": "m", "category": "长度"},
  {"id": 718, "name": "厘米", "symbol": "cm", "category": "长度"},
  {"id": 719, "name": "卷", "symbol": "卷", "category": "计数"},
  {"id": 720, "name": "提", "symbol": "提", "category": "计数"},
];

/// 异步获取单位数据
Future<List<SelectItem<int, UnitInfo>>> getUnitAsyncData({String? keyword}) async {
  final List<UnitInfo> data = mockUnitJson.map((json) => UnitInfo.fromJson(json)).toList();
  if (keyword != null) {
    data.retainWhere((item) => item.name.contains(keyword) || (item.category?.contains(keyword) ?? false));
  }
  await Future.delayed(const Duration(milliseconds: 500));
  return data.map((e) => SelectItem(label: e.name, value: e.id, data: e)).toList();
}

/// 同步获取单位数据
List<SelectItem<int, UnitInfo>> getUnitSyncData({String? keyword}) {
  final List<UnitInfo> data = mockUnitJson.map((json) => UnitInfo.fromJson(json)).toList();
  if (keyword != null) {
    data.retainWhere((item) => item.name.contains(keyword) || (item.category?.contains(keyword) ?? false));
  }
  return data.map((e) => SelectItem(label: e.name, value: e.id, data: e)).toList();
}

/// 模拟新增单位
void addMockUnit({required String name, String? symbol, String? category}) {
  final newId = (mockUnitJson.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b)) + 1;
  mockUnitJson.add({'id': newId, 'name': name, 'symbol': symbol, 'category': category});
}

/// 强类型列表
final List<UnitInfo> mockUnitList = mockUnitJson.map((json) => UnitInfo.fromJson(json)).toList();

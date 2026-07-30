import 'package:lite_ui/lite_ui.dart';

class SpecInfo {
  final String name;
  final int id;
  final String? unit;
  final String? description;

  SpecInfo({required this.name, required this.id, this.unit, this.description});

  factory SpecInfo.fromJson(Map<String, dynamic> json) {
    return SpecInfo(id: json['id'] as int, name: json['name'] as String, unit: json['unit'] as String?, description: json['description'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, if (unit != null) 'unit': unit, if (description != null) 'description': description};
  }
}

/// 模拟后端返回的 JSON 字符串
final List<Map<String, dynamic>> mockSpecJson = [
  {"id": 501, "name": "500ml", "unit": "ml", "description": "小瓶装"},
  {"id": 502, "name": "1L", "unit": "L", "description": "大瓶装"},
  {"id": 503, "name": "2L", "unit": "L", "description": "家庭装"},
  {"id": 504, "name": "100g", "unit": "g", "description": "小袋装"},
  {"id": 505, "name": "250g", "unit": "g", "description": "标准装"},
  {"id": 506, "name": "500g", "unit": "g", "description": "大袋装"},
  {"id": 507, "name": "1kg", "unit": "kg", "description": "千克装"},
  {"id": 508, "name": "5kg", "unit": "kg", "description": "大包装"},
  {"id": 509, "name": "10抽", "unit": "抽", "description": "便携装"},
  {"id": 510, "name": "30抽", "unit": "抽", "description": "标准装"},
  {"id": 511, "name": "100抽", "unit": "抽", "description": "家庭装"},
  {"id": 512, "name": "3层", "unit": "层", "description": "三层加厚"},
  {"id": 513, "name": "5层", "unit": "层", "description": "五层加厚"},
  {"id": 514, "name": "S码", "unit": null, "description": "小号"},
  {"id": 515, "name": "M码", "unit": null, "description": "中号"},
  {"id": 516, "name": "L码", "unit": null, "description": "大号"},
  {"id": 517, "name": "XL码", "unit": null, "description": "加大号"},
  {"id": 518, "name": "均码", "unit": null, "description": "通用尺寸"},
  {"id": 519, "name": "10片装", "unit": "片", "description": "小包装"},
  {"id": 520, "name": "30片装", "unit": "片", "description": "标准包装"},
];

/// 异步获取规格数据
Future<List<SelectItem<int, SpecInfo>>> getSpecAsyncData({String? keyword}) async {
  final List<SpecInfo> data = mockSpecJson.map((json) => SpecInfo.fromJson(json)).toList();
  if (keyword != null) {
    data.retainWhere((item) => item.name.contains(keyword) || (item.description?.contains(keyword) ?? false));
  }
  await Future.delayed(const Duration(milliseconds: 500));
  return data.map((e) => SelectItem(label: e.name, value: e.id, data: e)).toList();
}

/// 同步获取规格数据
List<SelectItem<int, SpecInfo>> getSpecSyncData({String? keyword}) {
  final List<SpecInfo> data = mockSpecJson.map((json) => SpecInfo.fromJson(json)).toList();
  if (keyword != null) {
    data.retainWhere((item) => item.name.contains(keyword) || (item.description?.contains(keyword) ?? false));
  }
  return data.map((e) => SelectItem(label: e.name, value: e.id, data: e)).toList();
}

/// 模拟新增规格
void addMockSpec({required String name, String? unit, String? description}) {
  final newId = (mockSpecJson.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b)) + 1;
  mockSpecJson.add({'id': newId, 'name': name, 'unit': unit, 'description': description ?? ''});
}

/// 强类型列表
final List<SpecInfo> mockSpecList = mockSpecJson.map((json) => SpecInfo.fromJson(json)).toList();

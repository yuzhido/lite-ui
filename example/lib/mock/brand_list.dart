import 'package:lite_ui/lite_ui.dart';

class BrandInfo {
  final String name;
  final int id;
  final String? logo;
  final String? country;
  final String? description;

  BrandInfo({required this.name, required this.id, this.logo, this.country, this.description});

  factory BrandInfo.fromJson(Map<String, dynamic> json) {
    return BrandInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      country: json['country'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, if (logo != null) 'logo': logo, if (country != null) 'country': country, if (description != null) 'description': description};
  }
}

/// 模拟后端返回的 JSON 字符串
final List<Map<String, dynamic>> mockBrandJson = [
  {"id": 601, "name": "维达", "logo": null, "country": "中国", "description": "生活用纸知名品牌"},
  {"id": 602, "name": "清风", "logo": null, "country": "中国", "description": "金红叶纸业旗下品牌"},
  {"id": 603, "name": "蓝月亮", "logo": null, "country": "中国", "description": "洗涤用品领导品牌"},
  {"id": 604, "name": "立白", "logo": null, "country": "中国", "description": "日化洗涤品牌"},
  {"id": 605, "name": "舒肤佳", "logo": null, "country": "美国", "description": "宝洁旗下个人护理品牌"},
  {"id": 606, "name": "海飞丝", "logo": null, "country": "美国", "description": "宝洁旗下洗发护发品牌"},
  {"id": 607, "name": "高露洁", "logo": null, "country": "美国", "description": "口腔护理品牌"},
  {"id": 608, "name": "滴露", "logo": null, "country": "英国", "description": "消毒除菌品牌"},
  {"id": 609, "name": "妙洁", "logo": null, "country": "中国", "description": "家居清洁用品品牌"},
  {"id": 610, "name": "乐扣乐扣", "logo": null, "country": "韩国", "description": "保鲜用品品牌"},
  {"id": 611, "name": "茶花", "logo": null, "country": "中国", "description": "家居用品品牌"},
  {"id": 612, "name": "洁丽雅", "logo": null, "country": "中国", "description": "毛巾家纺品牌"},
  {"id": 613, "name": "大卫", "logo": null, "country": "中国", "description": "清洁工具品牌"},
  {"id": 614, "name": "美丽雅", "logo": null, "country": "中国", "description": "家居清洁工具品牌"},
  {"id": 615, "name": "天马", "logo": null, "country": "日本", "description": "收纳用品品牌"},
  {"id": 616, "name": "旭包鲜", "logo": null, "country": "日本", "description": "保鲜膜品牌"},
  {"id": 617, "name": "花王", "logo": null, "country": "日本", "description": "日用化学品品牌"},
  {"id": 618, "name": "奥妙", "logo": null, "country": "英国", "description": "联合利华旗下洗涤品牌"},
  {"id": 619, "name": "金纺", "logo": null, "country": "英国", "description": "衣物护理品牌"},
  {"id": 620, "name": "威猛先生", "logo": null, "country": "美国", "description": "庄臣旗下清洁品牌"},
];

/// 异步获取品牌数据
Future<List<SelectItem<int, BrandInfo>>> getBrandAsyncData({String? keyword}) async {
  final List<BrandInfo> data = mockBrandJson.map((json) => BrandInfo.fromJson(json)).toList();
  if (keyword != null) {
    data.retainWhere((item) => item.name.contains(keyword) || (item.country?.contains(keyword) ?? false));
  }
  await Future.delayed(const Duration(milliseconds: 500));
  return data.map((e) => SelectItem(label: e.name, value: e.id, data: e)).toList();
}

/// 同步获取品牌数据
List<SelectItem<int, BrandInfo>> getBrandSyncData({String? keyword}) {
  final List<BrandInfo> data = mockBrandJson.map((json) => BrandInfo.fromJson(json)).toList();
  if (keyword != null) {
    data.retainWhere((item) => item.name.contains(keyword) || (item.country?.contains(keyword) ?? false));
  }
  return data.map((e) => SelectItem(label: e.name, value: e.id, data: e)).toList();
}

/// 模拟新增品牌
void addMockBrand({required String name, String? country, String? description}) {
  final newId = (mockBrandJson.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b)) + 1;
  mockBrandJson.add({'id': newId, 'name': name, 'country': country, 'description': description ?? ''});
}

/// 强类型列表
final List<BrandInfo> mockBrandList = mockBrandJson.map((json) => BrandInfo.fromJson(json)).toList();

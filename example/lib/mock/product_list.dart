import 'package:lite_ui/lite_ui.dart';

class ProductInfo {
  final String name;
  final String category;
  final int id;
  final double price;
  final String? brand;

  ProductInfo({required this.name, required this.category, required this.id, required this.price, this.brand});

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      brand: json['brand'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'category': category, 'price': price, if (brand != null) 'brand': brand};
  }
}

final List<Map<String, dynamic>> mockProductJson = [
  {"id": 3001, "name": "抽纸", "category": "纸品清洁", "price": 29.9, "brand": "维达"},
  {"id": 3002, "name": "洗衣液", "category": "衣物清洁", "price": 49.9, "brand": "蓝月亮"},
  {"id": 3003, "name": "牙膏", "category": "个人护理", "price": 19.9, "brand": "高露洁"},
  {"id": 3004, "name": "洗发水", "category": "个人护理", "price": 39.9, "brand": "海飞丝"},
  {"id": 3005, "name": "沐浴露", "category": "个人护理", "price": 35.9, "brand": "舒肤佳"},
  {"id": 3006, "name": "洗洁精", "category": "厨房清洁", "price": 15.9, "brand": "立白"},
  {"id": 3007, "name": "垃圾袋", "category": "纸品清洁", "price": 12.9, "brand": "妙洁"},
  {"id": 3008, "name": "保鲜膜", "category": "厨房用品", "price": 9.9, "brand": "旭包鲜"},
  {"id": 3009, "name": "毛巾", "category": "家纺", "price": 25.9, "brand": "洁丽雅"},
  {"id": 3010, "name": "香皂", "category": "个人护理", "price": 8.9, "brand": "舒肤佳"},
  {"id": 3011, "name": "洗手液", "category": "个人护理", "price": 18.9, "brand": "滴露"},
  {"id": 3012, "name": "消毒液", "category": "家居清洁", "price": 22.9, "brand": "滴露"},
  {"id": 3013, "name": "牙刷", "category": "个人护理", "price": 12.9, "brand": "高露洁"},
  {"id": 3014, "name": "卫生纸", "category": "纸品清洁", "price": 39.9, "brand": "清风"},
  {"id": 3015, "name": "厨房纸巾", "category": "纸品清洁", "price": 19.9, "brand": "维达"},
  {"id": 3016, "name": "衣架", "category": "家居收纳", "price": 29.9, "brand": "茶花"},
  {"id": 3017, "name": "收纳箱", "category": "家居收纳", "price": 45.9, "brand": "天马"},
  {"id": 3018, "name": "拖把", "category": "家居清洁", "price": 59.9, "brand": "大卫"},
  {"id": 3019, "name": "扫把套装", "category": "家居清洁", "price": 35.9, "brand": "美丽雅"},
  {"id": 3020, "name": "保鲜盒", "category": "厨房用品", "price": 32.9, "brand": "乐扣乐扣"},
];

Future<List<SelectItem<int, ProductInfo>>> getProductAsyncData({String? keyword}) async {
  final List<ProductInfo> data = mockProductJson.map((json) => ProductInfo.fromJson(json)).toList();
  if (keyword != null) {
    data.retainWhere((item) => item.name.contains(keyword) || item.category.contains(keyword) || (item.brand?.contains(keyword) ?? false));
  }
  await Future.delayed(const Duration(seconds: 1));
  return data.map((e) => SelectItem(label: e.name, value: e.id, data: e)).toList();
}

void addMockProduct({required String name, String? category, double price = 0, String? brand}) {
  final newId = (mockProductJson.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b)) + 1;
  mockProductJson.add({'id': newId, 'name': name, 'category': category ?? '其他', 'price': price, 'brand': brand ?? '未知'});
}

List<SelectItem<int, ProductInfo>> getProductSyncData({String? keyword}) {
  final List<ProductInfo> data = mockProductJson.map((json) => ProductInfo.fromJson(json)).toList();
  if (keyword != null) {
    data.retainWhere((item) => item.name.contains(keyword) || item.category.contains(keyword) || (item.brand?.contains(keyword) ?? false));
  }
  return data.map((e) => SelectItem(label: e.name, value: e.id, data: e)).toList();
}

final List<ProductInfo> mockProductList = [
  ProductInfo(id: 3001, name: '抽纸', category: '纸品清洁', price: 29.9, brand: '维达'),
  ProductInfo(id: 3002, name: '洗衣液', category: '衣物清洁', price: 49.9, brand: '蓝月亮'),
  ProductInfo(id: 3003, name: '牙膏', category: '个人护理', price: 19.9, brand: '高露洁'),
  ProductInfo(id: 3004, name: '洗发水', category: '个人护理', price: 39.9, brand: '海飞丝'),
  ProductInfo(id: 3005, name: '沐浴露', category: '个人护理', price: 35.9, brand: '舒肤佳'),
  ProductInfo(id: 3006, name: '洗洁精', category: '厨房清洁', price: 15.9, brand: '立白'),
  ProductInfo(id: 3007, name: '垃圾袋', category: '纸品清洁', price: 12.9, brand: '妙洁'),
  ProductInfo(id: 3008, name: '保鲜膜', category: '厨房用品', price: 9.9, brand: '旭包鲜'),
  ProductInfo(id: 3009, name: '毛巾', category: '家纺', price: 25.9, brand: '洁丽雅'),
  ProductInfo(id: 3010, name: '香皂', category: '个人护理', price: 8.9, brand: '舒肤佳'),
  ProductInfo(id: 3011, name: '洗手液', category: '个人护理', price: 18.9, brand: '滴露'),
  ProductInfo(id: 3012, name: '消毒液', category: '家居清洁', price: 22.9, brand: '滴露'),
  ProductInfo(id: 3013, name: '牙刷', category: '个人护理', price: 12.9, brand: '高露洁'),
  ProductInfo(id: 3014, name: '卫生纸', category: '纸品清洁', price: 39.9, brand: '清风'),
  ProductInfo(id: 3015, name: '厨房纸巾', category: '纸品清洁', price: 19.9, brand: '维达'),
  ProductInfo(id: 3016, name: '衣架', category: '家居收纳', price: 29.9, brand: '茶花'),
  ProductInfo(id: 3017, name: '收纳箱', category: '家居收纳', price: 45.9, brand: '天马'),
  ProductInfo(id: 3018, name: '拖把', category: '家居清洁', price: 59.9, brand: '大卫'),
  ProductInfo(id: 3019, name: '扫把套装', category: '家居清洁', price: 35.9, brand: '美丽雅'),
  ProductInfo(id: 3020, name: '保鲜盒', category: '厨房用品', price: 32.9, brand: '乐扣乐扣'),
];

import 'package:lite_ui/lite_ui.dart';

class CategoryInfo {
  final String name;
  final int id;
  final int parentId;
  final String? icon;
  final int sort;

  CategoryInfo({required this.name, required this.id, this.parentId = 0, this.icon, this.sort = 0});

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      parentId: json['parentId'] as int? ?? 0,
      icon: json['icon'] as String?,
      sort: json['sort'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'parentId': parentId, if (icon != null) 'icon': icon, 'sort': sort};
  }
}

/// 模拟后端返回的 JSON 字符串
final List<Map<String, dynamic>> mockCategoryJson = [
  {"id": 100, "name": "纸品清洁", "parentId": 0, "icon": "article", "sort": 1},
  {"id": 101, "name": "衣物清洁", "parentId": 0, "icon": "checkroom", "sort": 2},
  {"id": 102, "name": "个人护理", "parentId": 0, "icon": "face", "sort": 3},
  {"id": 103, "name": "厨房清洁", "parentId": 0, "icon": "restaurant", "sort": 4},
  {"id": 104, "name": "厨房用品", "parentId": 0, "icon": "coffee", "sort": 5},
  {"id": 105, "name": "家居清洁", "parentId": 0, "icon": "cleaning_services", "sort": 6},
  {"id": 106, "name": "家居收纳", "parentId": 0, "icon": "inventory_2", "sort": 7},
  {"id": 107, "name": "家纺", "parentId": 0, "icon": "bed", "sort": 8},
  {"id": 108, "name": "食品", "parentId": 0, "icon": "lunch_dining", "sort": 9},
  {"id": 109, "name": "母婴", "parentId": 0, "icon": "child_care", "sort": 10},
  {"id": 110, "name": "宠物用品", "parentId": 0, "icon": "pets", "sort": 11},
  {"id": 111, "name": "办公文具", "parentId": 0, "icon": "edit_note", "sort": 12},
  {"id": 112, "name": "数码电器", "parentId": 0, "icon": "devices", "sort": 13},
  {"id": 113, "name": "美妆护肤", "parentId": 0, "icon": "face_retouching_natural", "sort": 14},
  {"id": 114, "name": "医药保健", "parentId": 0, "icon": "local_hospital", "sort": 15},
];

/// 异步获取分类数据
Future<List<SelectItem<int, CategoryInfo>>> getCategoryAsyncData({String? keyword}) async {
  final List<CategoryInfo> data = mockCategoryJson.map((json) => CategoryInfo.fromJson(json)).toList();
  if (keyword != null) {
    data.retainWhere((item) => item.name.contains(keyword));
  }
  data.sort((a, b) => a.sort.compareTo(b.sort));
  await Future.delayed(const Duration(milliseconds: 500));
  return data.map((e) => SelectItem(label: e.name, value: e.id, data: e)).toList();
}

/// 同步获取分类数据
List<SelectItem<int, CategoryInfo>> getCategorySyncData({String? keyword}) {
  final List<CategoryInfo> data = mockCategoryJson.map((json) => CategoryInfo.fromJson(json)).toList();
  if (keyword != null) {
    data.retainWhere((item) => item.name.contains(keyword));
  }
  data.sort((a, b) => a.sort.compareTo(b.sort));
  return data.map((e) => SelectItem(label: e.name, value: e.id, data: e)).toList();
}

/// 模拟新增分类
void addMockCategory({required String name, int parentId = 0, String? icon}) {
  final newId = (mockCategoryJson.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b)) + 1;
  final newSort = (mockCategoryJson.map((e) => e['sort'] as int? ?? 0).reduce((a, b) => a > b ? a : b)) + 1;
  mockCategoryJson.add({'id': newId, 'name': name, 'parentId': parentId, 'icon': icon, 'sort': newSort});
}

/// 强类型列表
final List<CategoryInfo> mockCategoryList = mockCategoryJson.map((json) => CategoryInfo.fromJson(json)).toList();

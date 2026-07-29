import 'package:lite_ui/lite_ui.dart';

class AreaInfo {
  final String name;
  final String code;
  final int id;
  final String? description;

  AreaInfo({required this.name, required this.code, required this.id, this.description});

  /// 从 JSON 构造
  factory AreaInfo.fromJson(Map<String, dynamic> json) {
    return AreaInfo(id: json['id'] as int, name: json['name'] as String, code: json['code'] as String, description: json['description'] as String?);
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code, if (description != null) 'description': description};
  }
}

/// 模拟后端返回的 JSON 字符串（可变列表，支持运行时新增）
final List<Map<String, dynamic>> mockAreaJson = [
  {"id": 1918475623301, "name": "北京市", "code": "110000", "description": "直辖市"},
  {"id": 1918475623302, "name": "天津市", "code": "120000", "description": "直辖市"},
  {"id": 1918475623303, "name": "上海市", "code": "310000", "description": "直辖市"},
  {"id": 1918475623304, "name": "重庆市", "code": "500000", "description": "直辖市"},
  {"id": 1918475623305, "name": "石家庄市", "code": "130100", "description": "河北省省会"},
  {"id": 1918475623306, "name": "唐山市", "code": "130200", "description": "河北省"},
  {"id": 1918475623307, "name": "太原市", "code": "140100", "description": "山西省省会"},
  {"id": 1918475623308, "name": "大同市", "code": "140200", "description": "山西省"},
  {"id": 1918475623309, "name": "呼和浩特市", "code": "150100", "description": "内蒙古自治区首府"},
  {"id": 1918475623310, "name": "包头市", "code": "150200", "description": "内蒙古自治区"},
  {"id": 1918475623311, "name": "沈阳市", "code": "210100", "description": "辽宁省省会"},
  {"id": 1918475623312, "name": "大连市", "code": "210200", "description": "辽宁省"},
  {"id": 1918475623313, "name": "长春市", "code": "220100", "description": "吉林省省会"},
  {"id": 1918475623314, "name": "哈尔滨市", "code": "230100", "description": "黑龙江省省会"},
  {"id": 1918475623315, "name": "南京市", "code": "320100", "description": "江苏省省会"},
  {"id": 1918475623316, "name": "苏州市", "code": "320500", "description": "江苏省"},
  {"id": 1918475623317, "name": "杭州市", "code": "330100", "description": "浙江省省会"},
  {"id": 1918475623318, "name": "宁波市", "code": "330200", "description": "浙江省"},
  {"id": 1918475623319, "name": "合肥市", "code": "340100", "description": "安徽省省会"},
  {"id": 1918475623320, "name": "福州市", "code": "350100", "description": "福建省省会"},
];
// 异步获取数据
Future<List<SelectItem<int, AreaInfo>>> getAsyncData({String? keyword}) async {
  final List<AreaInfo> data = mockAreaJson.map((json) => AreaInfo.fromJson(json)).toList();
  if (keyword != null) {
    data.retainWhere((item) => item.name.contains(keyword));
  }
  await Future.delayed(Duration(seconds: 1));
  return data.map((json) => SelectItem(label: json.name, value: json.id, data: json)).toList();
}

/// 模拟新增城市到数据源
void addMockArea({required String name, String? code}) {
  final newId = (mockAreaJson.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b)) + 1;
  mockAreaJson.add({'id': newId, 'name': name, 'code': code ?? '000000', 'description': '新增城市'});
}

// 同步获取数据
List<SelectItem<int, AreaInfo>> getSyncData({String? keyword}) {
  final List<AreaInfo> data = mockAreaJson.map((json) => AreaInfo.fromJson(json)).toList();
  if (keyword != null) {
    data.retainWhere((item) => item.name.contains(keyword));
  }
  return data.map((json) => SelectItem(label: json.name, value: json.id, data: json)).toList();
}

/// 模拟 20 条后端返回的区域数据
final List<AreaInfo> mockAreaList = [
  AreaInfo(id: 1918475623301, name: '北京市', code: '110000', description: '直辖市'),
  AreaInfo(id: 1918475623302, name: '天津市', code: '120000', description: '直辖市'),
  AreaInfo(id: 1918475623303, name: '上海市', code: '310000', description: '直辖市'),
  AreaInfo(id: 1918475623304, name: '重庆市', code: '500000', description: '直辖市'),
  AreaInfo(id: 1918475623305, name: '石家庄市', code: '130100', description: '河北省省会'),
  AreaInfo(id: 1918475623306, name: '唐山市', code: '130200', description: '河北省'),
  AreaInfo(id: 1918475623307, name: '太原市', code: '140100', description: '山西省省会'),
  AreaInfo(id: 1918475623308, name: '大同市', code: '140200', description: '山西省'),
  AreaInfo(id: 1918475623309, name: '呼和浩特市', code: '150100', description: '内蒙古自治区首府'),
  AreaInfo(id: 1918475623310, name: '包头市', code: '150200', description: '内蒙古自治区'),
  AreaInfo(id: 1918475623311, name: '沈阳市', code: '210100', description: '辽宁省省会'),
  AreaInfo(id: 1918475623312, name: '大连市', code: '210200', description: '辽宁省'),
  AreaInfo(id: 1918475623313, name: '长春市', code: '220100', description: '吉林省省会'),
  AreaInfo(id: 1918475623314, name: '哈尔滨市', code: '230100', description: '黑龙江省省会'),
  AreaInfo(id: 1918475623315, name: '南京市', code: '320100', description: '江苏省省会'),
  AreaInfo(id: 1918475623316, name: '苏州市', code: '320500', description: '江苏省'),
  AreaInfo(id: 1918475623317, name: '杭州市', code: '330100', description: '浙江省省会'),
  AreaInfo(id: 1918475623318, name: '宁波市', code: '330200', description: '浙江省'),
  AreaInfo(id: 1918475623319, name: '合肥市', code: '340100', description: '安徽省省会'),
  AreaInfo(id: 1918475623320, name: '福州市', code: '350100', description: '福建省省会'),
];

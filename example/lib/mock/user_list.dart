import 'package:lite_ui/lite_ui.dart';

class UserInfo {
  final String name;
  final String phone;
  final int id;
  final String? department;

  UserInfo({required this.name, required this.phone, required this.id, this.department});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(id: json['id'] as int, name: json['name'] as String, phone: json['phone'] as String, department: json['department'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'phone': phone, if (department != null) 'department': department};
  }
}

final List<Map<String, dynamic>> mockUserJson = [
  {"id": 2001, "name": "张三", "phone": "13800138001", "department": "技术部"},
  {"id": 2002, "name": "李四", "phone": "13800138002", "department": "产品部"},
  {"id": 2003, "name": "王五", "phone": "13800138003", "department": "设计部"},
  {"id": 2004, "name": "赵六", "phone": "13800138004", "department": "技术部"},
  {"id": 2005, "name": "孙七", "phone": "13800138005", "department": "市场部"},
  {"id": 2006, "name": "周八", "phone": "13800138006", "department": "运营部"},
  {"id": 2007, "name": "吴九", "phone": "13800138007", "department": "技术部"},
  {"id": 2008, "name": "郑十", "phone": "13800138008", "department": "财务部"},
  {"id": 2009, "name": "陈明", "phone": "13800138009", "department": "人事部"},
  {"id": 2010, "name": "林芳", "phone": "13800138010", "department": "产品部"},
  {"id": 2011, "name": "黄伟", "phone": "13800138011", "department": "技术部"},
  {"id": 2012, "name": "刘洋", "phone": "13800138012", "department": "市场部"},
  {"id": 2013, "name": "杨静", "phone": "13800138013", "department": "设计部"},
  {"id": 2014, "name": "徐强", "phone": "13800138014", "department": "运营部"},
  {"id": 2015, "name": "马丽", "phone": "13800138015", "department": "技术部"},
  {"id": 2016, "name": "朱军", "phone": "13800138016", "department": "财务部"},
  {"id": 2017, "name": "胡婷", "phone": "13800138017", "department": "人事部"},
  {"id": 2018, "name": "郭磊", "phone": "13800138018", "department": "产品部"},
  {"id": 2019, "name": "何敏", "phone": "13800138019", "department": "技术部"},
  {"id": 2020, "name": "高峰", "phone": "13800138020", "department": "市场部"},
];

Future<List<SelectItem<int, UserInfo>>> getUserAsyncData({String? keyword}) async {
  final List<UserInfo> data = mockUserJson.map((json) => UserInfo.fromJson(json)).toList();
  if (keyword != null) {
    data.retainWhere((item) => item.name.contains(keyword) || (item.department?.contains(keyword) ?? false));
  }
  await Future.delayed(const Duration(seconds: 1));
  return data.map((e) => SelectItem(label: e.name, value: e.id, data: e)).toList();
}

void addMockUser({required String name, String? phone, String? department}) {
  final newId = (mockUserJson.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b)) + 1;
  mockUserJson.add({'id': newId, 'name': name, 'phone': phone ?? '00000000000', 'department': department ?? '未分配'});
}

List<SelectItem<int, UserInfo>> getUserSyncData({String? keyword}) {
  final List<UserInfo> data = mockUserJson.map((json) => UserInfo.fromJson(json)).toList();
  if (keyword != null) {
    data.retainWhere((item) => item.name.contains(keyword) || (item.department?.contains(keyword) ?? false));
  }
  return data.map((e) => SelectItem(label: e.name, value: e.id, data: e)).toList();
}

final List<UserInfo> mockUserList = [
  UserInfo(id: 2001, name: '张三', phone: '13800138001', department: '技术部'),
  UserInfo(id: 2002, name: '李四', phone: '13800138002', department: '产品部'),
  UserInfo(id: 2003, name: '王五', phone: '13800138003', department: '设计部'),
  UserInfo(id: 2004, name: '赵六', phone: '13800138004', department: '技术部'),
  UserInfo(id: 2005, name: '孙七', phone: '13800138005', department: '市场部'),
  UserInfo(id: 2006, name: '周八', phone: '13800138006', department: '运营部'),
  UserInfo(id: 2007, name: '吴九', phone: '13800138007', department: '技术部'),
  UserInfo(id: 2008, name: '郑十', phone: '13800138008', department: '财务部'),
  UserInfo(id: 2009, name: '陈明', phone: '13800138009', department: '人事部'),
  UserInfo(id: 2010, name: '林芳', phone: '13800138010', department: '产品部'),
  UserInfo(id: 2011, name: '黄伟', phone: '13800138011', department: '技术部'),
  UserInfo(id: 2012, name: '刘洋', phone: '13800138012', department: '市场部'),
  UserInfo(id: 2013, name: '杨静', phone: '13800138013', department: '设计部'),
  UserInfo(id: 2014, name: '徐强', phone: '13800138014', department: '运营部'),
  UserInfo(id: 2015, name: '马丽', phone: '13800138015', department: '技术部'),
  UserInfo(id: 2016, name: '朱军', phone: '13800138016', department: '财务部'),
  UserInfo(id: 2017, name: '胡婷', phone: '13800138017', department: '人事部'),
  UserInfo(id: 2018, name: '郭磊', phone: '13800138018', department: '产品部'),
  UserInfo(id: 2019, name: '何敏', phone: '13800138019', department: '技术部'),
  UserInfo(id: 2020, name: '高峰', phone: '13800138020', department: '市场部'),
];

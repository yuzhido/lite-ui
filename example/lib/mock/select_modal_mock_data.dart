import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';

/// SelectModal 示例数据
class SelectModalMockData {
  /// 城市列表示例
  static const List<SelectItem<String, void>> cityItems = [
    SelectItem(label: '北京', subtitle: 'Beijing · 首都', value: 'beijing'),
    SelectItem(label: '上海', subtitle: 'Shanghai · 经济中心', value: 'shanghai'),
    SelectItem(label: '广州', subtitle: 'Guangzhou · 华南重镇', value: 'guangzhou'),
    SelectItem(label: '深圳', subtitle: 'Shenzhen · 科技之城', value: 'shenzhen'),
    SelectItem(label: '杭州', subtitle: 'Hangzhou · 互联网之都', value: 'hangzhou'),
    SelectItem(label: '成都', subtitle: 'Chengdu · 天府之国', value: 'chengdu'),
    SelectItem(label: '武汉', subtitle: 'Wuhan · 九省通衢', value: 'wuhan'),
    SelectItem(label: '南京', subtitle: 'Nanjing · 六朝古都', value: 'nanjing'),
    SelectItem(label: '重庆', subtitle: 'Chongqing · 山城', value: 'chongqing'),
    SelectItem(label: '西安', subtitle: "Xi'an · 十三朝古都", value: 'xian'),
    SelectItem(label: '苏州', subtitle: 'Suzhou · 人间天堂', value: 'suzhou'),
    SelectItem(label: '天津', subtitle: 'Tianjin · 直辖市', value: 'tianjin'),
    SelectItem(label: '长沙', subtitle: 'Changsha · 星城', value: 'changsha'),
    SelectItem(label: '青岛', subtitle: 'Qingdao · 海滨城市', value: 'qingdao'),
    SelectItem(label: '大连', subtitle: 'Dalian · 北方明珠', value: 'dalian'),
  ];

  /// 带图标的操作项示例
  static List<SelectItem<String, void>> get iconItems => [
    SelectItem.withIcon(
      label: '拍照',
      value: 'camera',
      iconData: const IconData(0xe3ae, fontFamily: 'MaterialIcons'),
      iconColor: const Color(0xFF2196F3),
    ),
    SelectItem.withIcon(
      label: '从相册选择',
      value: 'album',
      iconData: const IconData(0xe39a, fontFamily: 'MaterialIcons'),
      iconColor: const Color(0xFF4CAF50),
    ),
    SelectItem.withIcon(
      label: '录制视频',
      value: 'video',
      iconData: const IconData(0xe3b1, fontFamily: 'MaterialIcons'),
      iconColor: const Color(0xFFF44336),
    ),
    SelectItem.withIcon(
      label: '文件管理器',
      value: 'files',
      iconData: const IconData(0xe2bc, fontFamily: 'MaterialIcons'),
      iconColor: const Color(0xFFFF9800),
    ),
    SelectItem.withIcon(
      label: '收藏夹',
      value: 'favorites',
      iconData: const IconData(0xe25b, fontFamily: 'MaterialIcons'),
      iconColor: const Color(0xFFFFC107),
    ),
  ];
}

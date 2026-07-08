import 'package:flutter/material.dart';
import 'package:lite_ui/lite_ui.dart';

/// ActionSheet 示例数据
class ActionSheetMockData {
  /// 默认操作项列表（20条，用于测试滚动效果）
  static const List<SelectItem<String, void>> defaultItems = [
    SelectItem(label: '拍照', subtitle: '使用相机拍摄照片', value: 'camera'),
    SelectItem(label: '从相册选择', subtitle: '从手机相册中选取图片', value: 'album'),
    SelectItem(label: '拍摄视频', subtitle: '录制一段短视频', value: 'video'),
    SelectItem(label: '文件', value: 'file'),
    SelectItem(label: '收藏', value: 'favorite'),
    SelectItem(label: '分享', value: 'share'),
    SelectItem(label: '复制链接', value: 'copy_link'),
    SelectItem(label: '刷新', subtitle: '重新加载当前内容', value: 'refresh'),
    SelectItem(label: '编辑', subtitle: '修改当前内容', value: 'edit'),
    SelectItem(label: '置顶', subtitle: '将内容置顶显示', value: 'pin'),
    SelectItem(label: '标记已读', value: 'mark_read'),
    SelectItem(label: '静音', subtitle: '关闭该会话的通知', value: 'mute'),
    SelectItem(label: '导出数据', subtitle: '导出为 CSV 或 Excel 格式', value: 'export'),
    SelectItem(label: '打印', subtitle: '发送到打印机打印', value: 'print'),
    SelectItem(label: '归档', value: 'archive'),
    SelectItem(label: '举报', subtitle: '提交违规内容举报', value: 'report'),
    SelectItem(label: '拉黑用户', subtitle: '屏蔽该用户的所有消息', value: 'block'),
    SelectItem(label: '清空记录', subtitle: '清除全部聊天记录', value: 'clear'),
    SelectItem(label: '切换账号', subtitle: '切换到其他账号登录', value: 'switch_account'),
    SelectItem(label: '删除', subtitle: '删除后不可恢复，请谨慎操作', value: 'delete'),
  ];

  /// 分组数据示例
  static List<ActionSheetSection<String, void>> get sectionedItems => [
    ActionSheetSection(
      title: '文件操作',
      items: [
        SelectItem(label: '新建文档', value: 'new_doc'),
        SelectItem(label: '新建文件夹', value: 'new_folder'),
        SelectItem(label: '从剪贴板粘贴', value: 'paste'),
      ],
    ),
    ActionSheetSection(
      title: '分享选项',
      items: [
        SelectItem(label: '微信好友', value: 'wechat'),
        SelectItem(label: '短信分享', value: 'sms'),
        SelectItem(label: '复制链接', value: 'copy_link'),
      ],
    ),
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
}

---
kind: configuration_system
name: LiteUI 主题与组件配置系统
category: configuration_system
scope:
    - '**'
source_files:
    - lib/src/theme/index.dart
    - lib/src/empty_data/models/index.dart
    - lib/src/dialog_action/models/index.dart
    - lib/src/file_upload/model/upload_config.dart
    - lib/lite_ui.dart
---

LiteUI 作为 Flutter 轻量级 UI 组件库，其配置系统围绕 **主题（Theme）+ 组件默认配置** 两层架构构建，没有使用外部配置文件或环境变量，所有配置均以 Dart 代码形式内聚在库内部。

## 1. 主题系统（LiteUITheme）
- 核心文件：`lib/src/theme/index.dart`
- 通过 `LiteUIThemeData` 承载库级别的默认颜色、圆角等样式配置（边框色、错误色、聚焦色、文字色、标签背景色等）
- 通过 `LiteUITheme` 继承 `InheritedWidget` 实现全局主题注入，应用层可通过包裹 `LiteUITheme(data: ..., child: MyApp())` 统一覆盖默认样式
- 提供 `LiteUITheme.of(context)` 静态方法从 Widget Tree 中获取当前主题，未找到时回退到 `LiteUIThemeData.defaults`

## 2. 组件默认配置表
各组件模块通过独立的 `models/index.dart` 定义默认配置，采用 **枚举 + 常量映射表** 模式：
- **空状态（EmptyData）**：`emptyDataDefaults` 是 `Map<EmptyDataType, EmptyConfig>`，为每种空状态场景（empty/search/noNetwork/error/noPermission/noMessage/noOrder/maintenance）预设标题、描述、图标、配色等
- **弹窗（DialogAction）**：`DialogDefaults` 类集中管理默认文案（确定/取消/提示文本），配合 `DialogType`、`DialogButtonStyle`、`DialogPresetIcon` 等枚举控制行为
- **上传（FileUpload）**：`UploadConfig` 类封装上传模式（auto/manual/custom）、URL、请求头、并发数、重试次数、自定义上传函数等完整配置项

## 3. 配置传递约定
- 组件参数优先使用传入值，其次回退到 `_config` 或 `defaults`（如 `widget.title ?? _config.title`）
- 复杂参数聚合为独立类（如 `EmptyDataStyleParams`、`UploadConfig`），避免构造函数参数膨胀
- 所有配置类均使用 `const` 构造器，支持编译时常量优化

## 4. 设计原则
- **零外部依赖**：不引入 `flutter_dotenv`、`shared_preferences` 等配置包，全部以纯 Dart 代码管理
- **类型安全**：通过 enum 和强类型 class 替代字符串魔法值
- **可组合性**：主题数据与组件配置分离，允许按需覆盖部分字段
- **向后兼容**：所有配置字段提供合理默认值，新增配置不影响现有用法
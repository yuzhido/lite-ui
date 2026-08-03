---
kind: configuration_system
name: LiteUI 配置系统 — 主题与组件级配置模式
category: configuration_system
scope:
    - '**'
source_files:
    - lib/src/theme/index.dart
    - lib/src/file_upload/model/upload_config.dart
    - lib/src/empty_data/models/index.dart
    - pubspec.yaml
---

该仓库是一个 Flutter 自定义 UI 组件库，**不包含运行时应用级配置加载系统**（如 .env、配置文件解析、环境变量注入等）。其“配置”主要体现在以下两个层面：

### 1. 主题配置（Theme）
- 核心文件：`lib/src/theme/index.dart`
- 通过 `LiteUIThemeData` 定义库级别的默认颜色、圆角、边框等样式常量。
- 通过 `LiteUITheme`（继承 `InheritedWidget`）在 Widget Tree 中提供全局主题数据，组件通过 `LiteUITheme.of(context)` 读取，未包裹时回退到 `LiteUIThemeData.defaults`。
- 这是库唯一的“全局配置”机制，由使用者在 App 层通过 `LiteUITheme(data: ..., child: ...)` 包裹来覆盖默认值。

### 2. 组件级配置对象
各组件通过独立的配置类暴露可定制参数，典型示例：
- **文件上传**：`lib/src/file_upload/model/upload_config.dart` 中的 `UploadConfig`，支持上传模式（auto/manual/custom）、URL、请求头、并发数、重试次数、自定义上传函数等。
- **空状态页**：`lib/src/empty_data/models/index.dart` 中的 `EmptyConfig`，为不同空状态类型提供标题、描述、图标、颜色等默认配置映射表 `emptyDataDefaults`。
- 其他组件（输入框、树形选择、对话框等）均遵循相同模式：在各自目录下定义 `models/` 或内嵌配置类，通过构造函数参数传入。

### 3. 包依赖与环境约束
- `pubspec.yaml` 声明 SDK 版本约束（`^3.12.2`、`flutter >= 1.17.0`）及第三方依赖（file_picker、image_picker 等）。
- 无 `.env`、`config.yaml`、`application.properties` 等运行时配置文件。
- 无环境变量读取（未使用 `Platform.environment`、`dotenv` 等）。

### 开发者约定
- 新增组件应仿照现有模式：在 `src/<component>/` 下创建 `index.dart` 导出入口，若有复杂配置则放在 `model/` 目录。
- 全局样式统一通过 `LiteUIThemeData` 扩展，不要在各组件内硬编码颜色或尺寸。
- 组件行为差异通过构造参数或独立配置类传递，避免引入全局单例或外部配置中心。
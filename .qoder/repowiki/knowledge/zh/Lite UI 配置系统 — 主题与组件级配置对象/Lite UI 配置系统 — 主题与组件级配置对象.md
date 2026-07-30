---
kind: configuration_system
name: Lite UI 配置系统 — 主题与组件级配置对象
category: configuration_system
scope:
    - '**'
source_files:
    - lib/src/theme/index.dart
    - lib/src/file_upload/model/upload_config.dart
    - lib/src/empty_data/models/index.dart
    - pubspec.yaml
    - example/pubspec.yaml
---

该仓库是一个 Flutter UI 组件库，没有传统意义上的全局配置文件（如 .env、application.properties、config.yaml 等），而是采用 **Flutter 惯用的运行时配置对象 + InheritedWidget 主题注入** 的方式管理配置。具体分为两个层次：

### 1. 应用级主题配置（Theme）
- 核心文件：`lib/src/theme/index.dart`
- 通过 `LiteUIThemeData` 定义库级别的默认颜色、圆角、边框等样式常量
- 通过 `LiteUITheme`（继承 `InheritedWidget`）将主题数据注入 widget tree，子组件可通过 `LiteUITheme.of(context)` 获取
- 使用方式：在 App 根节点用 `LiteUITheme(data: LiteUIThemeData(...), child: MyApp())` 包裹即可全局覆盖默认样式

### 2. 组件级配置对象（Config）
每个功能模块都通过独立的配置类暴露可定制参数：
- **空状态 EmptyData**：`EmptyConfig` + `emptyDataDefaults` 映射表，按 `EmptyDataType` 提供默认文案、颜色、图标，支持风格化覆盖
- **文件上传 FileUpload**：`UploadConfig` 统一封装上传模式（auto/manual/custom）、URL、请求头、并发数、重试次数、自定义上传函数等
- 其他组件如 InputText、DropdownChoose、TreeSelect 等也遵循同样的「参数对象」模式，避免构造函数参数爆炸

### 3. 包依赖与环境配置
- `pubspec.yaml`：声明 SDK 版本约束（flutter ^3.12.2）、依赖（file_picker、image_picker）和 dev_dependencies
- `example/pubspec.yaml`：示例应用通过 `path: ../` 引用本地 lite_ui 包，便于开发调试
- 无 `.env`、`.toml`、`application.properties` 等外部配置文件

### 设计约定
- 所有可配置项以 **不可变数据类（const constructor）** 形式存在，保证类型安全
- 默认值集中在各自模块的 `models/` 或独立 config 文件中，通过静态 defaults 或常量 Map 提供
- 组件内部通过 `widget.xxx ?? _default` 的模式实现参数合并
- 主题与组件配置解耦：主题管视觉，业务组件管行为参数
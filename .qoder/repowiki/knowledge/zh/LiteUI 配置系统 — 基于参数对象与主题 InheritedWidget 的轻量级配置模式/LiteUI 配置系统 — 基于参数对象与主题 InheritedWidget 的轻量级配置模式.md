---
kind: configuration_system
name: LiteUI 配置系统 — 基于参数对象与主题 InheritedWidget 的轻量级配置模式
category: configuration_system
scope:
    - '**'
source_files:
    - lib/lite_ui.dart
    - lib/src/theme/index.dart
    - lib/src/empty_data/models/index.dart
    - lib/src/file_upload/model/upload_config.dart
    - lib/src/tree_select/model.dart
---

## 1. 使用的系统与方式
LiteUI 作为 Flutter UI 组件库，没有引入外部配置框架（如 `flutter_config`、`envied`、`.env` 文件等），而是采用**纯 Dart 常量 + 不可变配置类 + InheritedWidget 主题注入**的方式实现运行时配置。所有配置以 `const` 构造的类或 Map 形式定义，通过 Widget 参数传入或由主题上下文提供。

## 2. 核心文件与包
- **主题系统**：`lib/src/theme/index.dart` — `LiteUIThemeData`（颜色/圆角等全局样式）+ `LiteUITheme`（InheritedWidget 注入）
- **空状态配置**：`lib/src/empty_data/models/index.dart` — `EmptyConfig` + `emptyDataDefaults`（按场景预置的标题、描述、图标、配色）
- **文件上传配置**：`lib/src/file_upload/model/upload_config.dart` — `UploadConfig`（URL、方法、并发、重试、自定义上传函数等）
- **树形选择器配置**：`lib/src/tree_select/model.dart` — `TreeSelectConfig<T>`（标题、搜索、多选、懒加载回调等）
- **统一导出入口**：`lib/lite_ui.dart` — 集中导出各模块的 index 与主题

## 3. 架构与设计约定
- **配置即数据**：每个组件的配置都是一个独立的 `const` 类（如 `UploadConfig`、`TreeSelectConfig`、`EmptyConfig`），字段均为 final，构造为 const，保证不可变性与编译期常量优化。
- **默认值集中管理**：`emptyDataDefaults` 是一个 `Map<EmptyDataType, EmptyConfig>`，按场景枚举提供开箱即用的文案与配色；`LiteUIThemeData.defaults` 提供全局默认主题。
- **主题通过 InheritedWidget 注入**：`LiteUITheme` 包裹应用根节点，组件内部通过 `LiteUITheme.of(context)` 读取，未找到时回退到 `defaults`，实现“库级默认 → 应用级覆盖”的层级。
- **配置与 UI 解耦**：配置类只承载数据，UI 组件通过构造函数接收配置对象，避免散落的布尔开关和魔法字符串。
- **无外部配置文件**：不依赖 `.env`、`.yaml`、`.properties` 等外部文件，所有配置在代码中定义，适合纯 Flutter 库场景。

## 4. 开发者应遵循的规则
- **新增组件配置**：新建一个 `XxxConfig` 类，使用 `const` 构造并提供合理的默认值；如需按类型区分默认值，参考 `emptyDataDefaults` 的模式建立 Map。
- **主题扩展**：通过 `LiteUIThemeData` 添加新的可配置属性，并在组件中通过 `LiteUITheme.of(context).xxx` 读取，保持向后兼容（新字段带默认值）。
- **不要硬编码配置**：组件内部不应出现魔法字符串或硬编码颜色，应从配置对象或主题中获取。
- **配置不可变**：所有 Config 类字段应为 final，构造为 const，禁止在运行期修改。
- **按需暴露**：仅在 `lite_ui.dart` 中导出必要的 index 文件，避免泄露内部实现细节。

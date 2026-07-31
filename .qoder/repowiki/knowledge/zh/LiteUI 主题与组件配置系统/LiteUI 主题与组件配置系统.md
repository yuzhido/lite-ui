---
kind: configuration_system
name: LiteUI 主题与组件配置系统
category: configuration_system
scope:
    - '**'
source_files:
    - lib/src/theme/index.dart
    - lib/src/file_upload/model/upload_config.dart
    - lib/src/empty_data/models/index.dart
    - pubspec.yaml
---

LiteUI 作为 Flutter UI 组件库，其配置系统主要围绕**主题系统**和**组件级配置对象**两个层面构建，采用纯 Dart 代码定义、无外部配置文件加载的方式。

## 1. 主题系统（Theme）

核心文件：`lib/src/theme/index.dart`

- **LiteUIThemeData**：不可变的主题数据类，包含边框颜色、错误颜色、圆角半径、提示文字颜色、标签背景色等视觉配置项，提供 `defaults` 静态默认值。
- **LiteUITheme**：基于 `InheritedWidget` 实现的主题提供者，通过 `LiteUITheme.of(context)` 在 widget tree 中获取主题数据，未设置时回退到 `LiteUIThemeData.defaults`。
- 使用方式：在 App 根节点用 `LiteUITheme(data: LiteUIThemeData(...), child: ...)` 包裹，全局覆盖组件默认样式。

## 2. 组件级配置对象

各组件通过独立的配置类管理自身行为，典型示例：

- **UploadConfig**（文件上传）：`lib/src/file_upload/model/upload_config.dart`，支持 auto/manual/custom 三种上传模式，配置 URL、HTTP 方法、请求头、并发数、重试次数、自定义上传函数等。
- **EmptyConfig**（空状态）：`lib/src/empty_data/models/index.dart`，为每种 EmptyDataType 预置 title、description、iconColor、bgColor、actionColor、icon 等默认值，通过 `emptyDataDefaults` 映射表统一管理。

## 3. 配置组织约定

- 所有配置均为**纯 Dart 类/枚举**，无 `.yaml`、`.json`、`.env` 等外部配置文件。
- 配置类采用不可变设计（const 构造函数），通过参数传递而非全局变量。
- 每个功能模块独立维护自己的配置模型，遵循 `model/` 或 `models/` 目录组织。
- 组件通过构造函数参数接收配置，内部使用 `??` 操作符提供默认值。

## 4. 开发者规范

- 新增组件时应定义对应的 Config 类，并提供合理的默认值。
- 主题相关样式统一通过 `LiteUITheme.of(context)` 获取，避免硬编码颜色。
- 配置变更通过 widget 重建传播，不使用全局状态管理。
- 不支持运行时动态加载外部配置文件，所有配置编译期确定。
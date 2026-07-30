---
kind: configuration_system
name: Lite UI 组件库配置系统
category: configuration_system
scope:
    - '**'
source_files:
    - lib/src/theme/index.dart
    - lib/src/file_upload/model/upload_config.dart
    - lib/src/empty_data/models/index.dart
    - lib/lite_ui.dart
---

Lite UI 是一个轻量级 Flutter 组件库，其配置系统采用**声明式参数 + 主题注入**的架构模式，没有集中式的配置文件或环境变量管理，而是通过以下三种方式实现配置：

## 1. 组件级配置（Config 类）
每个功能模块都有独立的配置类，以不可变对象形式传递：
- **UploadConfig** (`lib/src/file_upload/model/upload_config.dart`)：文件上传配置，支持 auto/manual/custom 三种上传模式、并发数、重试次数、自定义上传函数等
- **EmptyConfig** (`lib/src/empty_data/models/index.dart`)：空状态页面配置，包含标题、描述、颜色、图标等
- 各组件通过构造函数参数接收这些配置对象

## 2. 全局主题配置（Theme System）
使用 Flutter 标准的 `InheritedWidget` 模式实现主题系统：
- **LiteUIThemeData**：定义库级别的默认样式数据（边框颜色、错误色、圆角半径、文字颜色等）
- **LiteUITheme**：作为 InheritedWidget 包裹应用，提供全局主题覆盖能力
- 组件通过 `LiteUITheme.of(context)` 获取当前主题，未设置时回退到 `LiteUIThemeData.defaults`

## 3. 默认值映射表
对于特定场景（如空状态），使用静态映射表提供类型化的默认配置：
- `emptyDataDefaults: Map<EmptyDataType, EmptyConfig>` 为每种空状态类型预设完整的视觉配置
- 组件内部通过 `_config => emptyDataDefaults[widget.type]!` 获取对应默认配置

## 设计特点
- **无外部依赖**：不依赖任何配置加载库（如 flutter_config、dotenv 等）
- **编译期安全**：所有配置都是强类型 Dart 类，利用 IDE 自动补全和类型检查
- **渐进式配置**：组件有合理的默认值，用户只需覆盖需要的字段
- **单一职责**：每个模块的配置独立管理，避免全局配置污染

## 开发者约定
- 新增组件应遵循相同的配置模式：定义 Config 类 → 提供默认值 → 通过构造函数注入
- 需要全局样式的组件应使用 LiteUITheme 而非硬编码颜色值
- 配置类应保持不可变性（final 字段 + const 构造函数）
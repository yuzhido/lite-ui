---
kind: frontend_style
name: LiteUI 主题系统与组件样式规范
category: frontend_style
scope:
    - '**'
source_files:
    - lib/src/theme/index.dart
    - lib/src/widgets/border_builder.dart
    - lib/lite_ui.dart
    - lib/src/models/enum.dart
    - lib/src/input_text/input_text.dart
---

## 1. 系统概述
LiteUI 是一个基于 Flutter 的轻量级自定义 UI 组件库，采用 **Flutter 原生主题机制 + InheritedWidget** 实现全局主题定制，所有组件通过统一的 `LiteUITheme` 上下文获取样式数据，确保视觉一致性。

## 2. 核心架构
- **主题数据模型**：`LiteUIThemeData` 定义库级别的默认颜色与样式（边框色、错误色、聚焦色、圆角半径、提示文字色、标签背景色等）
- **主题注入器**：`LiteUITheme` 继承自 `InheritedWidget`，提供 `of(context)` 静态方法从 Widget Tree 中读取主题数据
- **样式构建器**：如 `border_builder.dart` 中的 `buildInputOutlineBorder` 函数，统一处理边框类型、圆角、颜色等样式逻辑

## 3. 设计约定
- **组件结构模式**：每个组件遵循 `models/` + `ui/` + `index.dart` 的分层结构，UI 细节封装在子目录中
- **样式优先级**：组件属性 > LiteUITheme 默认值 > Flutter 系统主题
- **枚举驱动样式**：通过 `FormLayout`、`BorderType`、`DisplayMode` 等枚举控制组件行为与外观
- **无 CSS/SCSS**：完全使用 Dart 代码定义样式，符合 Flutter 原生开发范式

## 4. 关键文件
- `lib/src/theme/index.dart` - 主题数据与 InheritedWidget 实现
- `lib/src/widgets/border_builder.dart` - 统一边框构建器
- `lib/lite_ui.dart` - 公共 API 导出入口
- `lib/src/models/enum.dart` - 共享枚举定义
- `lib/src/input_text/input_text.dart` - 输入框组件示例（展示主题使用方式）

## 5. 开发者规范
- 所有颜色、尺寸应从 `LiteUITheme.of(context)` 获取，避免硬编码
- 新增组件需遵循现有目录结构，包含 models、ui、index 三层
- 样式变更应优先修改主题数据或构建器函数，保持组件内部简洁
- 支持通过组件属性覆盖主题默认值，提供灵活性
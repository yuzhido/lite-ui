---
kind: frontend_style
name: LiteUI Flutter 组件库主题与样式系统
category: frontend_style
scope:
    - '**'
source_files:
    - lib/src/theme/index.dart
    - lib/src/widgets/border_builder.dart
    - lib/src/models/enum.dart
    - lib/src/input_text/input_text.dart
    - lib/src/empty_data/ui/default_style.dart
    - analysis_options.yaml
---

## 样式系统与架构概述

LiteUI 是一个基于 Flutter 的轻量级自定义 UI 组件库，采用 **Flutter Material 3** 作为基础框架，通过自定义主题系统实现统一的视觉风格。

### 核心主题系统

- **LiteUIThemeData**: 定义库级别的默认颜色配置，包括边框颜色、错误状态颜色、聚焦边框颜色、圆角半径、提示文字颜色、主文字颜色和标签背景色
- **LiteUITheme**: 基于 InheritedWidget 的主题提供者，允许在应用层通过包裹方式全局自定义组件样式
- 主题数据通过 `LiteUITheme.of(context)` 静态方法在组件树中获取

### 样式约定与模式

1. **边框构建器**: `buildInputOutlineBorder()` 函数统一处理所有输入框的 OutlineInputBorder，支持默认/启用/聚焦三种状态
2. **枚举驱动样式**: 使用 `FormLayout`（row/column）、`BorderType`（border/enabledBorder/focusedBorder）、`DisplayMode`（text/tags/compact）等枚举控制组件行为
3. **硬编码样式值**: 组件内部直接使用 Color 字面量（如 `Color(0xFFE2E8F0)`、`Colors.black87`），未建立设计令牌系统
4. **Material 3 集成**: 示例应用使用 `ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED)), useMaterial3: true)`

### 组件样式组织

- 每个组件遵循 `src/component_name/ui/` 目录结构，将样式相关代码与业务逻辑分离
- EmptyData 组件提供多种预设样式：default_style、compact_style、minimal_style、card_style
- 通用样式工具集中在 `lib/src/widgets/` 目录下，如 border_builder.dart、clear_icon.dart、prefix_icon_label.dart

### 开发规范

- 使用 `flutter_lints` 进行代码质量检查
- 组件属性优先通过参数覆盖默认值，而非直接修改源码
- 颜色值应优先从 LiteUITheme 获取，保持主题一致性
- 响应式布局通过 Flutter 内置的 Flexible、Expanded 等组件实现
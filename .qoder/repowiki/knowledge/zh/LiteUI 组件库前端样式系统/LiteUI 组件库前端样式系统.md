---
kind: frontend_style
name: LiteUI 组件库前端样式系统
category: frontend_style
scope:
    - '**'
source_files:
    - lib/src/theme/index.dart
    - lib/src/widgets/border_builder.dart
    - lib/src/input_text/input_text.dart
    - lib/src/action_button/action_button.dart
    - lib/src/models/enum.dart
    - lib/src/empty_data/ui/card_style.dart
---

LiteUI 是一个基于 Flutter 的轻量级自定义 UI 组件库，其前端样式系统采用以下架构和约定：

## 主题系统架构

核心主题系统通过 `LiteUITheme`（InheritedWidget）和 `LiteUIThemeData` 实现全局样式配置。主题数据包含边框颜色、错误状态颜色、聚焦边框颜色、圆角半径、提示文字颜色和主文字颜色等设计令牌。

所有组件通过 `LiteUITheme.of(context)` 静态方法从 widget tree 中获取主题配置，未找到时回退到默认值 `LiteUIThemeData.defaults`。

## 样式构建模式

1. **统一边框构建器**：`border_builder.dart` 中的 `buildInputOutlineBorder` 函数提供统一的 OutlineInputBorder 构建逻辑，支持默认/启用/聚焦三种边框类型，自动处理错误状态和焦点状态的颜色切换。

2. **组件内联样式**：每个组件内部直接定义样式逻辑，如 `EmptyDataCardStyle` 使用 BoxDecoration、LinearGradient、BoxShadow 等原生 Flutter 样式属性。

3. **枚举驱动样式**：通过 `BorderType`、`FormLayout`、`DisplayMode`、`ActionButtonType` 等枚举控制组件的不同显示模式和行为。

## 组件样式约定

- **输入组件**：`InputText` 使用 TextFormField + InputDecoration 组合，通过 `buildInputOutlineBorder` 统一边框样式，支持浮动标签、前缀/后缀图标、密码模式等。
- **按钮组件**：`ActionButton` 封装 Flutter 原生按钮类型（ElevatedButton、OutlinedButton、TextButton、FilledButton、IconButton），统一高度为45px，内置加载状态管理。
- **空状态组件**：提供多种风格（card_style、compact_style、default_style、minimal_style），每种风格都是独立的 StatelessWidget。

## 设计令牌规范

- 默认边框颜色：`0xFFE2E8F0`
- 错误状态颜色：`0xFFEF4444`
- 默认圆角：5dp
- 提示文字颜色：`0x61000000`
- 主文字颜色：`Colors.black87`
- 标签背景色：`0xFF64748B`

## 响应式策略

组件主要依赖 Flutter 的 Material Design 自适应机制，通过 `Theme.of(context).colorScheme` 获取系统主题色作为焦点状态的备选颜色，确保与平台主题保持一致性。

## 开发约束

- 所有颜色必须通过 `LiteUITheme.of(context)` 获取，避免硬编码
- 边框样式统一使用 `buildInputOutlineBorder` 函数
- 组件参数优先使用枚举而非字符串
- 保持组件的无状态或简单状态管理，复杂逻辑下沉到 service/controller
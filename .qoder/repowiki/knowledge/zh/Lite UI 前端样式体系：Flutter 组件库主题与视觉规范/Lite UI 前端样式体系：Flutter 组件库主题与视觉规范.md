---
kind: frontend_style
name: Lite UI 前端样式体系：Flutter 组件库主题与视觉规范
category: frontend_style
scope:
    - '**'
source_files:
    - lib/src/theme/index.dart
    - lib/lite_ui.dart
    - lib/src/widgets/border_builder.dart
    - lib/src/empty_data/models/index.dart
    - lib/src/empty_data/ui/default_style.dart
    - lib/src/empty_data/ui/card_style.dart
    - lib/src/input_text/input_text.dart
    - lib/src/widgets/empty_state.dart
    - example/lib/main.dart
---

## 1. 系统与方法论
该仓库是一个基于 Flutter 的轻量级 UI 组件库，采用 **纯 Dart/Flutter 原生样式方案**，不使用 CSS、SCSS、Tailwind 等 Web 样式技术。整体风格由以下机制统一控制：
- **自定义主题 InheritedWidget**：通过 `LiteUITheme` + `LiteUIThemeData` 提供全局颜色、圆角、边框等设计令牌（Design Tokens），组件内部通过 `LiteUITheme.of(context)` 读取。
- **统一的边框构建器**：`buildInputOutlineBorder` 将 OutlineInputBorder 的默认/聚焦/错误状态颜色与圆角集中管理，确保输入类组件视觉一致。
- **多风格策略模式**：以 EmptyData 为例，通过 `EmptyDataType`、`EmptyDataStyle` 枚举 + `EmptyConfig`/`EmptyDataStyleParams` 参数对象，实现同一组件的多套视觉风格（default/compact/card/minimal）可插拔切换。
- **示例应用驱动演示**：example 目录使用 Material3 种子色 `0xFF7C3A6A` 作为 App 主题基色，展示各组件在真实业务场景中的用法。

## 2. 核心文件与包
- 主题入口：`lib/src/theme/index.dart` — 定义 `LiteUIThemeData` 与 `LiteUITheme` InheritedWidget
- 公共导出：`lib/lite_ui.dart` — 统一暴露所有组件、模型、工具与主题
- 边框构建器：`lib/src/widgets/border_builder.dart` — 统一 OutlineInputBorder 生成逻辑
- 空状态多风格：`lib/src/empty_data/ui/default_style.dart`、`card_style.dart`、`compact_style.dart`、`minimal_style.dart`
- 空状态数据模型：`lib/src/empty_data/models/index.dart` — 枚举、默认配置表、共享参数对象
- 输入组件（样式最丰富）：`lib/src/input_text/input_text.dart` — 集成主题、校验、浮动标签、前后缀图标
- 通用占位组件：`lib/src/widgets/empty_state.dart` — 轻量版空状态
- 示例入口：`example/lib/main.dart` — Material3 主题配置与页面导航

## 3. 架构与约定
- **组件内聚结构**：每个组件按 `models/`、`ui/`、`widgets/`、`utils/` 分层组织，UI 与逻辑分离，便于复用与测试。
- **主题优先原则**：组件不硬编码颜色值，而是从 `LiteUITheme` 或 `Theme.of(context)` 获取，保证可定制性。
- **参数聚合模式**：复杂组件（如 EmptyData）通过 `*Params` 对象聚合多个样式属性，避免构造函数膨胀。
- **枚举驱动行为**：通过 `EmptyDataType`、`ValidRuleType`、`FormLayout`、`InputType` 等枚举统一控制组件行为与样式分支。
- **无外部样式依赖**：不引入第三方样式框架，所有视觉表现由 Flutter 原生 Widget 组合实现。

## 4. 开发者应遵循的规则
- **颜色与圆角必须通过 LiteUITheme 访问**，禁止在组件内直接写死 Color 常量（除默认值外）。
- **新增组件需支持主题覆盖**：至少暴露 borderColor、errorColor、borderRadius 等关键样式参数。
- **复杂样式用参数对象封装**：当组件样式参数超过 5 个时，考虑引入 `*Params` 类聚合。
- **保持向后兼容**：修改默认主题值时需评估对现有使用者的影响，必要时提供迁移指南。
- **示例代码需覆盖主要样式变体**：在 example/pages 中为每个组件提供多种配置示例。
- **禁用 CSS/SCSS 思维**：Flutter 样式通过 Widget 树与 BoxDecoration 组合，而非选择器与层叠规则。
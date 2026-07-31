---
kind: frontend_style
name: LiteUI Flutter 组件库主题与样式系统
category: frontend_style
scope:
    - '**'
source_files:
    - lib/src/theme/index.dart
    - lib/src/widgets/border_builder.dart
    - lib/src/input_text/input_text.dart
    - lib/src/empty_data/ui/default_style.dart
    - lib/lite_ui.dart
    - pubspec.yaml
---

## 1. 系统/方法概述
该仓库是一个基于 Flutter 的轻量级自定义 UI 组件库，采用纯 Dart + Material 风格构建，不使用 CSS/SCSS/Tailwind 等 Web 样式方案。样式体系围绕 LiteUITheme 主题数据与 InheritedWidget 机制实现，所有组件通过统一的主题 API 获取颜色、圆角等设计令牌（design tokens），保证跨组件视觉一致性。

## 2. 核心文件与包
- lib/src/theme/index.dart — 定义 LiteUIThemeData 主题数据类与 LiteUITheme InheritedWidget，提供 borderColor、errorColor、focusBorderColor、borderRadius、hintColor、textColor、tagColor 等设计令牌，并提供 defaults 默认值与静态 of(context) 读取方法。
- lib/src/widgets/border_builder.dart — 统一的 OutlineInputBorder 构建器 buildInputOutlineBorder，集中处理边框类型、圆角、错误态与聚焦态颜色。
- lib/src/input_text/input_text.dart — 输入框组件，全面使用 LiteUITheme 的颜色与圆角，并通过 FormField 集成校验与浮动标签。
- lib/src/empty_data/ui/default_style.dart — 空状态组件示例，展示硬编码样式与参数化样式的结合方式。
- lib/lite_ui.dart — 库的统一导出入口，集中暴露组件、主题、模型与工具。
- pubspec.yaml — 声明依赖 file_picker、image_picker，SDK 约束 flutter >= 1.17.0、dart ^3.12.2。

## 3. 架构与约定
- 主题驱动：所有组件通过 LiteUITheme.of(context) 读取主题色与圆角，未显式传入的参数自动回退到主题默认值或系统主题色。
- 组件内聚结构：每个功能模块按 models/ui/utils/index.dart 分层组织，如 input_text、dialog_action、file_upload、tree_select 等，UI 层集中在 ui/ 子目录。
- 边框与状态统一：buildInputOutlineBorder 将边框绘制逻辑收敛，支持 BorderType.border/enabledBorder/focusedBorder 三种状态，错误态优先覆盖主题 errorColor。
- 表单与校验：InputText 基于 FormField 与 ValidRules 组合规则，支持枚举式 validRuleType 与自定义 validRules，autoValidate 模式可配置。
- 无外部样式框架：不引入 CSS/SCSS/Tailwind，样式全部以 Dart Widget 属性与 TextStyle/BoxDecoration 表达。

## 4. 开发者应遵循的规则
- 主题使用：在 App 层用 LiteUITheme(data: LiteUIThemeData(...)) 包裹根节点，组件中通过 LiteUITheme.of(context) 读取颜色与圆角，避免硬编码 Color。
- 边框与圆角：优先使用 buildInputOutlineBorder 构建 InputDecorator 的 border/enabledBorder/focusedBorder，确保状态切换一致。
- 组件参数：颜色类参数（borderColor、errorColor、focusBorderColor）均支持覆盖主题默认值；未传参时回退到 LiteUITheme.defaults。
- 表单校验：使用 validRuleType 快速配置常见规则，复杂场景通过 validRules 列表扩展；required 字段自动添加必填校验。
- 布局与间距：组件内部使用 spacing/padding 控制间距，避免在业务层重复计算；文本样式通过 TextStyle 参数传入，保持可读性。
- 导出规范：新增组件需在对应 index.dart 中导出，并在 lib/lite_ui.dart 中统一暴露，保持库入口整洁。
- 平台兼容：依赖 flutter >= 1.17.0，注意旧版本 Material API 差异；新特性优先使用 withValues(alpha:) 等稳定 API。

置信度：high — 代码中存在明确的主题系统、统一边框构建器与一致的组件组织模式，证据充分且贯穿多个模块。
---
kind: frontend_style
name: LiteUI 主题系统与组件样式规范
category: frontend_style
scope:
    - '**'
source_files:
    - lib/src/theme/index.dart
    - lib/src/widgets/border_builder.dart
    - lib/src/input_text/input_text.dart
    - lib/src/action_button/action_button.dart
    - lib/src/empty_data/ui/card_style.dart
    - lib/src/empty_data/ui/default_style.dart
    - lib/src/empty_data/ui/minimal_style.dart
    - lib/lite_ui.dart
---

## 1. 使用的系统/方法
- Flutter Material 3：所有组件基于 Flutter 原生 Material 组件（ElevatedButton、OutlinedButton、TextButton、FilledButton、IconButton、InputDecoration 等）进行二次封装，遵循 Material Design 规范。
- 自定义主题系统：通过 LiteUITheme（InheritedWidget）+ LiteUIThemeData 实现库级主题注入，支持全局覆盖颜色、圆角等设计令牌。
- 无 CSS/SCSS：纯 Dart 代码实现样式，未使用任何外部样式框架。

## 2. 核心文件与包
- 主题定义：lib/src/theme/index.dart — LiteUIThemeData 与 LiteUITheme InheritedWidget
- 边框构建器：lib/src/widgets/border_builder.dart — 统一的 OutlineInputBorder 生成逻辑
- 输入框组件：lib/src/input_text/input_text.dart — 最复杂的表单组件，体现主题集成方式
- 按钮组件：lib/src/action_button/action_button.dart — 多类型按钮封装
- 空状态风格：lib/src/empty_data/ui/{card_style,default_style,minimal_style,compact_style}.dart — 多种视觉风格实现
- 公共导出：lib/lite_ui.dart — 统一对外暴露 API

## 3. 架构与约定
### 主题系统架构
LiteUITheme (InheritedWidget) -> LiteUIThemeData (设计令牌: borderColor, errorColor, focusBorderColor, borderRadius, hintColor, textColor, tagColor)

### 组件样式约定
- 颜色优先级：组件参数 > LiteUITheme > Flutter Theme.of(context) 默认值
- 边框构建：通过 buildInputOutlineBorder() 统一处理 border/enabledBorder/focusedBorder/error 状态
- 状态管理：组件内部维护 _isLoading、isShowPassword 等局部状态
- 样式组合：通过 ButtonStyle、TextStyle、BoxDecoration 等 Material 标准样式对象组合

### 组件组织模式
每个组件采用 src/<component>/ 目录结构：index.dart（对外导出）、<component>.dart（主组件实现）、models/（数据模型）、ui/（UI 实现，可包含多个 style 变体）、utils/（工具函数）

## 4. 开发者应遵循的规则
### 主题使用规则
1. 优先从 LiteUITheme 读取颜色：使用 LiteUITheme.of(context).borderColor 而非硬编码 Color
2. 允许组件参数覆盖：组件属性应支持传入具体颜色，覆盖主题默认值
3. fallback 到系统主题：当 focusBorderColor 为 null 时回退到 Theme.of(context).colorScheme.primary

### 样式开发规则
1. 使用 Material 标准样式对象：ButtonStyle、TextStyle、BoxDecoration、InputDecoration
2. 统一边框构建：表单类组件必须使用 buildInputOutlineBorder() 生成边框
3. 圆角一致性：默认使用 LiteUIThemeData.borderRadius（默认 5），可通过组件参数覆盖
4. 阴影与渐变：使用 withValues(alpha: x) 替代已废弃的 withOpacity()

### 组件开发约定
1. 保持向后兼容：新增样式参数应有默认值，不破坏现有 API
2. 支持无障碍：关键组件添加 Semantics 标签（如 EmptyData 组件）
3. 响应式布局：使用 Flexible、Expanded、MediaQuery 适配不同屏幕
4. 状态隔离：组件内部状态与外部 controller 分离管理

### 设计令牌扩展
如需新增设计令牌，应在 LiteUIThemeData 中添加字段，并在相关组件中引用，确保全局一致性。
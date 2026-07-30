---
kind: frontend_style
name: Lite UI 组件库前端样式体系
category: frontend_style
scope:
    - '**'
source_files:
    - lib/src/theme/index.dart
    - lib/src/widgets/border_builder.dart
    - lib/src/input_text/input_text.dart
    - lib/src/empty_data/ui/default_style.dart
    - lib/src/empty_data/ui/card_style.dart
---

## 样式系统概述

Lite UI 是一个基于 Flutter 的轻量级组件库，采用 **Flutter Material Design** 作为基础样式框架，通过自定义主题系统和组件内样式管理实现视觉一致性。

## 核心样式架构

### 1. 主题系统（Theme System）
- **主题数据模型**：`LiteUIThemeData` 定义全局设计令牌，包括边框颜色、错误状态颜色、圆角半径、提示文字颜色、主文字颜色和标签背景色
- **主题提供者**：`LiteUIThreme` 作为 `InheritedWidget` 提供主题数据访问
- **默认值策略**：所有主题属性都有合理的默认值，确保组件在无主题包裹时仍可正常工作

### 2. 样式构建工具
- **边框构建器**：`buildInputOutlineBorder()` 统一处理输入框边框样式，支持默认/聚焦/错误三种状态
- **样式继承**：组件优先使用传入参数，其次读取主题配置，最后回退到默认值

### 3. 组件样式模式
- **硬编码样式**：组件内部直接使用 `Color`、`TextStyle`、`BoxDecoration` 等 Flutter 原生样式
- **样式变体**：如 `EmptyData` 组件提供 `default_style`、`card_style`、`compact_style`、`minimal_style` 等多种视觉风格
- **配置驱动**：通过 `params` 和 `config` 对象传递样式配置，保持组件接口简洁

## 设计令牌规范

### 颜色系统
- **边框颜色**：默认 `0xFFE2E8F0`（浅灰色）
- **错误颜色**：默认 `0xFFEF4444`（红色）
- **主文字颜色**：默认 `Colors.black87`
- **提示文字颜色**：默认 `0x61000000`（半透明黑色）
- **标签背景色**：默认 `0xFF64748B`（中灰色）

### 尺寸规范
- **默认圆角**：5px
- **输入框边框宽度**：1.5px
- **图标尺寸**：根据容器自适应，常用 64-88px

## 组件样式约定

### 输入组件样式
- 使用 `InputText` 组件统一表单输入样式
- 支持浮动标签、前缀/后缀图标、密码显示切换
- 内置多种输入类型验证和格式化

### 空状态组件
- 提供多种视觉风格：默认居中、卡片式、紧凑式、极简式
- 支持自定义图标、背景色、阴影效果
- 包含语义化标签提升可访问性

### 弹窗与选择器
- 统一的底部操作面板样式
- 树形选择器的层级缩进和展开动画
- 文件上传组件的卡片列表展示

## 开发规范

### 样式优先级
1. 组件参数直接传入的样式
2. 从 `LiteUITheme` 读取的主题配置
3. 组件内部的默认样式

### 颜色使用规范
- 避免在组件内部硬编码颜色值
- 优先使用主题提供的颜色令牌
- 需要特殊颜色时通过组件参数传入

### 响应式设计
- 使用相对单位而非固定像素
- 利用 Flutter 的布局约束系统
- 考虑不同屏幕尺寸的适配

## 示例应用集成
示例应用使用 Material 3 主题系统，通过 `MaterialApp` 的 `theme` 属性配置全局样式，与 Lite UI 主题系统协同工作。
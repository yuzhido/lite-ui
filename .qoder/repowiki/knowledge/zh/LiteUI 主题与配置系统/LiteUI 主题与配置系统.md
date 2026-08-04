---
kind: configuration_system
name: LiteUI 主题与配置系统
category: configuration_system
scope:
    - '**'
source_files:
    - lib/src/theme/index.dart
    - lib/lite_ui.dart
    - lib/src/file_upload/model/upload_config.dart
---

LiteUI 组件库采用基于 Flutter InheritedWidget 的主题配置系统，通过 `LiteUITheme` 和 `LiteUIThemeData` 实现库级别的样式定制。该系统的核心设计如下：

**主题数据模型**：`LiteUIThemeData` 类定义了库组件的默认样式配置，包括边框颜色（borderColor）、错误状态颜色（errorColor）、聚焦边框颜色（focusBorderColor）、圆角半径（borderRadius）、提示文字颜色（hintColor）、主文字颜色（textColor）和标签背景色（tagColor）。所有属性都提供合理的默认值，确保组件在无主题包裹时也能正常显示。

**主题注入机制**：`LiteUITheme` 作为 InheritedWidget 封装主题数据，通过静态方法 `LiteUITheme.of(context)` 在组件树中获取当前主题。如果未找到 LiteUITheme，则自动回退到 `LiteUIThemeData.defaults`，保证配置的健壮性。

**使用方式**：应用层通过 `LiteUITheme` 包裹整个应用或特定组件树，传入自定义的 `LiteUIThemeData` 来统一修改组件外观。这种设计与 Flutter 原生 Theme 系统保持一致，降低了学习成本。

**配置模式**：除了主题配置外，库中的功能模块（如文件上传）采用参数化配置模式，通过专门的配置类（如 `UploadConfig`）传递运行时配置，支持多种模式和回调函数，提供了灵活的扩展能力。

**导出结构**：主题相关代码集中在 `lib/src/theme/index.dart`，并通过主入口 `lite_ui.dart` 统一导出，遵循了单一职责原则和清晰的模块边界。
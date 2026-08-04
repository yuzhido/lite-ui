---
kind: logging_system
name: 日志系统：无专用日志框架，仅使用 print/debugPrint 调试输出
category: logging_system
scope:
    - '**'
source_files:
    - pubspec.yaml
    - lib/lite_ui.dart
---

本仓库是一个轻量级 Flutter UI 组件库（lite_ui），未实现专门的日志系统。代码中没有任何第三方日志框架（如 logging、logger、loggy 等）的引入或初始化，也没有统一的日志工具类、日志级别管理或结构化日志输出。

现有日志相关用法如下：
- 示例工程（example/）中使用 print() 和 debugPrint() 进行简单的调试输出，例如在表单回调中打印用户输入值。
- 核心库代码（lib/src/...）中未发现任何日志语句，组件内部不主动输出日志。
- pubspec.yaml 依赖中不包含任何日志相关包。

这意味着该库遵循零依赖、纯 UI 的设计原则，将日志责任完全交给使用者。如果需要在生产环境中添加日志能力，建议由集成方自行引入合适的日志框架（如 logger、logging 等），并在应用启动时统一配置。
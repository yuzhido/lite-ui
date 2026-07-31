---
kind: logging_system
name: 日志系统 — 无专用日志框架，仅使用 print/debugPrint
category: logging_system
scope:
    - '**'
source_files:
    - pubspec.yaml
    - lib/lite_ui.dart
---

该仓库为轻量级 Flutter UI 组件库（lite_ui），在 lib/src 下的所有业务组件中未发现任何专用的日志框架或结构化日志实现。代码中未引入 logging、logger、loggy 等第三方日志包，也未定义统一的 Logger 类或日志工具模块。

实际输出方式：
- 示例应用（example/lib）中使用 print() 和 debugPrint() 进行简单调试输出，主要用于演示回调值打印。
- 核心库代码（lib/src）中未包含任何日志语句，符合 UI 组件库“零侵入、零依赖”的设计原则。

结论：该仓库不存在专门的日志系统。作为 UI 组件库，它不内置日志功能，使用者可在自己的应用中按需集成日志方案。
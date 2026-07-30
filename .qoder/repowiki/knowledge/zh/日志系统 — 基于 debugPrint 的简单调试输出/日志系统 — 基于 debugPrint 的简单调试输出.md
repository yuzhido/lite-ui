---
kind: logging_system
name: 日志系统 — 基于 debugPrint 的简单调试输出
category: logging_system
scope:
    - '**'
source_files:
    - lib/src/file_upload/service/upload_controller.dart
    - lib/src/file_upload/service/upload_service.dart
    - lib/src/file_upload/utils/file_utils.dart
    - lib/src/file_upload/widgets/list_show_file.dart
    - lib/src/dropdown_choose/dropdown_choose.dart
    - example/lib/pages/back.dart
    - example/lib/pages/component_demo.dart
---

该 Flutter 组件库未引入专门的日志框架（如 `logger`、`logging`、`loggy` 等），也没有统一的日志模块或配置。代码中的日志输出完全依赖 Flutter 内置的 `debugPrint`，且仅用于开发调试目的。

**使用方式与分布**
- 主要出现在 `lib/src/file_upload/` 目录下的服务与工具类中，例如 `upload_controller.dart`、`upload_service.dart`、`file_utils.dart`、`list_show_file.dart` 等文件。
- 示例应用 `example/lib/pages/*.dart` 中也散落着 `print()` 和 `debugPrint` 调用，用于演示回调打印。
- 核心 UI 组件（如 `dropdown_choose`）中存在少量硬编码的 `print(12121213131)` 调试语句。

**日志格式与约定**
- 采用 `[ClassName] 描述信息: key=value` 的简单前缀格式，便于在控制台快速定位来源。
- 所有日志均为字符串拼接，无结构化字段、无日志级别、无输出目标抽象。

**设计决策**
- 作为轻量级 UI 组件库，未引入额外依赖来管理日志。
- 所有日志均通过 `debugPrint` 输出，仅在 Debug 模式下可见，Release 构建时自动移除。
- 没有全局日志开关、格式化器或 Sink 抽象，开发者无法统一控制输出。

**开发者应遵循的规则**
- 如需新增日志，建议沿用 `[ClassName] 描述: key=value` 的前缀风格，保持可读性。
- 避免在生产环境中保留敏感信息，因为 `debugPrint` 在 Release 下虽不输出，但代码仍会执行。
- 不建议为组件库本身添加复杂日志逻辑，保持轻量原则。

由于该项目是纯 UI 组件库且未实现任何日志抽象层，此类别的实际适用性较低。
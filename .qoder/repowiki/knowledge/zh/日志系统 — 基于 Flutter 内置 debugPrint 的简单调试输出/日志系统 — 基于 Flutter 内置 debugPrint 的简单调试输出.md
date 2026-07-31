---
kind: logging_system
name: 日志系统 — 基于 Flutter 内置 debugPrint 的简单调试输出
category: logging_system
scope:
    - '**'
source_files:
    - lib/src/file_upload/service/upload_controller.dart
    - lib/src/file_upload/service/upload_service.dart
    - lib/src/file_upload/utils/file_utils.dart
    - lib/src/file_upload/widgets/show_file.dart
    - lib/src/file_upload/widgets/show_image.dart
---

该仓库未实现专门的日志框架或统一的日志系统，所有调试输出均直接使用 Flutter 内置的 `debugPrint` 和 `print` 函数，属于最基础的打印式调试方式。

**使用方式与分布**
- 核心库代码（`lib/src/`）中仅在文件上传模块（`file_upload/service/upload_controller.dart`、`upload_service.dart`、`utils/file_utils.dart`、`widgets/show_file.dart`、`show_image.dart` 等）中使用 `debugPrint` 输出调试信息，其余组件未包含任何日志输出。
- 示例应用（`example/lib/`）中广泛使用 `print` 和 `debugPrint` 进行交互反馈，如表单回调、按钮点击等场景。

**日志格式约定**
- 采用 `[类名] 描述: key=value` 的简单结构化字符串格式，例如：`[UploadController] 文件路径为空，无法上传: id=$id`、`[UploadService] 开始上传: url=$url, fileName=$fileName, method=$method`。
- 关键上下文信息（如 id、url、size、statusCode 等）以键值对形式拼接在消息末尾，便于快速定位问题。

**设计决策与限制**
- 未引入第三方日志库（如 `logger`、`logging`），也未定义统一的 Logger 类或日志级别枚举。
- 未区分生产/开发环境，所有 `debugPrint` 语句直接嵌入业务代码，无开关控制。
- 未实现日志分级（info/warn/error）、异步写入、文件落盘或远程上报等功能。

**开发者应遵循的约定**
- 如需新增日志，建议沿用 `[ClassName] message: key=value` 的统一格式，保持可读性。
- 由于当前为纯调试用途，建议在发布前清理或条件编译掉不必要的 `debugPrint`，避免影响性能。
- 若未来需要正式日志系统，可考虑抽象出统一 Logger 接口，替换现有分散的 `debugPrint` 调用。
---
kind: error_handling
name: Flutter UI 组件库的错误处理策略
category: error_handling
scope:
    - '**'
source_files:
    - lib/src/input_text/input_text.dart
    - lib/src/input_text/models/enum.dart
    - lib/src/file_upload/model/upload_config.dart
    - lib/src/file_upload/service/upload_service.dart
    - lib/src/file_upload/service/upload_controller.dart
    - lib/src/file_upload/model/enum.dart
    - lib/src/empty_data/models/index.dart
    - lib/src/dropdown_choose/dropdown_choose.dart
    - lib/src/tree_select/tree_select.dart
---

LiteUI 作为轻量级 Flutter UI 组件库，其错误处理主要围绕**表单校验错误展示**和**文件上传异常处理**两个核心场景展开，采用状态驱动 + 枚举分类的轻量模式，未定义全局异常类型或统一错误码体系。

### 1. 表单输入错误：基于 State 的 hasError/errorText 模式

- **InputText、DropdownChoose、TreeSelect** 等输入类组件均通过内部 state 管理 `hasError` 布尔标志与 `errorText` 字符串，校验失败时设置这两个字段，UI 层根据 `state.hasError` 决定是否渲染红色错误文本。
- 错误颜色统一通过 `LiteUITheme.of(context).errorColor` 获取，支持 widget 级别覆盖 `errorColor` 参数。
- 校验逻辑集中在 `input_text/utils/valid_rules.dart`，通过 `ValidRuleType` 枚举（phone/email/idCard/url/numeric/decimal/integer/chineseName/password/custom）组合内置规则，自定义规则以 `List<String? Function(String?)>` 形式传入。

### 2. 文件上传错误：UploadResult 结果对象 + 分层捕获

- **UploadService**（HTTP 上传）使用 `try/catch` 分层捕获：`SocketException` → 网络连接失败；`HttpException` → HTTP 请求异常；通用 `catch` → 未知异常。所有异常均转换为 `UploadResult.failure(error: ...)` 返回。
- **UploadController** 负责重试逻辑（`retryCount` 次）、并发控制（`maxConcurrent`）和取消支持，将网络层错误透传为业务层的 `UploadStatus.failed` 状态。
- **UploadResult** 是统一的上传结果载体，包含 `success`、`data`（已解析 JSON Map）、`error`（错误信息字符串），提供 `success()`、`failure()`、`successFromRaw()` 工厂方法。
- Web 平台因 `dart:io` 限制，需通过 `UploadMode.custom` 提供自定义上传函数，错误由调用方自行处理。

### 3. 空状态错误：EmptyDataType 枚举分类

- **EmptyData** 组件通过 `EmptyDataType.error` 表示加载失败场景，配合预定义的 `EmptyConfig`（标题、描述、图标、颜色）快速展示错误占位界面。
- 其他错误场景如 `noNetwork`、`noPermission`、`maintenance` 等均以枚举值区分，便于业务层根据错误类型选择对应 UI。

### 4. 设计约定与约束

- **不抛异常**：组件层避免 `throw`，而是通过返回值（如 `UploadResult`）或状态字段（`hasError`）传递错误信息。
- **调试输出**：关键错误路径使用 `debugPrint` 打印上下文信息（如 `[UploadService] 上传失败: id=$id, error=${result?.error}`），便于开发阶段排查。
- **无全局错误处理器**：未发现 `runZonedGuarded`、`FlutterError.onError` 或自定义 `ErrorWidget.builder` 的使用，错误处理分散在各组件内部。
- **主题化错误色**：错误颜色依赖 `LiteUITheme` 的 `errorColor`，确保视觉一致性。

### 5. 开发者应遵循的规则

- 输入组件校验失败时设置 `state.hasError = true` 和 `state.errorText = '错误提示'`，不要直接 `throw`。
- 网络/IO 操作使用 `try/catch` 捕获并转换为业务友好的错误消息，避免原始异常上抛。
- 需要区分错误类型时使用枚举（如 `EmptyDataType`、`UploadStatus`），而非字符串常量。
- 在 `catch` 块中保留 `debugPrint` 以便调试，但生产环境不应依赖日志作为用户反馈。
- 自定义上传函数（`customUpload`）必须返回 `UploadResult`，成功用 `UploadResult.success(data: ...)`, 失败用 `UploadResult.failure(error: ...)`。
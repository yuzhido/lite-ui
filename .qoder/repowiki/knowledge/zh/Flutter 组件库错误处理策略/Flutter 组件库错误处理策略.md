---
kind: error_handling
name: Flutter 组件库错误处理策略
category: error_handling
scope:
    - '**'
source_files:
    - lib/src/file_upload/model/upload_config.dart
    - lib/src/file_upload/service/upload_service.dart
    - lib/src/empty_data/models/index.dart
    - lib/src/input_text/utils/valid_rules.dart
    - lib/src/action_button/action_button.dart
    - lib/src/dropdown_choose/ui/modal_content.dart
---

LiteUI 组件库采用**结果对象 + 枚举状态 + 回调通知**的轻量级错误处理模式，未定义全局异常类型或统一的错误码体系。核心设计思想是将错误作为正常返回值的一部分，而非通过抛出异常来中断流程。

## 主要错误处理方式

### 1. 上传模块：UploadResult 结果对象
`lib/src/file_upload/model/upload_config.dart` 中的 `UploadResult` 类是典型的结果对象模式：
- 使用 `success` 布尔值标识成功/失败
- 成功时携带 `data`（解析后的 JSON Map）
- 失败时携带 `error`（字符串错误消息）
- 提供 `UploadResult.success()` 和 `UploadResult.failure(error: ...)` 工厂方法

`lib/src/file_upload/service/upload_service.dart` 中所有网络异常都被捕获并转换为 `UploadResult.failure`：
```dart
} on SocketException catch (e) {
  return UploadResult.failure(error: '网络连接失败: ${e.message}');
} on HttpException catch (e) {
  return UploadResult.failure(error: 'HTTP 请求异常: ${e.message}');
} catch (e) {
  return UploadResult.failure(error: e.toString());
}```

### 2. 空状态展示：EmptyDataType 枚举
`lib/src/empty_data/models/index.dart` 定义了完整的空状态类型枚举：
- `empty`、`search`、`noNetwork`、`error`、`noPermission`、`noMessage`、`noOrder`、`maintenance`
- 每种类型都有对应的默认配置（标题、描述、图标、颜色等）
- 通过 `EmptyConfig` 类和 `emptyDataDefaults` 映射表统一管理

### 3. 输入验证：ValidRules 工具类
`lib/src/input_text/utils/valid_rules.dart` 提供了一套完整的表单验证规则：
- 每个验证函数返回 `String?`（null 表示验证通过，非 null 为错误消息）
- 支持组合验证：`ValidRules.compose()` 依次执行多个规则
- 内置常见验证：手机号、邮箱、身份证号、URL、密码等
- 提供 `buildRules()` 工厂方法根据 `ValidRuleType` 自动生成验证规则列表

### 4. UI 层错误反馈
- **Action Button**：通过 `_isLoading` 状态和 `try-finally` 块管理异步操作状态，确保无论成功失败都恢复按钮状态
- **Dropdown Choose**：远程搜索时使用 `try-catch` 包裹，失败时清空结果并设置加载状态为 false
- **Input Text**：校验失败时通过 `state.errorText` 显示错误信息，配合主题系统的 `errorColor`

## 架构约定

1. **不抛异常原则**：业务逻辑层避免抛出异常，而是返回明确的结果对象
2. **错误消息本地化**：所有错误消息都是硬编码的中文文本，便于直接展示给用户
3. **状态驱动 UI**：通过组件内部状态（如 `_isLoading`、`_hasError`）控制 UI 表现
4. **渐进式错误处理**：从输入验证 → 业务逻辑 → 网络请求 → UI 展示，逐层处理错误
5. **无全局错误处理器**：没有统一的全局异常捕获或错误上报机制

## 开发者规范

- 自定义组件应遵循 `UploadResult` 模式，使用结果对象而非异常
- 表单验证应返回 `String?` 类型的错误消息
- 网络请求应使用 try-catch 包裹，将异常转换为友好的错误消息
- 利用 `EmptyDataType` 枚举统一处理各种空状态场景
- 避免使用 `throw` 和 `panic`，保持 Flutter 组件的稳定性
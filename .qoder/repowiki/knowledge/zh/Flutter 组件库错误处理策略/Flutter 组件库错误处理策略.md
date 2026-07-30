---
kind: error_handling
name: Flutter 组件库错误处理策略
category: error_handling
scope:
    - '**'
source_files:
    - lib/src/file_upload/model/upload_config.dart
    - lib/src/empty_data/models/index.dart
    - lib/src/dialog_action/models/index.dart
    - lib/src/input_text/utils/valid_rules.dart
    - lib/src/dropdown_choose/ui/select_modal_content.dart
---

该 Flutter 轻量级 UI 组件库采用**结果对象模式**和**枚举状态**相结合的方式处理错误，没有统一的异常体系或全局错误中间件。具体策略如下：

## 核心模式

### 1. 上传结果对象（UploadResult）
在 `lib/src/file_upload/model/upload_config.dart` 中定义了 `UploadResult` 类，通过 `success` 布尔字段和可选的 `error` 字符串来区分成功与失败：
- `UploadResult.success(data: ...)` - 成功结果
- `UploadResult.failure(error: ...)` - 失败结果
- `UploadResult.successFromRaw(rawBody)` - 从原始响应解析

### 2. 空状态枚举（EmptyDataType）
在 `lib/src/empty_data/models/index.dart` 中定义了多种空状态类型：
- `empty` - 默认空状态
- `search` - 搜索无结果
- `noNetwork` - 网络异常
- `error` - 加载失败/错误
- `noPermission` - 无访问权限
- `maintenance` - 系统维护

每种状态都有对应的 `EmptyConfig` 配置，包含标题、描述、图标、颜色等。

### 3. 弹窗预设图标（DialogPresetIcon）
在 `lib/src/dialog_action/models/index.dart` 中定义了四种预设图标：
- `success` - 成功（绿色勾选）
- `warning` - 警告（橙色三角感叹号）
- `error` - 错误（红色叉号）
- `info` - 信息（蓝色圆圈 i）

## 错误传播方式

### 1. try-catch 局部处理
在 `select_modal_content.dart` 中使用 try-catch 捕获远程搜索异常，将错误状态转换为空列表显示。

### 2. 回调参数传递
表单验证规则（`ValidRules`）返回 `String?` 类型的错误消息，通过回调传递给 UI 层展示。

### 3. 状态字段
组件内部使用状态字段（如 `hasError`、`errorText`）来管理错误状态，UI 根据这些状态渲染相应的错误提示。

## 设计特点

- **无抛出异常**：组件库避免使用 throw 抛出异常，而是通过返回值和状态字段传递错误信息
- **用户友好**：所有错误都转换为可理解的中文提示信息
- **渐进降级**：当数据获取失败时，提供空状态页面而非崩溃
- **类型安全**：使用枚举和泛型确保错误处理的类型安全

## 开发者约定

1. 组件内部错误应转换为状态字段，不向外抛出异常
2. 网络请求错误统一包装为 `UploadResult.failure()`
3. 用户输入验证返回错误消息字符串
4. 空状态使用预定义的枚举类型保持一致性
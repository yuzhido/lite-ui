# FileUpload 文件上传组件

轻量级 Flutter 文件上传组件，支持文件选择、图片选择、拍照上传，提供卡片/列表/自定义三种展示模式，内置自动上传、手动上传、自定义上传三种模式。

## 功能特性

- **多种文件来源**：支持文件选择器、相册、拍照，或弹窗组合选择
- **三种展示模式**：卡片网格（card）、横向列表（textInfo）、自定义（custom）
- **上传模式灵活**：自动上传（auto）、手动上传（manual）、自定义上传函数（custom）
- **文件状态管理**：待上传 / 上传中 / 上传成功 / 上传失败，完整生命周期管理
- **数量限制**：支持设置上传数量上限，达到上限后自动隐藏上传按钮
- **多选/单选**：支持多选或单选模式
- **文件类型过滤**：支持按扩展名过滤可选文件
- **编辑模式回显**：通过 `fileList` 传入已有文件列表，直接展示已上传文件
- **文件操作**：点击已上传成功的卡片可弹出操作 Sheet（替换 / 删除）
- **进度回调**：实时上报上传进度（0.0 ~ 1.0）
- **自定义样式**：支持自定义卡片尺寸、列数、间距、圆角、按钮装饰等

## 基础用法

### 仅选择文件（不上传）

不传 `uploadConfig` 时，组件仅提供文件选择能力，不涉及上传逻辑：

```dart
FileUpload(
  pickFile: PickFile.all,
  onFileChanged: (files, action) {
    print('当前文件列表：$files，动作：$action');
  },
)
```

### 自动上传

选择文件后自动开始上传，需提供上传接口地址：

```dart
FileUpload(
  pickFile: PickFile.imageOrCamera,
  uploadConfig: UploadConfig(
    mode: UploadMode.auto,
    url: 'https://api.example.com/upload',
    headers: {'Authorization': 'Bearer xxx'},
  ),
  onFileChanged: (files, action) {
    // 处理文件状态变化
  },
)
```

### 手动上传

选择文件后需手动触发上传，通过 `GlobalKey` 调用：

```dart
final uploadKey = GlobalKey<FileUploadState>();

FileUpload(
  key: uploadKey,
  pickFile: PickFile.file,
  uploadConfig: UploadConfig(
    mode: UploadMode.manual,
    url: 'https://api.example.com/upload',
  ),
)

// 触发上传
uploadKey.currentState?.startAllUpload();
```

### 自定义上传函数

完全由外部控制上传逻辑，适合已有封装好的网络库：

```dart
FileUpload(
  pickFile: PickFile.gallery,
  uploadConfig: UploadConfig(
    mode: UploadMode.custom,
    customUpload: (file, onProgress) async {
      // 使用你自己的网络库上传
      final result = await myHttpClient.upload(
        file.path!,
        onProgress: onProgress,
      );
      return result.isSuccess
          ? UploadResult.success(data: result.data)
          : UploadResult.failure(error: result.message);
    },
  ),
)
```

## 展示模式

### 卡片模式（默认）

正方形网格布局，适合图片上传场景：

```dart
FileUpload(
  pickFile: PickFile.imageOrCamera,
  showType: ShowType.card,
  columns: 3,         // 每行 3 列
  spacing: 10,        // 卡片间距
  borderRadius: 7,
)
```

也可使用固定尺寸代替列数（`columns` 与 `previewSize` 互斥）：

```dart
FileUpload(
  pickFile: PickFile.imageOrCamera,
  showType: ShowType.card,
  previewSize: 100,   // 固定 100x100 正方形
)
```

### 列表模式

横向行展示文件信息，适合文档上传场景：

```dart
FileUpload(
  pickFile: PickFile.file,
  showType: ShowType.textInfo,
  allowedExtensions: ['pdf', 'docx', 'xlsx'],
)
```

### 自定义模式

完全自定义每个文件项的 UI 展示：

```dart
FileUpload(
  pickFile: PickFile.all,
  showType: ShowType.custom,
  itemBuilder: (fileInfo, index, onRemove) {
    return ListTile(
      title: Text(fileInfo.name),
      subtitle: Text(fileInfo.formatSize),
      trailing: IconButton(icon: Icon(Icons.delete), onPressed: onRemove),
    );
  },
)
```

## 编辑模式（回显已有文件）

通过 `fileList` 传入已有文件，组件初始化时直接展示，`url` 为 http 开头时自动识别为已上传成功：

```dart
FileUpload(
  pickFile: PickFile.imageOrCamera,
  fileList: [
    FileInfo(name: 'avatar.jpg', url: 'https://example.com/avatar.jpg', size: 102400),
    FileInfo(name: 'cover.png', url: 'https://example.com/cover.png', size: 204800),
  ],
)
```

## API 参考

### FileUpload 参数

| 参数                  | 类型                                                      | 默认值                | 说明                                                                |
| --------------------- | --------------------------------------------------------- | --------------------- | ------------------------------------------------------------------- |
| `pickFile`            | `PickFile`                                                | `PickFile.all`        | 选择器类型：`file` / `gallery` / `camera` / `imageOrCamera` / `all` |
| `multiple`            | `bool`                                                    | `true`                | 是否支持多选                                                        |
| `limit`               | `int`                                                     | `-1`                  | 上传数量上限，`-1` 表示不限制                                       |
| `allowedExtensions`   | `List<String>?`                                           | `null`                | 允许的文件扩展名列表，仅 `PickFile.file` 时生效                     |
| `showType`            | `ShowType`                                                | `ShowType.card`       | 展示模式：`card` / `textInfo` / `custom`                            |
| `previewSize`         | `double?`                                                 | `null`                | 卡片固定尺寸（正方形），与 `columns` 互斥                           |
| `columns`             | `int?`                                                    | `3`                   | 每行列数，与 `previewSize` 互斥                                     |
| `spacing`             | `double`                                                  | `10`                  | 卡片间距（仅 `columns` 模式生效）                                   |
| `alignment`           | `WrapAlignment`                                           | `WrapAlignment.start` | 每行对齐方式（仅固定尺寸模式生效）                                  |
| `borderRadius`        | `double`                                                  | `7`                   | 卡片圆角半径                                                        |
| `title`               | `String`                                                  | `'点击上传'`          | 上传按钮提示文字                                                    |
| `icon`                | `Widget?`                                                 | `null`                | 自定义上传按钮图标                                                  |
| `uploadConfig`        | `UploadConfig?`                                           | `null`                | 上传配置，为空时仅提供选择能力                                      |
| `fileList`            | `List<FileInfo>?`                                         | `null`                | 初始文件列表（编辑模式回显）                                        |
| `onFileChanged`       | `Function(List<FileInfo>, FileAction)?`                   | `null`                | 文件变更回调                                                        |
| `onProgress`          | `void Function(String id, String path, double progress)?` | `null`                | 上传进度回调                                                        |
| `itemBuilder`         | `Widget Function(FileInfo, int, VoidCallback)?`           | `null`                | 自定义文件项构建器（仅 `ShowType.custom` 生效）                     |
| `uploadButtonBuilder` | `Widget Function(VoidCallback)?`                          | `null`                | 自定义上传按钮构建器                                                |
| `actionDecoration`    | `BoxDecoration?`                                          | `null`                | 上传按钮区域装饰样式                                                |
| `actionTitleStyle`    | `TextStyle?`                                              | `null`                | 上传按钮文字样式                                                    |

### FileUploadState 公开方法

通过 `GlobalKey<FileUploadState>` 在外部调用：

| 方法                                               | 说明                     |
| -------------------------------------------------- | ------------------------ |
| `startUpload(String id)`                           | 上传指定文件             |
| `startAllUpload()`                                 | 上传所有待上传文件       |
| `cancelUpload(String id)`                          | 取消指定文件上传         |
| `updateFileStatus(String id, UploadStatus status)` | 手动更新文件状态         |
| `files`                                            | 获取当前文件列表（只读） |

### UploadConfig 参数

| 参数             | 类型                                                              | 默认值   | 说明                                     |
| ---------------- | ----------------------------------------------------------------- | -------- | ---------------------------------------- |
| `mode`           | `UploadMode`                                                      | 必填     | 上传模式：`auto` / `manual` / `custom`   |
| `url`            | `String?`                                                         | `null`   | 上传接口地址（`auto` / `manual` 时必填） |
| `method`         | `String`                                                          | `'POST'` | HTTP 请求方法                            |
| `headers`        | `Map<String, String>?`                                            | `null`   | 自定义请求头                             |
| `fields`         | `Map<String, String>?`                                            | `null`   | 额外表单字段                             |
| `fileField`      | `String`                                                          | `'file'` | 文件对应的表单字段名                     |
| `maxConcurrent`  | `int`                                                             | `3`      | 最大并发上传数                           |
| `retryCount`     | `int`                                                             | `0`      | 失败自动重试次数                         |
| `customUpload`   | `Future<UploadResult> Function(FileInfo, void Function(double))?` | `null`   | 自定义上传函数（`custom` 模式必填）      |
| `validateResult` | `bool Function(Map<String, dynamic>?)?`                           | `null`   | 验证上传结果的业务成功状态               |

### FileInfo 模型

| 字段         | 类型                    | 说明                                             |
| ------------ | ----------------------- | ------------------------------------------------ |
| `id`         | `String`                | 唯一标识（雪花算法生成）                         |
| `name`       | `String`                | 文件名                                           |
| `path`       | `String?`               | 本地文件路径                                     |
| `url`        | `String?`               | 网络访问地址（http 开头自动识别为 success 状态） |
| `size`       | `int`                   | 文件大小（字节）                                 |
| `status`     | `UploadStatus`          | 上传状态                                         |
| `source`     | `FileSource`            | 文件来源                                         |
| `progress`   | `double`                | 上传进度 0.0 ~ 1.0                               |
| `data`       | `Map<String, dynamic>?` | 扩展数据（上传成功后存放服务端响应）             |
| `formatSize` | `String`                | 格式化文件大小（只读 getter）                    |
| `isImage`    | `bool`                  | 是否为图片文件（只读 getter）                    |

### 枚举值

**PickFile**：`file`（文件）、`gallery`（相册）、`camera`（拍照）、`imageOrCamera`（相册或拍照）、`all`（全部）

**ShowType**：`card`（卡片）、`textInfo`（列表）、`custom`（自定义）

**UploadMode**：`auto`（自动）、`manual`（手动）、`custom`（自定义函数）

**UploadStatus**：`pending`（待上传）、`uploading`（上传中）、`success`（成功）、`failed`（失败）

**FileAction**：`defaultLoad`（初始加载）、`add`（添加）、`remove`（移除）、`uploading`（开始上传）、`progress`（进度更新）、`success`（上传成功）、`failed`（上传失败）

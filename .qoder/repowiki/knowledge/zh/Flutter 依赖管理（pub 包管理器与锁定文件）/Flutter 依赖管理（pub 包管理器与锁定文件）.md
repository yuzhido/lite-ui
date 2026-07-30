---
kind: dependency_management
name: Flutter 依赖管理（pub 包管理器与锁定文件）
category: dependency_management
scope:
    - '**'
source_files:
    - pubspec.yaml
    - pubspec.lock
    - example/pubspec.yaml
---

本项目使用 Flutter/Dart 生态标准的 **pub 包管理器**进行第三方依赖声明、版本约束与解析，并通过 `pubspec.yaml` 和 `pubspec.lock` 两个核心文件完成依赖管理。

### 1. 使用的系统与工具
- **包管理器**: `pub`（Dart/Flutter 官方包管理器），通过 `flutter pub get` 安装依赖。
- **包仓库**: 默认从 `https://pub.dev` 托管源拉取依赖，未发现私有源或镜像配置。
- **锁定文件**: `pubspec.lock` 记录精确的依赖版本与 SHA256 校验值，确保构建可重现。
- **示例工程**: `example/pubspec.yaml` 通过 `path: ../` 引用本地库源码，用于开发时联调。

### 2. 关键文件与位置
- `pubspec.yaml` — 库包的依赖声明入口，定义 `dependencies` 与 `dev_dependencies`。
- `pubspec.lock` — 由 `pub` 自动生成，锁定所有直接/间接依赖的精确版本与来源。
- `example/pubspec.yaml` — 示例应用依赖声明，以路径方式引用本库。
- `.gitignore` — 遵循 Dart 官方约定，不提交 `pubspec.lock`（注释说明："Libraries should not include pubspec.lock"）。

### 3. 架构与约定
- **依赖分类清晰**：运行时依赖（`file_picker`、`image_picker`、`flutter` SDK）放入 `dependencies`；测试与分析工具（`flutter_test`、`flutter_lints`）放入 `dev_dependencies`。
- **SDK 约束**：通过 `environment.sdk` 和 `environment.flutter` 指定最低兼容版本，避免不兼容环境。
- **版本策略**：生产依赖使用精确版本号（如 `file_picker: 12.0.0-beta.7`、`image_picker: 1.2.3`），开发依赖使用语义化范围（`flutter_lints: ^6.0.0`）。
- **插件自动注册**：`example` 各平台（Android/iOS/Linux/macOS/Windows）的 `GeneratedPluginRegistrant.*` 文件由 Flutter 自动生成，无需手动维护。
- **无 vendoring**：未使用 `vendor/` 目录或 Git Submodule，所有依赖均通过 pub 远程解析。

### 4. 开发者应遵循的规则
- 新增依赖时编辑根目录 `pubspec.yaml`，运行 `flutter pub get` 生成/更新 `pubspec.lock`。
- 不要手动修改 `pubspec.lock`，应由 `pub` 工具自动维护。
- 发布为库时，按 Dart 官方建议**不提交** `pubspec.lock`，以便下游项目自行解析。
- 示例工程通过 `path:` 引用本地库，便于开发调试，但不应影响库本身的依赖声明。
- 升级依赖时使用 `flutter pub upgrade`，注意检查 breaking changes。
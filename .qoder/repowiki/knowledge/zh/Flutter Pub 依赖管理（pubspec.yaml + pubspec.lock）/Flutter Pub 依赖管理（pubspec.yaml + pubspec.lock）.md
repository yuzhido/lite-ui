---
kind: dependency_management
name: Flutter Pub 依赖管理（pubspec.yaml + pubspec.lock）
category: dependency_management
scope:
    - '**'
source_files:
    - pubspec.yaml
    - example/pubspec.yaml
    - example/pubspec.lock
---

## 1. 使用的系统与工具
- 包管理器：Dart/Flutter 官方 `pub`，通过 `pubspec.yaml` 声明依赖，`pubspec.lock` 锁定版本。
- 依赖来源：默认从 `https://pub.dev` 托管仓库拉取；未发现私有源或代理配置。
- SDK 约束：根库与 example 均通过 `environment.sdk: ^3.12.2` 和 `flutter: '>=1.17.0'` 限制 Dart/Flutter 版本范围。

## 2. 关键文件与位置
- `pubspec.yaml`：lite_ui 库的依赖声明（直接依赖 `file_picker`、`image_picker`，SDK 依赖 `flutter`），以及 dev_dependencies（`flutter_test`、`flutter_lints`）。
- `example/pubspec.yaml`：示例应用依赖 lite_ui（通过 `path: ../` 本地路径引用），并包含 `cupertino_icons`、`flutter_lints` 等。
- `example/pubspec.lock`：完整锁文件，记录所有直接/传递依赖的版本、sha256、source 与 sdk 约束，确保可重现构建。
- `analysis_options.yaml`：lint 规则（属于开发期依赖行为的一部分）。

## 3. 架构与约定
- 双工程结构：根目录为 Flutter 包（`lite_ui`），`example/` 作为演示应用，通过 path 引用本地包，便于开发与测试。
- 依赖分层清晰：
  - `dependencies`：运行时依赖（`file_picker`、`image_picker`）。
  - `dev_dependencies`：仅开发/测试使用（`flutter_test`、`flutter_lints`）。
- 版本策略：
  - 第三方包使用精确版本（如 `file_picker: 12.0.0-beta.7`、`image_picker: 1.2.3`）或 caret 约束（`flutter_lints: ^6.0.0`）。
  - SDK 使用 `^` 与 `>=` 组合，保证向前兼容同时避免不兼容升级。
- 无 vendoring：未使用 `packages/` 或 `vendor/` 目录，依赖由 pub 自动解析缓存。
- 无私有注册表：未发现 `.pub-cache` 外的自定义源、`PUB_HOSTED_URL`、`PUB_CACHE` 等配置。

## 4. 开发者应遵循的规则
- 新增依赖时仅在对应工程的 `pubspec.yaml` 中声明，不要手动修改 `pubspec.lock`。
- 保持 `environment.sdk` 与 `flutter` 版本约束与团队环境一致，避免升级冲突。
- 区分 `dependencies` 与 `dev_dependencies`，仅将构建/测试工具放入 dev_dependencies。
- 提交前运行 `flutter pub get` 生成/更新 `pubspec.lock`，确保 CI 与本地构建一致。
- 升级依赖时使用 `flutter pub upgrade --major-versions` 并检查 breaking changes，必要时调整版本约束。
- 示例工程通过 `path` 引用主包进行联调，发布时应改为从 pub.dev 拉取正式版本。

---
kind: dependency_management
name: Flutter 包依赖管理（pubspec + pub.dev）
category: dependency_management
scope:
    - '**'
source_files:
    - pubspec.yaml
    - pubspec.lock
    - example/pubspec.yaml
    - analysis_options.yaml
---

## 1. 使用的系统与工具
- 包管理器：Dart/Flutter 官方 `pub`，通过 `pubspec.yaml` 声明依赖。
- 版本锁定：使用 `pubspec.lock` 锁定所有直接和传递依赖的精确版本与 sha256，确保构建可重现。
- 包源：默认从 `https://pub.dev` 拉取，未发现私有仓库或代理配置。
- 代码分析：通过 `analysis_options.yaml` 引入 `flutter_lints`，统一静态检查规则。

## 2. 关键文件与位置
- 根库依赖声明：`pubspec.yaml`（name: lite_ui，version: 1.2.0）
- 依赖锁定文件：`pubspec.lock`（记录所有依赖及其 sha256、source、version）
- 示例应用依赖：`example/pubspec.yaml`（通过 `path: ../` 引用本地 lite_ui）
- 静态分析配置：`analysis_options.yaml`（继承 `package:flutter_lints/flutter.yaml`）

## 3. 架构与约定
- 依赖分层清晰：
  - `dependencies`：运行时依赖，仅包含 `file_picker`、`image_picker` 以及 SDK 中的 `flutter`。
  - `dev_dependencies`：开发期依赖，包含 `flutter_test` 和 `flutter_lints`。
- SDK 约束：`environment.sdk: ^3.12.2`，`environment.flutter: '>=1.17.0'`，锁定 Dart 与 Flutter 兼容范围。
- 示例工程通过相对路径引用主库，便于本地开发与调试。
- 未使用 vendoring（无 `vendor/` 目录），所有第三方包均通过 pub.dev 动态解析。
- 未发现 `.dart_tool/package_config.json` 以外的自定义缓存或私有 registry 配置。

## 4. 开发者应遵循的规则
- 新增依赖时，在 `pubspec.yaml` 中明确声明，并优先使用语义化版本约束（如 `^x.y.z`）。
- 提交前运行 `flutter pub get` 生成/更新 `pubspec.lock`，确保锁文件随代码一起提交。
- 升级依赖时使用 `flutter pub upgrade` 或 `flutter pub upgrade --major-packages`，并验证示例应用正常运行。
- 保持 `analysis_options.yaml` 与 `flutter_lints` 一致，避免引入不一致的 lint 规则。
- 不要手动编辑 `pubspec.lock`；如需强制指定版本，应在 `pubspec.yaml` 中使用 `dependency_overrides`（谨慎使用）。
- 示例工程应保持对主库的 `path:` 引用，以便在发布前进行端到端验证。
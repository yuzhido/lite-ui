---
kind: build_system
name: Flutter 包构建与发布体系
category: build_system
scope:
    - '**'
source_files:
    - pubspec.yaml
    - example/pubspec.yaml
    - analysis_options.yaml
---

该仓库是一个基于 Flutter 的轻量级 UI 组件库，其构建与发布完全依赖 Flutter/Dart 官方工具链，没有自定义 Makefile、Dockerfile 或 CI 配置文件。核心构建配置集中在以下位置：

1. **包定义**：根目录 `pubspec.yaml` 定义了包名 `lite_ui`、版本 `1.2.0`、Flutter SDK 约束（`^3.12.2`）以及依赖项（`file_picker`、`image_picker` 等）。开发依赖使用 `flutter_lints` 进行代码分析。

2. **示例应用**：`example/` 目录下包含一个完整的 Flutter 应用，通过 `path: ../` 引用本地包，用于演示和测试组件功能。该示例应用同样使用 `pubspec.yaml` 管理依赖，并配置了 `flutter_lints`。

3. **代码质量**：根目录和 example 目录均包含 `analysis_options.yaml`，统一代码风格检查规则。

4. **平台支持**：从 `example/` 下的 `android/`、`ios/`、`linux/`、`macos/`、`web/`、`windows/` 目录可见，项目支持 Flutter 所有主流平台。

**开发者应遵循的规则**：
- 修改包内容后，通过 `flutter pub publish --dry-run` 验证可发布性
- 使用 `flutter analyze` 执行代码分析
- 在 `example/` 中运行 `flutter test` 执行单元测试
- 版本号遵循语义化版本控制，在 `pubspec.yaml` 中统一管理
- 新增依赖需同时更新 `pubspec.yaml` 并通过 `flutter pub get` 安装

由于没有发现 CI/CD 配置文件、自动化脚本或 Docker 相关配置，该项目的构建流程主要依赖 Flutter CLI 命令手动执行。
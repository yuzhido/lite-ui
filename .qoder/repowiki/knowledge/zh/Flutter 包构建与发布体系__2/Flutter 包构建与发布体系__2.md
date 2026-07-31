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

该仓库是一个标准的 Flutter 组件库项目，构建与发布完全依赖 Flutter/Dart 官方工具链，未引入自定义 Makefile、Docker 或 CI 脚本。

**构建系统**：基于 `pubspec.yaml` 声明式配置，使用 `flutter pub get` 解析依赖，`flutter build` 生成各平台产物。SDK 约束为 `^3.12.2`，Flutter 版本要求 `>=1.17.0`。

**包结构**：根目录 `pubspec.yaml` 定义库 `lite_ui`（当前版本 1.2.0），`example/` 子项目通过 `path: ../` 引用本地库进行开发调试，且设置 `publish_to: 'none'` 避免误发布示例项目。

**代码质量**：通过 `analysis_options.yaml` 启用 `flutter_lints ^6.0.0` 进行静态分析，测试使用 `flutter_test`。

**发布流程**：遵循 Flutter 包的常规发布方式——更新 `pubspec.yaml` 中的版本号后执行 `flutter pub publish`。未发现自动化 CI/CD 配置、Docker 化或跨平台编译脚本，属于轻量级手动发布模式。

**开发者约定**：新增组件需同步更新 CHANGELOG.md；依赖管理集中在根 `pubspec.yaml`；示例应用与库保持路径引用以便本地联调。
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
    - example/android/app/build.gradle.kts
    - example/android/settings.gradle.kts
---

该仓库是一个基于 Flutter 的轻量级 UI 组件库，构建系统完全依赖 Flutter/Dart 官方工具链，采用标准的 pub 包管理方式，没有自定义 Makefile、Dockerfile 或 CI 脚本。

**构建系统与工具**
- 使用 `pubspec.yaml` 统一声明包元数据、依赖版本和 SDK 约束（SDK ^3.12.2, flutter >=1.17.0）
- 通过 `flutter pub get` 拉取依赖，`flutter build` 生成各平台产物
- 代码质量检查使用 `flutter_lints`，配置在根目录 `analysis_options.yaml` 中继承 `package:flutter_lints/flutter.yaml`
- 测试框架为 `flutter_test`，位于 `dev_dependencies` 中

**包结构与发布策略**
- 根目录 `pubspec.yaml` 定义可发布包 `lite_ui`（当前版本 1.2.0），包含业务组件源码于 `lib/src/`
- `example/` 子项目作为演示应用，通过 `path: ../` 引用本地 lite_ui 包进行开发调试
- 示例应用独立维护自己的 `pubspec.yaml`，`publish_to: 'none'` 表明仅用于本地演示

**多平台构建支持**
- Android：Gradle Kotlin DSL (`build.gradle.kts`) + Gradle Wrapper (9.1.0)，JVM Target 17
- iOS/macOS：Xcode 工程文件（`.xcodeproj`/`.xcworkspace`）+ `.xcconfig` 配置文件
- Linux/Windows：CMake 构建系统，由 Flutter 工具链自动生成
- Web：标准 `web/index.html` + `manifest.json` 配置

**开发者约定**
- 新增组件应放在 `lib/src/` 下，并通过 `lib/lite_ui.dart` 统一导出
- 依赖版本需严格锁定在 `pubspec.yaml` 中，避免隐式升级导致兼容性问题
- 示例代码应在 `example/lib/` 中按功能模块组织页面
- 无自动化 CI/CD 流水线，发布流程依赖手动执行 `flutter pub publish`
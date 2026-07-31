---
kind: build_system
name: Flutter 包构建与发布系统
category: build_system
scope:
    - '**'
source_files:
    - pubspec.yaml
    - example/pubspec.yaml
    - analysis_options.yaml
    - CHANGELOG.md
---

该仓库是一个 Flutter 组件库，采用标准的 Flutter 包结构进行构建与管理，未使用自定义的 Makefile、Dockerfile 或 CI/CD 脚本。

**构建系统与工具链**
- 依赖管理：通过 `pubspec.yaml` 声明依赖，使用 Flutter/Dart SDK 3.12.2+ 和 flutter_lints 6.0.0 进行静态分析
- 版本管理：主包版本为 1.2.0，遵循语义化版本控制（MAJOR.MINOR.PATCH）
- 环境约束：SDK 要求 `^3.12.2`，Flutter 最低版本 `>=1.17.0`

**项目结构**
- 根目录 `pubspec.yaml` 定义库包配置，包含 file_picker、image_picker 等运行时依赖
- `example/` 子项目通过 `path: ../` 引用本地库进行开发验证
- 代码组织在 `lib/src/` 下，入口文件为 `lite_ui.dart`

**测试与分析**
- 使用 `flutter_test` 框架进行测试
- 通过 `flutter_lints` 执行代码质量检查
- example 项目中包含基础 widget 测试 `test/widget_test.dart`

**平台支持**
- 原生平台：Android (Gradle)、iOS (Xcode)、Linux/macOS/Windows (CMake)、Web
- 各平台示例工程位于 `example/{platform}/` 目录下

**发布流程**
- 标准 Flutter 包发布流程：`flutter pub publish`
- CHANGELOG.md 记录版本变更历史
- 无自动化 CI/CD 配置，需手动执行构建和发布命令
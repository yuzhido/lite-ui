---
kind: build_system
name: Flutter 包构建与发布系统
category: build_system
scope:
    - '**'
source_files:
    - pubspec.yaml
    - example/pubspec.yaml
    - CHANGELOG.md
    - analysis_options.yaml
---

该仓库是一个 Flutter 自定义 UI 组件库，采用标准的 Flutter Package 结构进行构建和发布管理。

**构建系统与工具链**
- 使用 Flutter SDK 作为核心构建工具，通过 `pubspec.yaml` 声明依赖和元数据
- 版本管理：主包版本为 1.2.0，SDK 要求 ^3.12.2，Flutter 版本 >=1.17.0
- 依赖管理：使用 `file_picker: 12.0.0-beta.7`、`image_picker: 1.2.3` 等第三方包
- 代码分析：通过 `flutter_lints: ^6.0.0` 进行静态分析和代码质量检查

**项目结构**
- 根目录 `pubspec.yaml`：定义库的元数据、依赖和发布配置
- `example/` 目录：包含完整的示例应用，用于测试和演示组件功能
- `lib/src/`：核心组件源码目录
- `lite_ui.dart`：库的统一入口文件

**构建流程**
- 开发时通过 `flutter pub get` 获取依赖
- 运行示例应用：`flutter run` 在 example 目录下
- 打包发布：使用 `flutter pub publish` 发布到 pub.dev
- 跨平台支持：Android、iOS、Linux、macOS、Windows、Web

**发布策略**
- 无 CI/CD 配置文件（如 GitHub Actions、Dockerfile 等）
- 手动发布流程，通过 Flutter CLI 工具完成
- 版本变更通过 CHANGELOG.md 记录
- 遵循 Flutter Package 的标准发布规范
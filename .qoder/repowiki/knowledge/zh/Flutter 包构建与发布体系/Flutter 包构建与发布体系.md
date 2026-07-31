---
kind: build_system
name: Flutter 包构建与发布体系
category: build_system
scope:
    - '**'
source_files:
    - pubspec.yaml
    - analysis_options.yaml
    - example/pubspec.yaml
---

该仓库是一个标准的 Flutter 包（package），采用 Flutter/Dart 官方推荐的包结构，没有自定义的 Makefile、Dockerfile 或 CI/CD 脚本。构建系统完全依赖 Flutter SDK 和 pub 包管理器。

**核心构建配置**
- `pubspec.yaml`：定义包名 lite_ui、版本 1.2.0、SDK 约束 ^3.12.2、依赖 file_picker 和 image_picker
- `analysis_options.yaml`：继承 flutter_lints 进行代码分析
- `example/`：示例应用通过 path 引用本地包，用于开发时验证组件

**构建流程**
- 使用 `flutter pub get` 获取依赖
- 使用 `flutter test` 运行测试
- 使用 `flutter analyze` 执行静态分析
- 使用 `flutter build` 生成各平台产物
- 使用 `dart pub publish` 发布到 pub.dev

**跨平台支持**
- Android：Gradle (Kotlin DSL)
- iOS：Xcode 工程
- Web：标准 Flutter Web 构建
- Linux/macOS/Windows：CMake 原生构建

**约定**
- 无自动化 CI/CD 配置
- 无 Docker 化部署
- 无自定义构建脚本
- 遵循 Flutter 包的标准目录结构和命名规范
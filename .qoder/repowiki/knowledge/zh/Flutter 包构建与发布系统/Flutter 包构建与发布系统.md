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

该仓库是一个 Flutter 组件库，构建系统基于 Flutter/Dart 官方工具链，采用标准的 pub 包管理方式。

**构建系统与工具**
- 使用 `pubspec.yaml` 作为核心构建配置，定义包名、版本、依赖和 Dart SDK 约束（^3.12.2）
- 通过 `flutter pub` 命令进行依赖解析、分析和打包
- 代码质量检查使用 `flutter_lints` 静态分析规则
- 测试框架为 `flutter_test`

**项目结构**
- 根目录 `pubspec.yaml` 定义库包 `lite_ui`（当前版本 1.2.0），包含业务依赖如 `file_picker`、`image_picker`
- `example/` 子项目通过 `path: ../` 引用本地库，用于开发和演示，且设置 `publish_to: 'none'` 避免误发布
- 各平台原生工程（Android/iOS/Linux/macOS/Windows/Web）由 Flutter 自动生成，无需手动维护构建脚本

**发布流程**
- 无自动化 CI/CD 流水线（未发现 `.github/workflows`、`.gitlab-ci.yml` 等配置文件）
- 版本号管理在 `pubspec.yaml` 的 `version` 字段中手动维护
- 发布方式为标准的 `flutter pub publish` 命令
- 变更日志记录在 `CHANGELOG.md` 中

**开发约定**
- 使用 `analysis_options.yaml` 统一代码风格和分析规则
- 示例应用与库代码分离，便于独立开发和调试
- 依赖版本采用语义化版本控制，SDK 约束使用 caret 语法保证兼容性
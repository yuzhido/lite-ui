---
kind: dependency_management
name: Flutter 依赖管理（pub 包管理器）
category: dependency_management
scope:
    - '**'
source_files:
    - pubspec.yaml
    - pubspec.lock
    - example/pubspec.yaml
    - analysis_options.yaml
---

该仓库使用 Flutter/Dart 生态的标准依赖管理系统 **pub**，通过 `pubspec.yaml` 声明依赖、`pubspec.lock` 锁定版本，遵循 Flutter 官方最佳实践。

## 1. 使用的系统与工具
- **包管理器**: `pub`（Dart/Flutter 官方包管理器）
- **依赖声明**: `pubspec.yaml`
- **版本锁定**: `pubspec.lock`（由 `pub get` 自动生成）
- **代码分析**: `analysis_options.yaml` 引用 `flutter_lints/flutter.yaml`
- **包发布源**: 默认 `https://pub.dev`（公共托管源）

## 2. 关键文件与位置
- **根库依赖**: `pubspec.yaml` — 定义 `lite_ui` 包的运行时依赖与开发依赖
- **锁文件**: `pubspec.lock` — 锁定所有直接和传递依赖的精确版本及 SHA256 校验值
- **示例应用依赖**: `example/pubspec.yaml` — 通过 `path: ../` 本地引用主库进行开发测试
- **静态分析配置**: `analysis_options.yaml` — 继承 `flutter_lints/flutter.yaml`

## 3. 架构与约定
- **SDK 约束**: 根 `pubspec.yaml` 中 `environment.sdk: ^3.12.2` 和 `flutter: '>=1.17.0'` 明确 Dart SDK 与 Flutter 最低版本要求
- **依赖分类清晰**:
  - `dependencies`: 运行时依赖（`file_picker: 12.0.0-beta.7`、`image_picker: 1.2.3`、`flutter: sdk: flutter`）
  - `dev_dependencies`: 开发期依赖（`flutter_test`、`flutter_lints: ^6.0.0`）
- **版本策略**:
  - 第三方包使用语义化版本号（如 `^6.0.0` 允许兼容更新）
  - 部分平台插件使用精确版本（如 `file_picker: 12.0.0-beta.7`）
- **本地开发模式**: `example/` 通过 `path: ../` 引用主库，便于联调与演示
- **无 vendoring**: 未使用 `vendor/` 目录或私有缓存，依赖从 pub.dev 远程拉取
- **无私有注册表**: 未发现 `pubspec_overrides.yaml`、`.dart_tool/package_config.json` 中的自定义源配置

## 4. 开发者应遵循的规则
- **添加依赖时**：在 `pubspec.yaml` 的对应区块（`dependencies` / `dev_dependencies`）声明，并使用 `^` 前缀保持语义化版本兼容
- **提交锁文件**：`pubspec.lock` 必须纳入版本控制，确保团队构建一致性
- **避免硬编码版本**：除非必要（如 beta 包），优先使用 `^version` 语法
- **示例同步**：修改主库依赖后，需在 `example/pubspec.yaml` 中验证兼容性
- **分析规则统一**：通过 `analysis_options.yaml` 继承 `flutter_lints/flutter.yaml`，不自行重写 lint 规则
- **不手动编辑 lock 文件**：依赖更新应通过 `flutter pub upgrade` 等命令完成
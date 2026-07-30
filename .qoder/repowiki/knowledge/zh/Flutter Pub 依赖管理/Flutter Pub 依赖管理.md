---
kind: dependency_management
name: Flutter Pub 依赖管理
category: dependency_management
scope:
    - '**'
source_files:
    - pubspec.yaml
    - pubspec.lock
    - example/pubspec.yaml
    - analysis_options.yaml
---

该仓库使用 Flutter/Dart 生态的标准依赖管理系统 pub，通过 `pubspec.yaml` 声明依赖、`pubspec.lock` 锁定版本，实现跨平台一致的包管理。

**系统与工具**
- 包管理器：Dart/Flutter 内置的 `pub`（由 `flutter pub` 命令驱动）
- 包源：默认使用官方 `https://pub.dev` 托管源，未配置私有仓库或镜像
- 锁文件：`pubspec.lock` 精确记录所有直接依赖与传递依赖的版本及 SHA256 校验值
- 分析规则：通过 `analysis_options.yaml` 继承 `package:flutter_lints/flutter.yaml` 统一代码风格检查

**核心文件与结构**
- 根目录 `pubspec.yaml`：定义库包 `lite_ui`（版本 1.2.0），声明 SDK 约束 `dart: ^3.12.2`、`flutter: >=1.17.0`，直接依赖 `file_picker: 12.0.0-beta.7` 和 `image_picker: 1.2.3`
- 根目录 `pubspec.lock`：锁定全部 40+ 个依赖（含传递依赖）的具体版本与来源
- `example/pubspec.yaml`：示例应用通过 `path: ../` 引用本地 lite_ui 包，便于开发调试
- `.dart_tool/`：pub 生成的缓存与解析结果目录

**架构与约定**
- 单仓双项目结构：根目录为可发布的库包，`example/` 子目录为演示应用，两者共享同一 Dart SDK 版本约束
- 依赖分层清晰：运行时依赖放入 `dependencies`，测试与分析工具（`flutter_test`、`flutter_lints`）放入 `dev_dependencies`
- 版本策略：SDK 使用 `^` 语义化版本约束，第三方包采用精确版本或 `^` 约束混合使用
- 无 vendoring：不提交 `vendor/` 目录，依赖通过 pub 从 pub.dev 动态拉取
- 无私有注册表：未配置 `pubspec_overrides.yaml` 或环境变量代理私有源

**开发者应遵循的规则**
1. 新增依赖时仅修改对应 `pubspec.yaml` 的 `dependencies` 或 `dev_dependencies` 段，不要手动编辑 `pubspec.lock`
2. 保持 example 与应用使用相同 Dart SDK 版本（当前均为 `^3.12.2`）
3. 发布前运行 `flutter pub get` 确保锁文件与依赖树一致
4. 升级依赖后需验证示例应用正常运行，避免破坏组件兼容性
5. 分析规则通过 `analysis_options.yaml` 统一管理，新增 lint 规则应在根目录集中配置
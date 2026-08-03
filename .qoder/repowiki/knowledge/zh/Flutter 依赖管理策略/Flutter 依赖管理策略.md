---
kind: dependency_management
name: Flutter 依赖管理策略
category: dependency_management
scope:
    - '**'
source_files:
    - pubspec.yaml
    - example/pubspec.yaml
    - analysis_options.yaml
---

该仓库是一个 Flutter 自定义 UI 组件库，采用标准的 Flutter/Dart 依赖管理体系：

**1. 包管理器与声明文件**
- 使用 `pubspec.yaml` 作为核心依赖声明文件，位于根目录和 `example/` 子项目
- 主包 `lite_ui`（版本 1.2.0）通过 `dependencies` 声明运行时依赖：`file_picker: 12.0.0-beta.7`、`image_picker: 1.2.3`、`flutter: sdk: flutter`
- 开发依赖通过 `dev_dependencies` 管理：`flutter_test`（SDK 内置）、`flutter_lints: ^6.0.0`
- SDK 约束：`sdk: ^3.12.2`，Flutter 最低版本 `>=1.17.0`

**2. 版本锁定机制**
- 使用 `pubspec.lock` 锁定依赖版本，确保构建可重现性
- 示例项目通过 `path: ../` 引用本地 lite_ui 包进行开发调试

**3. 代码质量与静态分析**
- 通过 `analysis_options.yaml` 继承 `package:flutter_lints/flutter.yaml` 规则集
- 统一 lint 配置保证代码风格一致性

**4. 依赖管理约定**
- 第三方库使用语义化版本控制（如 `^6.0.0`、`1.2.3`）
- SDK 依赖通过 `sdk: flutter` 方式声明，避免硬编码版本号
- 示例项目 `publish_to: 'none'` 表明仅用于演示，不发布到 pub.dev

**开发者应遵循的规则：**
- 新增依赖需在 `pubspec.yaml` 中明确声明版本约束
- 保持 `flutter_lints` 规则启用以统一代码风格
- 更新依赖后需运行 `flutter pub get` 同步 `pubspec.lock`
- 测试依赖与运行时依赖严格分离
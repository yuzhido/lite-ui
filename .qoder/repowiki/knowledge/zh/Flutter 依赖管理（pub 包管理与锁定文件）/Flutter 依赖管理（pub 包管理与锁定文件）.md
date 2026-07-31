---
kind: dependency_management
name: Flutter 依赖管理（pub 包管理与锁定文件）
category: dependency_management
scope:
    - '**'
source_files:
    - pubspec.yaml
    - pubspec.lock
    - example/pubspec.yaml
    - analysis_options.yaml
---

本仓库使用 Flutter/Dart 生态的标准依赖管理系统 `pub`，通过 `pubspec.yaml` 声明依赖、`pubspec.lock` 锁定版本，配合示例工程验证组件库的兼容性。

**1. 使用的系统与工具**
- 包管理器：`pub`（Dart/Flutter 官方包管理工具）
- 依赖声明：`pubspec.yaml`
- 版本锁定：`pubspec.lock`（由 `pub get` 自动生成）
- 代码分析规则：`analysis_options.yaml` 继承自 `package:flutter_lints/flutter.yaml`
- 私有源/代理：未发现自定义 `pubspec_overrides.yaml`、`.pub-cache` 或 `PUB_HOSTED_URL` 配置，默认使用 https://pub.dev

**2. 核心文件与位置**
- 根目录 `pubspec.yaml`：定义库名 `lite_ui`、版本 `1.2.0`、SDK 约束 `^3.12.2`、Flutter `>=1.17.0`，以及三个直接依赖：`file_picker: 12.0.0-beta.7`、`image_picker: 1.2.3`、`flutter_lints: ^6.0.0`（dev）
- 根目录 `pubspec.lock`：完整记录所有直接和传递依赖的版本、sha256 校验值及来源（均为 `hosted` + pub.dev）
- `example/pubspec.yaml`：示例应用通过 `path: ../` 引用本地 lite_ui，用于开发时联调
- `analysis_options.yaml`：统一 lint 规则，避免各模块风格不一致

**3. 架构与约定**
- **最小化依赖原则**：作为轻量 UI 组件库，仅引入文件选择与图片选择两个第三方包，保持包体积极小
- **SDK 版本约束严格**：Dart SDK 使用 `^3.12.2`（语义化版本兼容），Flutter SDK 使用 `>=1.17.0` 宽泛下限，确保向后兼容
- **dev_dependencies 分离**：测试与 lint 工具放在 `dev_dependencies`，不进入发布产物
- **示例工程隔离**：`example/` 独立 pubspec，通过 path 引用主库，便于在真实项目中验证 API 可用性
- **无 vendoring**：未使用 `vendor/` 目录或 Git Submodule，所有依赖均从 pub.dev 拉取
- **锁文件提交**：`pubspec.lock` 已纳入版本控制，保证构建可重现

**4. 开发者应遵循的规则**
- 新增依赖必须同时更新 `pubspec.yaml` 并运行 `flutter pub get` 生成最新 `pubspec.lock`
- 优先使用语义化版本范围（如 `^x.y.z`），避免固定死版本号导致升级困难
- 第三方依赖需评估必要性，UI 组件库应保持依赖精简
- 修改依赖后应在 `example/` 中验证组件正常工作
- 禁止手动编辑 `pubspec.lock`，应由 `pub` 工具自动维护
- 如需私有源或镜像，应在团队规范中统一配置环境变量而非写入项目文件
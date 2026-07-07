# 关键字匹配高亮功能实施计划

## Context

TreeSelect 和 ActionSheet 组件均有搜索过滤功能，但过滤后匹配项的文本以普通样式显示，用户无法直观看到关键字命中的位置。需要新增可配置的关键字高亮能力，在过滤时对匹配项中的关键字部分进行高亮渲染。

## 设计概要

- 新建通用高亮工具文件 `lib/widgets/keyword_highlight.dart`，包含配置类 `KeywordHighlightStyle` 和工具函数 `buildHighlightedText()`
- 使用 `RichText` + `TextSpan` 实现文本分段高亮
- 配置通过各组件的 Config 类透传，`highlightStyle` 为 null 时自动启用默认高亮（蓝色加粗），传 `enabled: false` 关闭

---

## Task 1: 新建通用高亮工具 `keyword_highlight.dart`

**新建文件**: `lib/widgets/keyword_highlight.dart`

包含:
- `KeywordHighlightStyle` 配置类: `enabled`(开关), `color`(前景色), `backgroundColor`(背景色), `bold`(是否加粗)
- `buildHighlightedText()` 工具函数: 接收 text、keyword、style、highlightStyle 等参数，keyword 为空时返回普通 Text，否则用 RegExp 拆分文本构建 RichText

核心逻辑:
1. keyword 为空 或 enabled=false → 返回普通 `Text`
2. 用 `RegExp.escape(keyword)` 构建正则，`caseSensitive: false` 匹配
3. 遍历 Match 结果，构建 `TextSpan` 列表（匹配段用高亮样式，非匹配段用基础样式）
4. 返回 `RichText`

## Task 2: TreeSelect 组件集成高亮

### 2a. `lib/src/tree_select/model.dart` — TreeSelectConfig 新增字段
- 新增 `final KeywordHighlightStyle? highlightStyle` 字段（默认 null = 启用默认高亮）

### 2b. `lib/src/tree_select/ui/tree_list.dart` — TreeList 接收高亮参数
- 新增 `keyword`（String, 默认 `''`）和 `highlightStyle`（KeywordHighlightStyle?, 默认 null）两个字段
- 第 170-178 行 `Text(node.label, ...)` 替换为 `buildHighlightedText(text: node.label, keyword: widget.keyword, style: ..., highlightStyle: widget.highlightStyle)`

### 2c. `lib/src/tree_select/ui/tree_select.dart` — 透传参数
- 第 153-161 行 TreeList 构造处新增 `keyword: _searchController.text` 和 `highlightStyle: widget.config.highlightStyle`

### 2d. `lib/src/tree_select/tree_select_helper.dart` — Helper 方法透传
- `show()` 和 `showMultiple()` 方法新增可选参数 `KeywordHighlightStyle? highlightStyle`，传入 TreeSelectConfig

## Task 3: ActionSheet 组件集成高亮

### 3a. `lib/src/action_sheet/action_sheet_widgets.dart` — ActionSheetCheckListItem 支持高亮
- 新增 `keyword`（String?, 默认 null）和 `highlightStyle`（KeywordHighlightStyle?, 默认 null）
- 第 229-236 行 `Text(label, ...)` 替换为 `buildHighlightedText`
- 第 239-247 行 `Text(subtitle!, ...)` 替换为 `buildHighlightedText`（subtitle 也支持高亮匹配）

### 3b. `lib/src/action_sheet/action_sheet.dart` — show() 方法新增参数
- 新增 `KeywordHighlightStyle? highlightStyle` 参数，透传给 filterable/remote 子组件

## Task 4: 导出与验证

### 4a. `lib/lite_ui.dart` — 新增导出
- 添加 `export 'widgets/keyword_highlight.dart';`

### 4b. 编译验证
- 运行 `dart analyze` 确保无编译错误

---

## 文件变更清单

| 文件 | 操作 |
|------|------|
| `lib/widgets/keyword_highlight.dart` | 新建 |
| `lib/src/tree_select/model.dart` | 修改 (TreeSelectConfig 加 highlightStyle) |
| `lib/src/tree_select/ui/tree_list.dart` | 修改 (加 keyword/highlightStyle 参数，Text→buildHighlightedText) |
| `lib/src/tree_select/ui/tree_select.dart` | 修改 (透传 keyword 和 highlightStyle) |
| `lib/src/tree_select/tree_select_helper.dart` | 修改 (show/showMultiple 加 highlightStyle 参数) |
| `lib/src/action_sheet/action_sheet_widgets.dart` | 修改 (ActionSheetCheckListItem 加 keyword/highlightStyle) |
| `lib/src/action_sheet/action_sheet.dart` | 修改 (show 方法加 highlightStyle 参数) |
| `lib/lite_ui.dart` | 修改 (新增 export) |

## 验证方式

1. `dart analyze` 无错误
2. 运行 example app，打开 TreeSelect 搜索关键字，确认匹配文本蓝色加粗高亮
3. 测试 `KeywordHighlightStyle(enabled: false)` 关闭高亮后回退为普通文本
4. 测试特殊字符输入（如 `(`、`*`）不会导致异常

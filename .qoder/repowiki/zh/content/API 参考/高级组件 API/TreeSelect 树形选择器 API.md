# TreeSelect 树形选择器 API

<cite>
**本文引用的文件**   
- [tree_select.dart](file://lib/src/tree_select/tree_select.dart)
- [tree_select_helper.dart](file://lib/src/tree_select/tree_select_helper.dart)
- [models/index.dart](file://lib/src/tree_select/models/index.dart)
- [ui/tree_select_content.dart](file://lib/src/tree_select/ui/tree_select_content.dart)
- [ui/tree_list.dart](file://lib/src/tree_select/ui/tree_list.dart)
- [utils/index.dart](file://lib/src/tree_select/utils/index.dart)
- [bottom_action_bar.dart](file://lib/src/widgets/bottom_action_bar.dart)
- [keyword_highlight.dart](file://lib/src/widgets/keyword_highlight.dart)
- [tree_select_example.dart](file://example/lib/pages/tree_select_example.dart)
</cite>

## 更新摘要
**变更内容**   
- 新增 TreeSelectField 表单组件，集成 FormField 和 WrapperContainer
- 重构 TreeSelect 为 TreeModalContent 弹窗内容组件
- 统一 show<T>() 方法替代原有的 show() 和 showMultiple()
- 底部按钮区域复用 BottomActionBar 通用组件
- 简化 API 架构，对齐 DropdownChoose 设计模式

## 目录
1. [简介](#简介)
2. [项目结构](#项目结构)
3. [核心组件](#核心组件)
4. [架构总览](#架构总览)
5. [详细组件分析](#详细组件分析)
6. [依赖关系分析](#依赖关系分析)
7. [性能与大数据优化](#性能与大数据优化)
8. [故障排查指南](#故障排查指南)
9. [结论](#结论)
10. [附录：API 参考与示例](#附录api-参考与示例)

## 简介
TreeSelect 是一个支持单选/多选、搜索过滤、关键字高亮、懒加载与父节点联动选择的树形选择器。经过重大重构后，现在提供统一的 `show<T>()` 便捷方法和全新的 `TreeSelectField` 表单组件，完美集成 Flutter 表单系统。组件采用"表单字段组件 + 弹窗内容"的现代化架构，既支持快速集成，也满足深度定制需求。

## 项目结构
TreeSelect 相关代码位于 lib/src/tree_select 目录下，采用清晰的模块化设计：
- `tree_select.dart`: 新的表单字段组件 TreeSelectField
- `tree_select_helper.dart`: 统一的便捷入口方法
- `ui/tree_select_content.dart`: 重构后的弹窗内容组件 TreeModalContent
- `ui/tree_list.dart`: 树形列表渲染组件
- `models/index.dart`: 数据模型和配置类
- `utils/index.dart`: 树操作工具类

```mermaid
graph TB
A["示例页面<br/>tree_select_example.dart"] --> B["便捷入口<br/>tree_select_helper.dart"]
B --> C["弹窗内容<br/>ui/tree_select_content.dart"]
C --> D["树列表渲染<br/>ui/tree_list.dart"]
C --> E["工具类<br/>utils/index.dart"]
D --> E
C --> F["数据模型<br/>models/index.dart"]
D --> G["关键词高亮<br/>keyword_highlight.dart"]
H["表单组件<br/>tree_select.dart"] --> C
H --> I["底部操作栏<br/>bottom_action_bar.dart"]
```

**图表来源**
- [tree_select_example.dart:1-369](file://example/lib/pages/tree_select_example.dart#L1-L369)
- [tree_select_helper.dart:1-79](file://lib/src/tree_select/tree_select_helper.dart#L1-L79)
- [ui/tree_select_content.dart:1-311](file://lib/src/tree_select/ui/tree_select_content.dart#L1-L311)
- [ui/tree_list.dart:1-291](file://lib/src/tree_select/ui/tree_list.dart#L1-L291)
- [utils/index.dart:1-243](file://lib/src/tree_select/utils/index.dart#L1-L243)
- [models/index.dart:1-123](file://lib/src/tree_select/models/index.dart#L1-L123)
- [tree_select.dart:1-423](file://lib/src/tree_select/tree_select.dart#L1-L423)
- [bottom_action_bar.dart:1-135](file://lib/src/widgets/bottom_action_bar.dart#L1-L135)

## 核心组件
- **TreeNode<T>**: 树节点数据模型，包含 id、label、parentId、children、isExpanded、isLeaf、isLoading、data 等字段
- **TreeSelectConfig<T>**: 选择器配置项，集中管理所有行为与外观配置
- **TreeSelectField<T>**: 新的表单字段组件，集成 FormField 和 WrapperContainer
- **TreeModalContent<T>**: 重构后的弹窗内容组件，专注展示和交互逻辑
- **TreeList<T>**: 纯展示型树列表，递归渲染节点和处理懒加载
- **TreeUtils**: 静态工具类，提供树操作的无状态方法集合
- **TreeSelectHelper**: 统一的便捷入口，提供单一的 show<T>() 方法
- **BottomActionBar**: 通用的底部操作栏组件，支持已选数量展示和空选禁用

**章节来源**
- [models/index.dart:1-123](file://lib/src/tree_select/models/index.dart#L1-L123)
- [tree_select.dart:1-423](file://lib/src/tree_select/tree_select.dart#L1-L423)
- [ui/tree_select_content.dart:1-311](file://lib/src/tree_select/ui/tree_select_content.dart#L1-L311)
- [ui/tree_list.dart:1-291](file://lib/src/tree_select/ui/tree_list.dart#L1-L291)
- [utils/index.dart:1-243](file://lib/src/tree_select/utils/index.dart#L1-L243)
- [tree_select_helper.dart:1-79](file://lib/src/tree_select/tree_select_helper.dart#L1-L79)
- [bottom_action_bar.dart:1-135](file://lib/src/widgets/bottom_action_bar.dart#L1-L135)

## 架构总览
TreeSelect 采用现代化的"表单字段 + 弹窗内容"分层架构，完全对齐 DropdownChoose 的设计模式：

```mermaid
classDiagram
class TreeNode~T~ {
+id : T
+label : String
+parentId : T?
+children : List<TreeNode~T~>
+isExpanded : bool
+isLeaf : bool
+isLoading : bool
+data : Map~String,dynamic~?
+hasChildren : bool
+isChildrenLoaded : bool
}
class TreeSelectConfig~T~ {
+title : String
+searchHint : String
+emptyText : String
+showSearch : bool
+multiple : bool
+selectedIds : Set~T~
+onSelect(node) : void
+onConfirm(nodes) : void
+onLoadChildren(parent) : Future~TreeNode[]T~~
+cancelLabel : String
+confirmLabel : String
+parentSelectable : bool
+highlightStyle : KeywordHighlightStyle?
}
class TreeSelectField~T~ {
+formLabel : String
+subTitle : String?
+hintText : String?
+required : bool
+multiple : bool
+treeData : TreeNode[]T~~
+selectedIds : Set~T~
+parentSelectable : bool
+showSearch : bool
+searchHint : String
+emptyText : String
+onLoadChildren : Function?
+highlightStyle : KeywordHighlightStyle?
+validator : Function?
+autovalidateMode : AutovalidateMode
+onSaved : Function?
+formLayout : FormLayout
+prefixIcon : Widget?
+displayMode : DisplayMode
+maxShowTags : int?
+valueBuilder : Function?
+onSelect : Function?
+onConfirm : Function?
+onClear : VoidCallback?
}
class TreeModalContent~T~ {
+treeData : TreeNode[]T~~
+title : String
+searchHint : String
+emptyText : String
+showSearch : bool
+multiple : bool
+selectedIds : Set~T~
+parentSelectable : bool
+onSelect : Function?
+onConfirm : Function?
+onLoadChildren : Function?
+cancelLabel : String
+confirmLabel : String
+highlightStyle : KeywordHighlightStyle?
}
class TreeList~T~ {
+nodes : TreeNode[]T~~
+selectedIds : Set~T~
+multiple : bool
+emptyText : String
+onLoadChildren : Function?
+onChildrenLoaded : Function?
+onNodeTap : Function?
+keyword : String
+highlightStyle : KeywordHighlightStyle?
+parentSelectable : bool
+onParentIndicatorTap : Function?
+onParentExpandForSelect : Function?
}
class TreeUtils {
<<static>>
+cloneTree(nodes) : TreeNode[]T~~
+filterTree(nodes, keyword) : TreeNode[]T~~
+findNode(nodes, id) : TreeNode~T~?
+setNodeChildren(nodes, id, children) : void
+toggleNodeInTree(nodes, id) : bool
+countDescendants(node) : int
+countSelectedDescendants(node, selectedIds) : int
+getSelectedNodes(nodes, selectedIds) : TreeNode[]T~~
+isNodeFullySelected(node, selectedIds) : bool
+isNodeHalfSelected(node, selectedIds) : bool
+hasAnyDescendantSelected(node, selectedIds) : bool
+addNodeAndDescendants(node, selectedIds) : void
+removeNodeAndDescendants(node, selectedIds) : void
+expandSelectedNodeAncestors(nodes, selectedIds) : void
+findParentNode(roots, id) : TreeNode~T~?
+autoSelectParentChain(roots, node, selectedIds) : void
+autoDeselectParentChain(roots, node, selectedIds) : void
}
class TreeSelectHelper {
<<static>>
+show(context, treeData, ...) : Future~TreeNode~T~~?
}
class BottomActionBar {
+selectedCount : int
+maxCount : int?
+onViewSelected : VoidCallback?
+cancelLabel : String
+confirmLabel : String
+onCancel : VoidCallback?
+onConfirm : VoidCallback?
+disableWhenEmpty : bool
+confirmButtonColor : Color?
+confirmButtonTextColor : Color?
+cancelButtonColor : Color?
}
TreeSelectField~T~ --> TreeModalContent~T~ : "打开弹窗"
TreeModalContent~T~ --> TreeList~T~ : "渲染"
TreeModalContent~T~ --> BottomActionBar : "使用"
TreeList~T~ --> TreeUtils : "调用"
TreeModalContent~T~ --> TreeUtils : "调用"
TreeSelectHelper --> TreeModalContent~T~ : "构建"
TreeList~T~ --> KeywordHighlightStyle : "高亮"
```

**图表来源**
- [models/index.dart:1-123](file://lib/src/tree_select/models/index.dart#L1-L123)
- [tree_select.dart:1-423](file://lib/src/tree_select/tree_select.dart#L1-L423)
- [ui/tree_select_content.dart:1-311](file://lib/src/tree_select/ui/tree_select_content.dart#L1-L311)
- [ui/tree_list.dart:1-291](file://lib/src/tree_select/ui/tree_list.dart#L1-L291)
- [utils/index.dart:1-243](file://lib/src/tree_select/utils/index.dart#L1-L243)
- [tree_select_helper.dart:1-79](file://lib/src/tree_select/tree_select_helper.dart#L1-L79)
- [bottom_action_bar.dart:1-135](file://lib/src/widgets/bottom_action_bar.dart#L1-L135)

## 详细组件分析

### 数据模型与配置（TreeNode / TreeSelectConfig）
- **TreeNode<T>**: 描述树节点结构与状态，isLeaf=false 且 children 为空表示待懒加载；isExpanded 控制展开；isLoading 控制加载态；data 用于扩展附加信息
- **TreeSelectConfig<T>**: 集中配置选择器行为与外观，包括 title、searchHint、emptyText、showSearch、multiple、selectedIds、onSelect、onConfirm、onLoadChildren、cancelLabel、confirmLabel、parentSelectable、highlightStyle

**章节来源**
- [models/index.dart:1-123](file://lib/src/tree_select/models/index.dart#L1-L123)

### 统一便捷入口（TreeSelectHelper）
- **show<T>()**: 统一的显示方法，通过 multiple 参数区分单选和多选模式
  - 单选模式：选中节点后自动关闭，返回该节点，取消返回 null
  - 多选模式：通过 onConfirm 回调返回选中节点列表
- 内部通过 showModalBottomSheet 构建 TreeModalContent，设置高度约束与 SafeArea
- 支持所有配置选项：selectedIds 预选中、onSelect/onConfirm 回调、onLoadChildren 懒加载、高亮样式等

**章节来源**
- [tree_select_helper.dart:1-79](file://lib/src/tree_select/tree_select_helper.dart#L1-L79)

### 表单字段组件（TreeSelectField）
- **TreeSelectField<T>**: 全新的表单字段组件，完全集成 Flutter FormField
- 核心特性：
  - 支持单选和多选模式
  - 集成 WrapperContainer 提供默认 UI
  - 完整的表单校验和保存功能
  - 灵活的显示模式（text/compact/tags）
  - 自定义值构建器和图标配置
- State 管理：
  - 维护内部选中状态（_selectedNode/_selectedNodes）
  - 同步外部 selectedIds 变化
  - 处理清除状态和验证逻辑
  - 弹窗展开/折叠状态管理

**章节来源**
- [tree_select.dart:1-423](file://lib/src/tree_select/tree_select.dart#L1-L423)

### 弹窗内容组件（TreeModalContent）
- **TreeModalContent<T>**: 重构后的纯弹窗内容组件，移除动画相关代码
- 核心功能：
  - 搜索过滤与关键词高亮
  - 树形列表渲染与交互
  - 懒加载子节点处理
  - 父子节点联动选择
  - 底部操作栏集成
- 状态管理：
  - _searchController 搜索控制器
  - _selectedIds 选中状态集合
  - _filteredData 过滤后的数据
  - 祖先节点展开状态管理

**章节来源**
- [ui/tree_select_content.dart:1-311](file://lib/src/tree_select/ui/tree_select_content.dart#L1-L311)

### 树列表渲染（TreeList）
- **TreeList<T>**: 纯展示型树列表组件，专注于渲染和基础交互
- 核心功能：
  - 递归渲染节点，支持展开/折叠箭头、加载指示器、子节点数量 badge
  - 选择指示器（全/半选/未选）三态显示
  - 懒加载：当 isLeaf=false 且 children 为空时，展开触发 onLoadChildren
  - 高亮文本：使用 buildHighlightedText 对 label 进行关键词匹配与高亮
  - 父节点可选模式：splitIndicator 将文本区与圆圈区分开，避免误触

**章节来源**
- [ui/tree_list.dart:1-291](file://lib/src/tree_select/ui/tree_list.dart#L1-L291)

### 工具类（TreeUtils）
- **TreeUtils**: 静态工具类，提供无状态的树操作方法
- 核心方法分类：
  - 树操作：cloneTree、filterTree、findNode、setNodeChildren、toggleNodeInTree
  - 统计与查询：countDescendants、countSelectedDescendants、getSelectedNodes
  - 选中状态：isNodeFullySelected、isNodeHalfSelected、hasAnyDescendantSelected
  - 批量操作：addNodeAndDescendants、removeNodeAndDescendants
  - 展开与联动：expandSelectedNodeAncestors、findParentNode、autoSelectParentChain、autoDeselectParentChain

**章节来源**
- [utils/index.dart:1-243](file://lib/src/tree_select/utils/index.dart#L1-L243)

### 底部操作栏（BottomActionBar）
- **BottomActionBar**: 通用的底部操作栏组件，被 TreeModalContent 复用
- 核心特性：
  - 已选数量展示："已选 N 项"或"已选 N/M 项"
  - 空选禁用确认按钮（可配置）
  - 查看已选项功能（点击数量提示）
  - 可配置的按钮颜色和样式
  - 响应式布局适配

**章节来源**
- [bottom_action_bar.dart:1-135](file://lib/src/widgets/bottom_action_bar.dart#L1-L135)

### 关键词高亮（KeywordHighlightStyle / buildHighlightedText）
- 支持 enabled、useThemeColor、color、backgroundColor、bold 等配置
- 通过正则匹配 keyword，生成 RichText 片段实现高亮
- 默认颜色为琥珀黄，可强制使用主题色或自定义背景

**章节来源**
- [keyword_highlight.dart:1-129](file://lib/src/widgets/keyword_highlight.dart#L1-L129)

## 依赖关系分析
- **TreeSelectHelper** 依赖 TreeModalContent 与 models 中的配置类型
- **TreeSelectField** 依赖 TreeModalContent、WrapperContainer 和 FormField
- **TreeModalContent** 依赖 TreeList、TreeUtils、models 与 keyword_highlight
- **TreeList** 依赖 TreeUtils 与 keyword_highlight
- **TreeUtils** 仅依赖 models 中的 TreeNode

```mermaid
graph LR
Helper["TreeSelectHelper"] --> Modal["TreeModalContent"]
Field["TreeSelectField"] --> Modal
Modal --> List["TreeList"]
Modal --> Utils["TreeUtils"]
List --> Utils
Modal --> Model["model(TreeNode/Config)"]
List --> Highlight["keyword_highlight"]
Utils --> Model
Modal --> BottomBar["BottomActionBar"]
```

**图表来源**
- [tree_select_helper.dart:1-79](file://lib/src/tree_select/tree_select_helper.dart#L1-L79)
- [tree_select.dart:1-423](file://lib/src/tree_select/tree_select.dart#L1-L423)
- [ui/tree_select_content.dart:1-311](file://lib/src/tree_select/ui/tree_select_content.dart#L1-L311)
- [ui/tree_list.dart:1-291](file://lib/src/tree_select/ui/tree_list.dart#L1-L291)
- [utils/index.dart:1-243](file://lib/src/tree_select/utils/index.dart#L1-L243)
- [models/index.dart:1-123](file://lib/src/tree_select/models/index.dart#L1-L123)
- [bottom_action_bar.dart:1-135](file://lib/src/widgets/bottom_action_bar.dart#L1-L135)

## 性能与大数据优化
- **数据克隆与过滤**：每次搜索都会 cloneTree + filterTree，建议在大数据集上结合分页或虚拟滚动策略，减少一次性渲染量
- **懒加载**：通过 isLeaf=false 且 children 为空标识待加载，按需请求子节点，显著降低首屏内存占用
- **选中状态缓存**：使用 Set<T> 存储 selectedIds，O(1) 查找；联动父链时避免重复遍历
- **渲染优化**：TreeList 使用 ListView.builder 惰性构建；展开/折叠与加载状态局部 setState，避免整树重建
- **高亮性能**：keyword 为空时回退普通 Text，避免不必要的 RichText 构建
- **内存建议**：
  - 合理设置 maxHeight/minHeight，避免过高的底部面板导致大量节点渲染
  - 在 onLoadChildren 中限制单次返回的子节点数量，必要时分页加载
  - 避免在 data 中存放大对象，保持节点轻量

## 故障排查指南
- **搜索无结果**：检查 keyword 是否为空；确认 filterTree 是否正确执行；确保 label 大小写一致（内部已转小写比较）
- **懒加载不触发**：确认 isLeaf=false 且 children 为空；确保 onLoadChildren 非空；检查异常捕获分支是否隐藏 loading
- **父节点联动异常**：确认 parentSelectable 配置；检查 autoSelectParentChain/autoDeselectParentChain 是否被调用；确保 isChildrenLoaded 判断正确
- **高亮不生效**：检查 highlightStyle.enabled 是否为 true；确认 keyword 非空；验证 buildHighlightedText 参数传递
- **表单验证问题**：检查 validator 函数返回值；确认 required 属性设置；验证 onSaved 回调是否正常触发
- **BottomActionBar 按钮禁用**：确认 selectedCount > 0 或 disableWhenEmpty = false；检查 onConfirm 回调是否正确绑定

**章节来源**
- [ui/tree_select_content.dart:1-311](file://lib/src/tree_select/ui/tree_select_content.dart#L1-L311)
- [ui/tree_list.dart:1-291](file://lib/src/tree_select/ui/tree_list.dart#L1-L291)
- [utils/index.dart:1-243](file://lib/src/tree_select/utils/index.dart#L1-L243)
- [tree_select.dart:1-423](file://lib/src/tree_select/tree_select.dart#L1-L423)
- [bottom_action_bar.dart:1-135](file://lib/src/widgets/bottom_action_bar.dart#L1-L135)

## 结论
TreeSelect 经过重大重构后，提供了更加现代化和一致的 API 设计。新的架构完全对齐 DropdownChoose 的使用模式，通过 TreeSelectField 表单组件和统一的 show<T>() 方法，既简化了使用方式，又增强了表单集成能力。BottomActionBar 的复用进一步提升了组件的一致性和可维护性。针对大数据场景，推荐结合懒加载与分页策略，以获得更优的性能体验。

## 附录：API 参考与示例

### TreeSelectHelper 统一方法
- **show<T>()**: 统一的显示方法，支持单选和多选模式
  - 参数：context、treeData、title、searchHint、emptyText、showSearch、multiple、parentSelectable、selectedIds、onSelect、onConfirm、onLoadChildren、cancelLabel、confirmLabel、highlightStyle、各种颜色配置
  - 单选模式：multiple=false，选中后返回节点，取消返回 null
  - 多选模式：multiple=true，通过 onConfirm 回调返回选中节点列表

**章节来源**
- [tree_select_helper.dart:1-79](file://lib/src/tree_select/tree_select_helper.dart#L1-L79)

### TreeSelectField 表单组件参数
- **基础参数**：formLabel、subTitle、hintText、required、multiple、treeData、selectedIds
- **显示配置**：parentSelectable、showSearch、searchHint、emptyText、highlightStyle、title、各种按钮文字和颜色
- **表单集成**：validator、autovalidateMode、onSaved、formLayout、prefixIcon、displayMode、maxShowTags、valueBuilder
- **回调函数**：onSelect（单选）、onConfirm（多选）、onClear

**章节来源**
- [tree_select.dart:1-423](file://lib/src/tree_select/tree_select.dart#L1-L423)

### TreeModalContent 弹窗组件参数
- **数据配置**：treeData、selectedIds、onLoadChildren
- **显示配置**：title、searchHint、emptyText、showSearch、multiple、parentSelectable
- **交互配置**：onSelect、onConfirm、cancelLabel、confirmLabel
- **样式配置**：highlightStyle、各种按钮颜色配置

**章节来源**
- [ui/tree_select_content.dart:1-311](file://lib/src/tree_select/ui/tree_select_content.dart#L1-L311)

### TreeList 组件参数
- **数据参数**：nodes、selectedIds、multiple、emptyText
- **交互参数**：onLoadChildren、onChildrenLoaded、onNodeTap、keyword、highlightStyle、parentSelectable
- **高级参数**：onParentIndicatorTap、onParentExpandForSelect

**章节来源**
- [ui/tree_list.dart:1-291](file://lib/src/tree_select/ui/tree_list.dart#L1-L291)

### 数据模型与类型
- **TreeNode<T>**：id、label、parentId、children、isExpanded、isLeaf、isLoading、data、hasChildren、isChildrenLoaded
- **TreeSelectConfig<T>**：title、searchHint、emptyText、showSearch、multiple、selectedIds、onSelect、onConfirm、onLoadChildren、cancelLabel、confirmLabel、parentSelectable、highlightStyle
- **回调类型**：TreeNodeTapCallback、TreeNodeSelectCallback、TreeNodeLoadChildrenCallback

**章节来源**
- [models/index.dart:1-123](file://lib/src/tree_select/models/index.dart#L1-L123)

### 常见使用场景与最佳实践
- **表单集成**：使用 TreeSelectField 直接嵌入 Form，享受完整的表单校验和保存功能
- **快速弹出**：使用 TreeSelectHelper.show() 一行代码弹出选择面板
- **懒加载**：初始仅根节点，展开时按需加载子节点，提升首屏性能
- **搜索过滤**：实时过滤并高亮匹配文本，自动展开匹配路径
- **父子联动**：根据 parentSelectable 配置灵活控制父节点选择行为
- **大数据优化**：结合懒加载与分页策略，避免一次性加载过多数据

**章节来源**
- [tree_select_example.dart:1-369](file://example/lib/pages/tree_select_example.dart#L1-L369)
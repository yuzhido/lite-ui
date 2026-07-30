---
kind: design
name: DropdownChoose 后缀图标由状态驱动
source: session
category: adr
---

# DropdownChoose 后缀图标由状态驱动

_来源：2590cbb → b591e74 提交周期内记录的编码计划——内容为规划时意图，实现可能滞后或有出入。_

**状态：** accepted

## 背景
SuffixIconLabel 已支持根据 isExpanded、selectedValue、selectedValues 切换三种图标（close / 向下箭头 / 向右箭头），但 WrapperContainer 调用时未传参，DropdownChoose 也未维护展开状态，导致图标始终显示默认样式。

## 决策驱动
- UI 反馈一致性
- 组件状态与视图同步

## 备选方案
- **在 DropdownChoose 中维护 _isExpanded 状态并透传给 WrapperContainer** — 优点：简单直接，仅修改三处文件，无需引入额外状态管理
- **将图标逻辑上移到 DropdownChoose 自行绘制** _（已否决）_ — 优点：完全控制渲染；缺点：重复实现 SuffixIconLabel 的图标切换逻辑，增加维护成本

## 决策
在 _DropdownChooseState 中新增 bool _isExpanded 字段，onTap 打开弹窗前置为 true、showModalBottomSheet 返回后置为 false；同时将 selectedValue / selectedValues 透传给 WrapperContainer，由其转发给 SuffixIconLabel 完成图标切换。

## 影响
WrapperContainer 和 DropdownChoose 的 API 增加了可选参数；后续任何使用 SuffixIconLabel 的组件如需状态驱动图标，需自行传入对应参数。
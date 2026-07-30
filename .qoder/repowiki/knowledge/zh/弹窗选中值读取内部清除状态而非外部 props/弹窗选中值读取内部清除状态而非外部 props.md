---
kind: design
name: 弹窗选中值读取内部清除状态而非外部 props
source: session
category: adr
---

# 弹窗选中值读取内部清除状态而非外部 props

_来源：2590cbb → b591e74 提交周期内记录的编码计划——内容为规划时意图，实现可能滞后或有出入。_

**状态：** accepted

## 背景
当用户点击清除按钮后，_cleared 被置为 true，但 widget.selectedValues（外部 props）并未同步更新，导致再次打开弹窗时仍显示旧的选中项。

## 决策驱动
- 内部状态与弹窗视图一致性
- 避免依赖外部 props 同步

## 备选方案
- **新增 _modalSelectedValues() 方法感知 _cleared 状态** — 优点：最小改动，仅在弹窗打开路径上修正取值逻辑
- **强制父组件在清除后立即重建 Widget 以刷新 props** _（已否决）_ — 优点：props 始终一致；缺点：破坏受控组件语义，要求调用方承担状态同步责任

## 决策
在 _DropdownChooseState 中新增 _modalSelectedValues() 方法：若 _cleared 为 true 则返回 null，否则返回 _effectiveSelectedValues()；多选模式下弹窗 selectedValues 改用该方法计算。

## 影响
弹窗选中值的计算与外部 props 解耦，内部清除操作不再需要依赖父组件同步更新 props；但调用方仍需确保外部 state 最终与内部状态一致。
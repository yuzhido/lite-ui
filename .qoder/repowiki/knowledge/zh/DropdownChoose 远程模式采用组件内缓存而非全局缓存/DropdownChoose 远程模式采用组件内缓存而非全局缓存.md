---
kind: design
name: DropdownChoose 远程模式采用组件内缓存而非全局缓存
source: session
category: adr
---

# DropdownChoose 远程模式采用组件内缓存而非全局缓存

_来源：a98fd9d → 2590cbb 提交周期内记录的编码计划——内容为规划时意图，实现可能滞后或有出入。_

**状态：** accepted

## 背景
DropdownChoose 在 remote 模式下每次打开弹窗都会触发 onRemoteSearch('') 请求，导致重复网络调用和延迟。需要一种方式避免首次加载后的重复请求。

## 决策驱动
- 减少重复网络请求
- 保持组件独立性
- 避免引入全局状态管理

## 备选方案
- **组件内缓存 (_cachedRemoteItems)** — 优点：实现简单、无额外依赖、每个实例独立缓存互不干扰；缺点：页面销毁后缓存丢失，重新进入仍需首次加载
- **全局缓存（如 Provider/GetX）** _（已否决）_ — 优点：跨页面共享数据，彻底避免重复请求；缺点：增加架构复杂度、需要处理缓存失效和内存管理
- **通过 enableCache 参数控制** _（已否决）_ — 优点：可配置化；缺点：增加 API 复杂度且默认行为不明确

## 决策
在 _DropdownChooseState 中新增 _cachedRemoteItems 字段作为组件级缓存；首次打开时若已有缓存则直接使用，否则调用 onRemoteSearch('') 并将结果写入缓存；通过 onDataLoaded 回调将搜索结果回传给外部以更新缓存。

## 影响
首次打开弹窗有短暂等待但后续打开立即展示；每个 DropdownChoose 实例独立缓存不会互相污染；无需额外的 clearCache() 方法或 enableCache 开关；搜索功能和本地过滤模式完全不受影响。
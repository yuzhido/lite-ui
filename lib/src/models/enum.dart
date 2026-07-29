enum FormLayout {
  // 行布局
  row,
  // 列布局
  column,
}

// 边框类型枚举
enum BorderType {
  // 默认边框
  border,
  // 正常边框
  enabledBorder,
  // 聚焦边框
  focusedBorder,
}

/// 值显示模式
enum DisplayMode {
  /// 文本模式：单行显示，顿号分隔
  text,

  /// 标签模式：每个值显示为一个 tag，横向滚动
  tags,

  /// 紧凑模式：显示前 N 个 tag，剩余以 "+M" 显示
  compact,
}

/// 输入框类型枚举
enum InputTextType {
  /// 单行输入
  single,

  /// 多行输入（TextArea）
  multi,

  /// 密码输入框（带可见性切换）
  password,
}

// 点击后置图标的事件枚举
enum SuffixIconEvent {
  // 纯点击
  onTap,
  // 显示密码
  showPassword,
  // 清空内容
  clear,
}

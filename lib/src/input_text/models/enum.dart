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

/// 输入类型枚举
///
/// 用于 [InputText] 的 `inputType` 参数，控制用户只能输入指定类型的内容。
/// 底层通过 [TextInputFormatter] 实时拦截非法字符。
enum InputType {
  /// 普通文本（默认，不限制）
  text,

  /// 小数（只能输入数字和小数点，如 3.14）
  decimal,

  /// 整数（只能输入数字，如 123）
  integer,

  /// 中文（只能输入中文字符）
  chinese,

  /// 英文（只能输入英文字母）
  english,

  /// 单字符（只能输入单个 ASCII 字符，如键盘按一次输入的字母/数字/符号，不包含中文等多字节字符）
  char,
}

/// 校验规则类型枚举
///
/// 用于 [InputText] 的 `validRuleType` 参数，一个枚举值搞定常见校验。
/// `custom` 类型需配合 `validRules` 列表使用自定义规则。
enum ValidRuleType {
  /// 必填 + 手机号格式（中国大陆11位）
  phone,

  /// 必填 + 邮箱格式
  email,

  /// 必填 + 身份证号格式（18位）
  idCard,

  /// 必填 + URL格式
  url,

  /// 必填 + 纯数字
  numeric,

  /// 必填 + 有效小数格式（如 123、12.34、0.5，不允许 1.2.3、. 等非法格式）
  decimal,

  /// 必填 + 整数（支持负数）
  integer,

  /// 必填 + 中文姓名（2-20个中文字符）
  chineseName,

  /// 必填 + 至少6位 + 含大写字母
  password,

  /// 自定义规则（需配合 validRules 列表）
  custom,
}

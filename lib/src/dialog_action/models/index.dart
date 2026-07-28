/// 弹窗类型枚举
enum DialogType {
  /// 提示弹窗：标题 + 内容 + 单个确认按钮
  alert,

  /// 确认弹窗：标题 + 内容 + 取消/确认双按钮
  confirm,

  /// 输入弹窗：标题 + 输入框 + 取消/确认按钮
  input,

  /// 多操作弹窗：标题 + 内容 + 多按钮纵向排列
  multiAction,

  /// 自定义内容弹窗：仅壳子，内容由外部传入
  custom,
}

/// 弹窗按钮样式
enum DialogButtonStyle {
  /// 普通样式
  normal,

  /// 主要样式（高亮/主题色）
  primary,

  /// 危险样式（红色/警告色）
  destructive,
}

/// 弹窗操作按钮数据
///
/// 泛型参数：
/// - [V] value 的类型，用于标识按钮
class DialogActionButton<V> {
  /// 按钮文字
  final String label;

  /// 按钮值，用于标识返回
  final V value;

  /// 按钮样式
  final DialogButtonStyle style;

  /// 是否禁用
  final bool disabled;

  const DialogActionButton({required this.label, required this.value, this.style = DialogButtonStyle.normal, this.disabled = false});
}

/// 弹窗按钮点击回调：返回选中的 value
typedef DialogActionCallback<V> = void Function(V value);

/// 输入弹窗确认回调：返回输入文本
typedef DialogInputCallback = void Function(String text);

/// 弹窗预设图标类型
///
/// 用于快速设置弹窗顶部图标，也可通过 [DialogAction.show] 的
/// [icon] 参数传入自定义 Widget。
enum DialogPresetIcon {
  /// 成功（绿色勾选）
  success,

  /// 警告（橙色三角感叹号）
  warning,

  /// 错误（红色叉号）
  error,

  /// 信息（蓝色圆圈 i）
  info,
}

/// 内部默认值容器
class DialogDefaults {
  final String? title;
  final String? content;
  final String confirmLabel;
  final String cancelLabel;
  final String hintText;

  const DialogDefaults({this.title, this.content, this.confirmLabel = '确定', this.cancelLabel = '取消', this.hintText = '请输入'});
}

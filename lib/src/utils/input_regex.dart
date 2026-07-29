/// 输入类型正则表达式常量
class InputRegex {
  InputRegex._();

  /// 整数：仅数字 0-9
  static final RegExp integer = RegExp(r'^\d+$');

  /// 小数：数字和小数点（用于输入格式化器）
  static final RegExp decimalInput = RegExp(r'^[0-9.]*$');

  /// 小数：有效小数格式（用于校验，允许 123、12.34、0.5、.5、5.，不允许 1.2.3）
  static final RegExp decimalValid = RegExp(r'^\d*\.?\d*$');

  /// 中文：中文字符（包含基本汉字、扩展A区、兼容汉字等）
  static final RegExp chinese = RegExp(r'[\u4e00-\u9fff\u3400-\u4dbf\uf900-\ufaff]');

  /// 非中文：除中文外的所有字符（包含英文、数字、特殊字符@>等）
  static final RegExp nonChinese = RegExp(r'[^\u4e00-\u9fff\u3400-\u4dbf\uf900-\ufaff]');

  /// 标识符：只能以英文字母或下划线开头，后续可包含字母、数字、下划线（不允许中文和特殊字符）
  static final RegExp identifier = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');

  /// 英文：仅英文字母
  static final RegExp english = RegExp(r'[a-zA-Z]');

  /// 单字符：ASCII 范围（0x00-0x7F），排除中文等多字节字符
  static final RegExp char = RegExp(r'[\x00-\x7F]');

  /// 手机号：中国大陆 11 位
  static final RegExp phone = RegExp(r'^1[3-9]\d{9}$');

  /// 邮箱（改进版：禁止连续点、域名不以点/连字符开头结尾）
  static final RegExp email = RegExp(
    r'^[a-zA-Z0-9][a-zA-Z0-9._%+\-]*[a-zA-Z0-9]@[a-zA-Z0-9](?:[a-zA-Z0-9\-]*[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9\-]*[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$',
  );

  /// URL
  static final RegExp url = RegExp(r'^https?://[^\s/$.?#].[^\s]*$', caseSensitive: false);

  /// 身份证号：18 位
  static final RegExp idCard = RegExp(r'^\d{17}[\dXx]$');

  /// 密码大写字母
  static final RegExp passwordUpperCase = RegExp(r'[A-Z]');
}

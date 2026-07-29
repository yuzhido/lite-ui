import '../../utils/input_regex.dart';
import '../models/enum.dart';

class ValidRules {
  /// 必填校验
  /// [value] 输入值
  /// [message] 自定义错误提示
  static String? required(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? '此项为必填项';
    }
    return null;
  }

  /// 手机号校验（中国大陆11位手机号）
  /// [value] 输入值
  /// [message] 自定义错误提示
  static String? phone(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? '手机号是必填项不能为空';
    }
    if (!InputRegex.phone.hasMatch(value.trim())) {
      return message ?? '请输入正确的手机号';
    }
    return null;
  }

  /// 身份证号校验（18位，支持最后一位X）
  /// [value] 输入值
  /// [message] 自定义错误提示
  static String? idCard(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? '请输入身份证号';
    }
    final trimmed = value.trim();
    if (!InputRegex.idCard.hasMatch(trimmed)) {
      return message ?? '请输入正确的身份证号';
    }
    // 校验码验证（加权因子）
    const weights = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];
    const checkCodes = ['1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2'];
    int sum = 0;
    for (int i = 0; i < 17; i++) {
      sum += int.parse(trimmed[i]) * weights[i];
    }
    final checkCode = checkCodes[sum % 11];
    if (trimmed[17].toUpperCase() != checkCode) {
      return message ?? '请输入正确的身份证号';
    }
    return null;
  }

  /// 邮箱校验
  /// [value] 输入值
  /// [message] 自定义错误提示
  static String? email(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? '请输入邮箱';
    }
    if (!InputRegex.email.hasMatch(value.trim())) {
      return message ?? '请输入正确的邮箱地址';
    }
    return null;
  }

  /// URL校验
  /// [value] 输入值
  /// [message] 自定义错误提示
  static String? url(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? '请输入URL';
    }
    if (!InputRegex.url.hasMatch(value.trim())) {
      return message ?? '请输入正确的URL';
    }
    return null;
  }

  /// 最小长度校验
  /// [value] 输入值
  /// [minLength] 最小长度
  /// [message] 自定义错误提示
  static String? minLength(String? value, int minLength, {String? message}) {
    if (value == null || value.length < minLength) {
      return message ?? '长度不能少于$minLength个字符';
    }
    return null;
  }

  /// 最小长度校验规则工厂（返回可直接放入 validRules 列表的函数）
  /// 用法：`validRules: [ValidRules.minLengthRule(6, message: '至少6位')]`
  static String? Function(String?) minLengthRule(int len, {String? message}) {
    return (value) => minLength(value, len, message: message);
  }

  /// 最大长度校验
  /// [value] 输入值
  /// [maxLength] 最大长度
  /// [message] 自定义错误提示
  static String? maxLength(String? value, int maxLength, {String? message}) {
    if (value != null && value.length > maxLength) {
      return message ?? '长度不能超过$maxLength个字符';
    }
    return null;
  }

  /// 最大长度校验规则工厂（返回可直接放入 validRules 列表的函数）
  /// 用法：`validRules: [ValidRules.maxLengthRule(20, message: '最多20位')]`
  static String? Function(String?) maxLengthRule(int len, {String? message}) {
    return (value) => maxLength(value, len, message: message);
  }

  /// 数字校验（纯数字）
  /// [value] 输入值
  /// [message] 自定义错误提示
  static String? numeric(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? '请输入数字';
    }
    if (!InputRegex.integer.hasMatch(value.trim())) {
      return message ?? '只能输入数字';
    }
    return null;
  }

  /// 整数校验（支持负整数）
  /// [value] 输入值
  /// [message] 自定义错误提示
  static String? integer(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? '请输入整数';
    }
    final regex = RegExp(r'^-?\d+$');
    if (!regex.hasMatch(value.trim())) {
      return message ?? '只能输入整数';
    }
    return null;
  }

  /// 小数校验（支持整数、小数，不允许非法格式如 1.2.3、. 、空小数点）
  /// [value] 输入值
  /// [message] 自定义错误提示
  static String? decimal(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? '请输入有效数字';
    }
    final trimmed = value.trim();
    // 允许：123、12.34、0.5、.5、5. ，不允许：1.2.3、abc、空字符串
    if (!InputRegex.decimalValid.hasMatch(trimmed)) {
      return message ?? '只能输入数字和小数点';
    }
    // 排除纯小数点或空的情况
    if (trimmed == '.' || trimmed.isEmpty) {
      return message ?? '请输入有效数字';
    }
    return null;
  }

  /// 中文姓名校验（2-20个中文字符）
  /// [value] 输入值
  /// [message] 自定义错误提示
  static String? chineseName(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? '请输入姓名';
    }
    final regex = RegExp(r'^[\u4e00-\u9fa5]{2,20}$');
    if (!regex.hasMatch(value.trim())) {
      return message ?? '请输入正确的中文姓名';
    }
    return null;
  }

  /// 组合校验（依次执行多个校验规则，返回第一个错误）
  /// [value] 输入值
  /// [validators] 校验函数列表
  static String? compose(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }

  /// 根据 [ValidRuleType] 枚举 + 可选长度参数，自动构建校验规则列表
  ///
  /// [type] 校验规则类型
  /// [formLabel] 表单标签名（用于必填提示）
  /// [minLen] 最小长度（可选）
  /// [maxLen] 最大长度（可选）
  /// [customRules] 自定义规则列表（type 为 custom 时使用）
  static List<String? Function(String?)> buildRules({required ValidRuleType type, String? formLabel, int? minLen, int? maxLen, List<String? Function(String?)>? customRules}) {
    final rules = <String? Function(String?)>[];

    // custom 类型：只使用自定义规则 + 长度限制
    if (type == ValidRuleType.custom) {
      if (customRules != null) rules.addAll(customRules);
      if (minLen != null) rules.add((v) => minLength(v, minLen));
      if (maxLen != null) rules.add((v) => maxLength(v, maxLen));
      return rules;
    }

    final requiredMsg = formLabel != null ? '$formLabel是必填项不能为空' : '这个字段是必填项';
    rules.add((v) => required(v, message: requiredMsg));

    switch (type) {
      case ValidRuleType.phone:
        rules.add(phone);
        break;
      case ValidRuleType.email:
        rules.add(email);
        break;
      case ValidRuleType.idCard:
        rules.add(idCard);
        break;
      case ValidRuleType.url:
        rules.add(url);
        break;
      case ValidRuleType.numeric:
        rules.add(numeric);
        break;
      case ValidRuleType.decimal:
        rules.add(decimal);
        break;
      case ValidRuleType.integer:
        rules.add(integer);
        break;
      case ValidRuleType.chineseName:
        rules.add(chineseName);
        break;
      case ValidRuleType.password:
        rules.add((v) => minLength(v, 6, message: '密码至少6位'));
        rules.add((v) => v != null && v.contains(InputRegex.passwordUpperCase) ? null : '必须包含大写字母');
        break;
      case ValidRuleType.custom:
        break;
    }

    // 长度限制（可与任意类型组合）
    if (minLen != null) rules.add((v) => minLength(v, minLen));
    if (maxLen != null) rules.add((v) => maxLength(v, maxLen));

    return rules;
  }
}

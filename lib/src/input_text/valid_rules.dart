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
    final regex = RegExp(r'^1[3-9]\d{9}$');
    if (!regex.hasMatch(value.trim())) {
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
    final regex = RegExp(r'^\d{17}[\dXx]$');
    if (!regex.hasMatch(trimmed)) {
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
    final regex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) {
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
    final regex = RegExp(r'^(https?|ftp)://[^\s/$.?#].[^\s]*$', caseSensitive: false);
    if (!regex.hasMatch(value.trim())) {
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

  /// 数字校验（纯数字）
  /// [value] 输入值
  /// [message] 自定义错误提示
  static String? numeric(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? '请输入数字';
    }
    final regex = RegExp(r'^\d+$');
    if (!regex.hasMatch(value.trim())) {
      return message ?? '只能输入数字';
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
}

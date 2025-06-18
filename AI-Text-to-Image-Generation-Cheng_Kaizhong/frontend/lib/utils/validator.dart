class Validator {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '邮箱不能为空';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return '密码至少 6 位';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '用户名不能为空';
    }
    return null;
  }

  static String? validatePrompt(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入生成图像的描述';
    }
    return null;
  }
}

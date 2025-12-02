class AuthValidator {
  static String? nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }
    return null;
  }

  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email.';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }
}

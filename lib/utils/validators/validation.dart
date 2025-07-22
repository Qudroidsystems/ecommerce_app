class TValidator {
  /// Empty Text Validation
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  /// Username Validation
  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return 'Username is required.';
    }
    const pattern = r"^[a-zA-Z0-9_-]{3,20}$";
    final regex = RegExp(pattern);
    bool isValid = regex.hasMatch(username);
    if (isValid) {
      isValid = !username.startsWith('_') && !username.startsWith('-') && !username.endsWith('_') && !username.endsWith('-');
    }
    if (!isValid) {
      return 'Username must be 3-20 characters, alphanumeric, with optional underscores or hyphens (not at start/end).';
    }
    return null;
  }

  /// Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    final emailRegExp = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Invalid email address.';
    }
    return null;
  }

  /// Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }
    return null;
  }

  /// Phone Number Validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone number is optional
    }
    final phoneRegExp = RegExp(r'^\+?\d{10,15}$');
    if (!phoneRegExp.hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
      return 'Invalid phone number format (10-15 digits required).';
    }
    return null;
  }

  /// Zip Code Validation
  static String? validateZipCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Zip code is required.';
    }
    final zipRegExp = RegExp(r'^\d{4,10}(-\d{4})?$');
    if (!zipRegExp.hasMatch(value.trim())) {
      return 'Invalid zip code format (e.g., 12345 or 12345-6789).';
    }
    return null;
  }
}
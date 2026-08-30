class Validators {
  Validators._();

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? mobile(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mobile number is required';
    if (!RegExp(r'^[0-9]{7,15}$').hasMatch(value.trim())) return 'Enter a valid mobile number';
    return null;
  }

  /// For the optional mobile number field: blank is fine, but if something
  /// was typed it must look like a real number.
  static String? mobileOptional(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[0-9]{7,15}$').hasMatch(value.trim())) return 'Enter a valid mobile number';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter the OTP';
    if (value.trim().length < 4) return 'Enter the complete OTP';
    return null;
  }

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// For the optional email field itself: blank is fine, but if something
  /// was typed it must look like a real address.
  static String? emailOptional(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!_emailPattern.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  /// For the "Get OTP" action, where an email is actually required.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Enter a valid name';
    return null;
  }
}

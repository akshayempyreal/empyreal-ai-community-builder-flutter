class FormValidators {
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName is required' : 'This field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (value.length < 10) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;
    if (value.trim().length < min) {
      return fieldName != null 
        ? '$fieldName must be at least $min characters' 
        : 'Minimum $min characters required';
    }
    return null;
  }

  static String? wordCount(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;
    final words = value.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
    if (words < min) {
      return fieldName != null 
        ? '$fieldName must have at least $min words' 
        : 'Minimum $min words required';
    }
    return null;
  }

  static String? numberRange(String? value, double min, double max, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;
    final num = double.tryParse(value);
    if (num == null) return 'Enter a valid number';
    if (num < min || num > max) {
      return fieldName != null 
        ? '$fieldName must be between $min and $max' 
        : 'Value must be between $min and $max';
    }
    return null;
  }
}

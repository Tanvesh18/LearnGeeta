enum PasswordStrength { none, weak, medium, strong }

class PasswordValidationResult {
  const PasswordValidationResult({required this.errorMessage});

  final String? errorMessage;

  bool get isValid => errorMessage == null;
}

class PasswordUtils {
  const PasswordUtils._();

  static final RegExp _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
  static final RegExp _repeatedCharRegex = RegExp(r'(.)\1{3,}');
  static final RegExp _sequentialRegex = RegExp(
    r'(?:012|123|234|345|456|567|678|789|890|abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)',
  );
  static const List<String> _commonPasswords = [
    'password',
    '123456',
    '123456789',
    'qwerty',
    'abc123',
    'password123',
    'admin',
    'letmein',
    'welcome',
    'monkey',
    'dragon',
    'passw0rd',
  ];

  static PasswordStrength strengthFor(String password) {
    if (password.isEmpty) return PasswordStrength.none;

    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (_specialCharRegex.hasMatch(password)) score++;
    if (_repeatedCharRegex.hasMatch(password)) score--;
    if (_sequentialRegex.hasMatch(password.toLowerCase())) score--;

    if (score >= 5) return PasswordStrength.strong;
    if (score >= 3) return PasswordStrength.medium;
    if (score >= 1) return PasswordStrength.weak;
    return PasswordStrength.none;
  }

  static PasswordValidationResult validate(
    String password, {
    String? email,
    bool requireStrong = false,
  }) {
    if (password.isEmpty) {
      return const PasswordValidationResult(
        errorMessage: 'Please enter a password',
      );
    }

    if (password.length < 8) {
      return const PasswordValidationResult(
        errorMessage: 'Password must be at least 8 characters',
      );
    }

    final strength = strengthFor(password);
    if (requireStrong && strength == PasswordStrength.weak) {
      return const PasswordValidationResult(
        errorMessage:
            'Password is too weak. Include uppercase, lowercase, numbers, and special characters.',
      );
    }

    if (_commonPasswords.contains(password.toLowerCase())) {
      return const PasswordValidationResult(
        errorMessage: 'This password is too common. Choose a unique password.',
      );
    }

    if (email != null && email.isNotEmpty) {
      final emailPrefix = email.split('@').first.toLowerCase();
      if (emailPrefix.isNotEmpty &&
          password.toLowerCase().contains(emailPrefix)) {
        return const PasswordValidationResult(
          errorMessage: 'Password should not contain your email address',
        );
      }
    }

    if (_repeatedCharRegex.hasMatch(password)) {
      return const PasswordValidationResult(
        errorMessage:
            'Password should not contain 4 or more repeated characters',
      );
    }

    if (_sequentialRegex.hasMatch(password.toLowerCase())) {
      return const PasswordValidationResult(
        errorMessage: 'Password should not contain sequential characters',
      );
    }

    return const PasswordValidationResult(errorMessage: null);
  }

  static bool containsUppercase(String password) =>
      RegExp(r'[A-Z]').hasMatch(password);

  static bool containsLowercase(String password) =>
      RegExp(r'[a-z]').hasMatch(password);

  static bool containsNumber(String password) =>
      RegExp(r'[0-9]').hasMatch(password);

  static bool containsSpecialCharacter(String password) =>
      _specialCharRegex.hasMatch(password);

  static bool hasRepeatedCharacters(String password) =>
      _repeatedCharRegex.hasMatch(password);

  static bool hasSequentialCharacters(String password) =>
      _sequentialRegex.hasMatch(password.toLowerCase());
}

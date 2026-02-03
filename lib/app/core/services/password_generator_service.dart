// =====================================================
// ShieldX Password Generator Service
// File: password_generator_service.dart
// =====================================================
// Description: Advanced password generation with memorable options
// =====================================================

import 'dart:math';

class PasswordGeneratorService {
  static final _random = Random.secure();

  // Character sets
  static const _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const _numbers = '0123456789';
  static const _symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  // Memorable word lists
  static const _adjectives = [
    'Happy', 'Clever', 'Swift', 'Brave', 'Bright', 'Calm', 'Bold', 'Quick',
    'Wise', 'Noble', 'Strong', 'Gentle', 'Proud', 'Lucky', 'Silent', 'Royal',
  ];

  static const _nouns = [
    'Tiger', 'Eagle', 'Dragon', 'Phoenix', 'Lion', 'Wolf', 'Falcon', 'Panther',
    'Ocean', 'Mountain', 'River', 'Thunder', 'Storm', 'Fire', 'Star', 'Moon',
  ];

  /// Generate a strong random password
  static String generatePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    if (length < 8) length = 8;
    if (length > 128) length = 128;

    String chars = '';
    if (includeUppercase) chars += _uppercase;
    if (includeLowercase) chars += _lowercase;
    if (includeNumbers) chars += _numbers;
    if (includeSymbols) chars += _symbols;

    if (chars.isEmpty) chars = _lowercase + _numbers;

    // Ensure at least one character from each selected set
    String password = '';
    if (includeUppercase) password += _uppercase[_random.nextInt(_uppercase.length)];
    if (includeLowercase) password += _lowercase[_random.nextInt(_lowercase.length)];
    if (includeNumbers) password += _numbers[_random.nextInt(_numbers.length)];
    if (includeSymbols) password += _symbols[_random.nextInt(_symbols.length)];

    // Fill the rest randomly
    while (password.length < length) {
      password += chars[_random.nextInt(chars.length)];
    }

    // Shuffle the password
    final charList = password.split('')..shuffle(_random);
    return charList.join();
  }

  /// Generate a memorable passphrase
  static String generateMemorablePassword({
    int wordCount = 3,
    bool includeNumbers = true,
    bool includeSymbols = false,
    String separator = '-',
  }) {
    final words = <String>[];

    for (int i = 0; i < wordCount; i++) {
      if (i % 2 == 0) {
        words.add(_adjectives[_random.nextInt(_adjectives.length)]);
      } else {
        words.add(_nouns[_random.nextInt(_nouns.length)]);
      }
    }

    String password = words.join(separator);

    if (includeNumbers) {
      final number = _random.nextInt(9999).toString().padLeft(4, '0');
      password += separator + number;
    }

    if (includeSymbols) {
      password += _symbols[_random.nextInt(_symbols.length)];
    }

    return password;
  }

  /// Generate a PIN code
  static String generatePin({int length = 6}) {
    String pin = '';
    for (int i = 0; i < length; i++) {
      pin += _random.nextInt(10).toString();
    }
    return pin;
  }

  /// Calculate password strength (0-100)
  static int calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int score = 0;

    // Length score (max 30 points)
    if (password.length >= 8) score += 10;
    if (password.length >= 12) score += 10;
    if (password.length >= 16) score += 10;

    // Character variety (max 40 points)
    if (password.contains(RegExp(r'[a-z]'))) score += 10;
    if (password.contains(RegExp(r'[A-Z]'))) score += 10;
    if (password.contains(RegExp(r'[0-9]'))) score += 10;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 10;

    // Complexity score (max 30 points)
    final uniqueChars = password.split('').toSet().length;
    score += (uniqueChars / password.length * 30).round();

    // Penalty for common patterns
    if (password.toLowerCase().contains('password')) score -= 20;
    if (password.contains('123')) score -= 10;
    if (password.contains('abc')) score -= 10;

    return score.clamp(0, 100);
  }

  /// Get password strength label
  static String getPasswordStrengthLabel(int strength) {
    if (strength >= 80) return 'Very Strong';
    if (strength >= 60) return 'Strong';
    if (strength >= 40) return 'Medium';
    if (strength >= 20) return 'Weak';
    return 'Very Weak';
  }

  /// Get suggested password improvements
  static List<String> getSuggestions(String password) {
    final suggestions = <String>[];

    if (password.length < 12) {
      suggestions.add('Increase length to at least 12 characters');
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      suggestions.add('Add uppercase letters');
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      suggestions.add('Add lowercase letters');
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      suggestions.add('Add numbers');
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      suggestions.add('Add special characters');
    }

    if (password.toLowerCase().contains('password') ||
        password.contains('123') ||
        password.contains('abc')) {
      suggestions.add('Avoid common patterns');
    }

    return suggestions;
  }

  /// Check if password is commonly used
  static bool isCommonPassword(String password) {
    const commonPasswords = [
      'password', '123456', '12345678', 'qwerty', 'abc123',
      'password123', '111111', 'welcome', 'admin', 'letmein',
    ];

    return commonPasswords.contains(password.toLowerCase());
  }
}

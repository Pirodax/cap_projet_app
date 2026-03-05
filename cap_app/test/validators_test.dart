import 'package:flutter_test/flutter_test.dart';

/// Email validation regex (same as in sign_in_screen.dart & sign_up_screen.dart)
String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Email requis';
  final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v);
  if (!ok) return 'Email invalide';
  return null;
}

/// Password validation
String? validatePassword(String? value) {
  final v = value ?? '';
  if (v.isEmpty) return 'Mot de passe requis';
  return null;
}

void main() {
  group('Email validator', () {
    test('empty email returns error', () {
      expect(validateEmail(''), 'Email requis');
    });

    test('null email returns error', () {
      expect(validateEmail(null), 'Email requis');
    });

    test('whitespace-only email returns error', () {
      expect(validateEmail('   '), 'Email requis');
    });

    test('valid email passes', () {
      expect(validateEmail('test@example.com'), isNull);
    });

    test('email without @ is invalid', () {
      expect(validateEmail('testexample.com'), 'Email invalide');
    });

    test('email without domain is invalid', () {
      expect(validateEmail('test@'), 'Email invalide');
    });

    test('email without TLD is invalid', () {
      expect(validateEmail('test@example'), 'Email invalide');
    });

    test('email with spaces is trimmed and validated', () {
      expect(validateEmail('  test@example.com  '), isNull);
    });

    test('email with multiple @ is invalid', () {
      expect(validateEmail('test@@example.com'), 'Email invalide');
    });

    test('complex valid email passes', () {
      expect(validateEmail('user.name+tag@sub.domain.fr'), isNull);
    });
  });

  group('Password validator', () {
    test('empty password returns error', () {
      expect(validatePassword(''), 'Mot de passe requis');
    });

    test('null password returns error', () {
      expect(validatePassword(null), 'Mot de passe requis');
    });

    test('any non-empty password passes', () {
      expect(validatePassword('abc'), isNull);
    });

    test('long password passes', () {
      expect(validatePassword('a' * 100), isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:dinelify_app/core/utils/validators.dart';

void main() {
  group('Validators.mobile', () {
    test('rejects empty input', () {
      expect(Validators.mobile(''), isNotNull);
      expect(Validators.mobile(null), isNotNull);
    });

    test('rejects non-numeric or too-short input', () {
      expect(Validators.mobile('abc'), isNotNull);
      expect(Validators.mobile('123'), isNotNull);
    });

    test('accepts a valid mobile number', () {
      expect(Validators.mobile('9876543210'), isNull);
    });
  });

  group('Validators.mobileOptional', () {
    test('accepts an empty value', () {
      expect(Validators.mobileOptional(''), isNull);
      expect(Validators.mobileOptional(null), isNull);
    });

    test('rejects non-numeric or too-short input', () {
      expect(Validators.mobileOptional('abc'), isNotNull);
      expect(Validators.mobileOptional('123'), isNotNull);
    });

    test('accepts a valid mobile number', () {
      expect(Validators.mobileOptional('9876543210'), isNull);
    });
  });

  group('Validators.otp', () {
    test('rejects short codes', () {
      expect(Validators.otp('12'), isNotNull);
    });

    test('accepts a 4-digit code', () {
      expect(Validators.otp('1234'), isNull);
    });
  });

  group('Validators.name', () {
    test('rejects single-character names', () {
      expect(Validators.name('A'), isNotNull);
    });

    test('accepts a real name', () {
      expect(Validators.name('Demo User'), isNull);
    });
  });

  group('Validators.emailOptional', () {
    test('accepts an empty value', () {
      expect(Validators.emailOptional(''), isNull);
      expect(Validators.emailOptional(null), isNull);
    });

    test('rejects a malformed address', () {
      expect(Validators.emailOptional('not-an-email'), isNotNull);
    });

    test('accepts a valid address', () {
      expect(Validators.emailOptional('user@example.com'), isNull);
    });
  });

  group('Validators.email', () {
    test('rejects an empty value', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('rejects a malformed address', () {
      expect(Validators.email('not-an-email'), isNotNull);
    });

    test('accepts a valid address', () {
      expect(Validators.email('user@example.com'), isNull);
    });
  });
}

import 'dart:typed_data';

import 'package:t3_crypto_objects/src/argon2/argon2_derivation_service.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bytes.dart';
import 'package:test/test.dart';

void main() {
  group('Argon2DerivationService Tests', () {
    late Argon2DerivationService argon2Service;
    late EntropyBytes entropyBytes;

    setUp(() {
      argon2Service = Argon2DerivationService();
      entropyBytes = EntropyBytes(Uint8List.fromList([1, 2, 3, 4, 5]));
    });

    test('deriveWithHighMemory returns a non-null derived hash', () {
      final derivedHash = argon2Service.deriveWithHighMemory(1, entropyBytes);

      expect(derivedHash, isNotNull);
      expect(derivedHash.length, 128, reason: 'Expected hash length is 128 bytes.');
    });

    test('deriveWithHighMemory with multiple iterations produces different results', () {
      final derivedHash1 = argon2Service.deriveWithHighMemory(1, entropyBytes);
      final derivedHash2 = argon2Service.deriveWithHighMemory(2, entropyBytes);

      expect(derivedHash1, isNot(derivedHash2));
    });

    test('deriveWithModerateMemory returns a valid derived hash', () {
      final derivedHash = argon2Service.deriveWithModerateMemory(entropyBytes);

      expect(derivedHash, isNotNull);
      expect(derivedHash.length, 128, reason: 'Expected hash length is 128 bytes.');
    });

    test('deriveKey generates a valid SecretKey', () async {
      const key = 'test_key';
      final secretKey = await argon2Service.deriveKey(key);

      expect(secretKey, isNotNull);
    });
  });
}

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

      expect(derivedHash.value, isNotNull);
      expect(derivedHash.value, isNot(equals(entropyBytes.value)),
          reason:
              'The derived hash should be different from the input entropy.');
    });

    test('deriveWithHighMemory is deterministic for the same input', () {
      final derivedHash1 = argon2Service.deriveWithHighMemory(1, entropyBytes);
      final derivedHash2 = argon2Service.deriveWithHighMemory(1, entropyBytes);

      expect(derivedHash1.value, equals(derivedHash2.value),
          reason: 'The derived hash should be the same for identical inputs.');
    });

    test('deriveWithHighMemory produces different hashes for different inputs',
        () {
      final entropyBytes2 =
          EntropyBytes(Uint8List.fromList([1, 2, 3, 4, 5, 6]));

      final derivedHash1 = argon2Service.deriveWithHighMemory(1, entropyBytes);
      final derivedHash2 = argon2Service.deriveWithHighMemory(1, entropyBytes2);

      expect(derivedHash1.value, isNot(equals(derivedHash2.value)),
          reason:
              'The derived hash should change if the input entropy changes.');
    });

    test(
        'deriveWithHighMemory with multiple iterations produces different results',
        () {
      final derivedHash1 = argon2Service.deriveWithHighMemory(1, entropyBytes);
      final derivedHash2 = argon2Service.deriveWithHighMemory(2, entropyBytes);

      expect(derivedHash1.value, isNot(derivedHash2.value));
    });

    test('deriveWithModerateMemory returns a valid derived hash', () {
      final derivedHash = argon2Service.deriveWithModerateMemory(entropyBytes);

      expect(derivedHash.value, isNotNull);
      expect(derivedHash.value, isNot(equals(entropyBytes.value)),
          reason:
              'The derived hash should be different from the input entropy.');
    });

    test('deriveWithModerateMemory is deterministic for the same input', () {
      final derivedHash1 = argon2Service.deriveWithModerateMemory(entropyBytes);
      final derivedHash2 = argon2Service.deriveWithModerateMemory(entropyBytes);

      expect(derivedHash1.value, equals(derivedHash2.value),
          reason: 'The derived hash should be the same for identical inputs.');
    });

    test('deriveWithModerateMemory produces different hashes for different inputs',
        () {
      final entropyBytes2 =
          EntropyBytes(Uint8List.fromList([1, 2, 3, 4, 5, 6]));

      final derivedHash1 = argon2Service.deriveWithModerateMemory(entropyBytes);
      final derivedHash2 = argon2Service.deriveWithModerateMemory(entropyBytes2);

      expect(derivedHash1.value, isNot(equals(derivedHash2.value)),
          reason:
              'The derived hash should change if the input entropy changes.');
    });

    test('deriveKey generates a valid SecretKey', () async {
      const key = 'test_key';
      final secretKey = await argon2Service.deriveKey(key);

      expect(secretKey, isNotNull);
    });
  });
}

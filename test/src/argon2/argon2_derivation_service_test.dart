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
      final expectedDerivedHash = EntropyBytes(Uint8List.fromList([141, 66, 110, 64, 190, 43, 57, 204, 226, 254, 178, 237, 2, 198, 203, 45, 136, 11, 204, 234, 188, 44, 169, 85, 119, 42, 191, 114, 212, 212, 90, 22, 217, 54, 218, 85, 14, 175, 97, 103, 13, 92, 12, 60, 185, 213, 75, 202, 181, 166, 83, 53, 51, 206, 11, 195, 30, 204, 252, 232, 252, 210, 84, 255, 86, 190, 242, 204, 231, 176, 142, 23, 56, 112, 153, 108, 173, 240, 117, 72, 43, 89, 145, 2, 180, 82, 141, 37, 223, 219, 35, 78, 211, 101, 191, 243, 122, 124, 23, 104, 152, 196, 237, 12, 164, 84, 66, 245, 111, 205, 161, 47, 92, 136, 48, 172, 177, 190, 107, 78, 207, 47, 119, 237, 8, 255, 62, 119]));
      
      final derivedHash = argon2Service.deriveWithHighMemory(1, entropyBytes);

      expect(derivedHash.value, equals(expectedDerivedHash.value),
          reason: 'The derived hash should be as expected');
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

    test('deriveWithHighMemory with multiple iterations produces different results',
        () {
      final derivedHash1 = argon2Service.deriveWithHighMemory(1, entropyBytes);
      final derivedHash2 = argon2Service.deriveWithHighMemory(2, entropyBytes);

      expect(derivedHash1.value, isNot(derivedHash2.value));
    });

    test('deriveWithModerateMemory returns a valid derived hash', () {
      final expectedDerivedHash = EntropyBytes(Uint8List.fromList([12, 39, 0, 74, 214, 196, 56, 142, 165, 181, 77, 234, 94, 126, 150, 56, 239, 113, 243, 109, 129, 255, 111, 6, 240, 216, 95, 224, 118, 35, 149, 107, 11, 140, 140, 102, 221, 53, 132, 214, 153, 149, 104, 44, 114, 25, 63, 89, 254, 45, 93, 194, 167, 131, 86, 1, 214, 3, 122, 238, 65, 162, 237, 114, 151, 154, 254, 208, 243, 217, 27, 205, 207, 255, 157, 4, 196, 180, 106, 102, 204, 185, 13, 150, 49, 86, 3, 201, 155, 89, 6, 255, 242, 2, 60, 174, 119, 248, 128, 16, 3, 139, 134, 146, 227, 5, 239, 92, 92, 70, 159, 48, 200, 54, 70, 1, 68, 87, 230, 150, 18, 166, 24, 211, 214, 94, 240, 146]));
      
      final derivedHash = argon2Service.deriveWithModerateMemory(entropyBytes);

      expect(derivedHash.value, equals(expectedDerivedHash.value),
          reason: 'The derived hash should be as expected');
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
      List<int> expectedKeyBytes = [82, 122, 191, 172, 244, 65, 63, 218, 218, 161, 210, 144, 198, 165, 180, 146, 110, 58, 232, 129, 7, 57, 1, 145, 6, 180, 19, 173, 157, 50, 4, 161];

      final secretKey = await argon2Service.deriveKey(key);
      
      expect(await secretKey.extractBytes(), equals(expectedKeyBytes));
    });
  });
}

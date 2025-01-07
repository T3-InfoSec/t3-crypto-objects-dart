import 'dart:typed_data';

import 'package:t3_crypto_objects/src/encryption/ciphertext.dart';
import 'package:t3_crypto_objects/src/encryption/eka.dart';
import 'package:t3_crypto_objects/src/encryption/plaintext.dart';
import 'package:test/test.dart';

void main() {
  group('Eka', () {
    test('Eka generates a key with the correct format and length', () {
      final eka = Eka();
      expect(eka.key, isNotNull);
      expect(eka.key.replaceAll(' ', '').length, equals(32),
          reason: 'Eka key should have 32 hexadecimal characters excluding spaces.');
    });

    test('Eka.fromKey uses the provided key', () {
      const providedKey = 'AABB CCDD EEFF 1122 3344 5566 7788 99AA';
      final eka = Eka.fromKey(providedKey);
      expect(eka.key, equals(providedKey),
          reason: 'Eka.fromKey should correctly assign the provided key.');
    });

    test('Generated key is different each time', () {
      final eka1 = Eka();
      final eka2 = Eka();
      expect(eka1.key, isNot(equals(eka2.key)),
          reason: 'Two Eka instances should generate different keys.');
    });

    test('Eka.encrypt and decrypt works as expected', () async {
      final eka = Eka.fromKey('AABB CCDD EEFF 1122 3344 5566 7788 99AA');
      final plaintext = Plaintext(Uint8List.fromList([1, 2, 3, 4, 5]));

      Ciphertext ciphertext = await eka.encrypt(plaintext);
      Plaintext finalPlaintext = await eka.decrypt(ciphertext.concatenation());

      expect(plaintext.value, equals(finalPlaintext.value),
          reason: 'plaintext shoud be equals to finalPlaintext');
    });
  });
}

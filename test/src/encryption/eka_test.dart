import 'package:t3_crypto_objects/crypto_objects.dart';
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
      expect(eka.key, equals(providedKey), reason: 'Eka.fromKey should correctly assign the provided key.');
    });

    test('Generated key is different each time', () {
      final eka1 = Eka();
      final eka2 = Eka();
      expect(eka1.key, isNot(equals(eka2.key)), reason: 'Two Eka instances should generate different keys.');
    });
  });
  group(
    'TLP',
    () {
      test('TLP.fromKey uses the provided key', () {
        final providedKey = BigInt.from(3459835368198562363);
        final tlp = Tlp.fromKey(providedKey);
        expect(tlp.key, equals(providedKey), reason: 'TLP.fromKey should correctly assign the provided key.');
      });

      test('Generated key is different each time', () {
        final tlp1 = Tlp();
        final tlp2 = Tlp();
        expect(tlp1.key, isNot(equals(tlp2.key)), reason: 'Two TLP instances should generate different keys.');
      });
    },
  );
}

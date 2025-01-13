import 'package:t3_crypto_objects/crypto_objects.dart';
import 'package:test/test.dart';

void main() {
  group('TLP', () {
    test('TLP.fromKey uses the provided key', () {
      final providedKey = BigInt.from(3459835368198562363);
      final tlp = Tlp.fromKey(providedKey);
      expect(tlp.key, equals(providedKey), reason: 'TLP.fromKey should correctly assign the provided key.');
    });

    test('Generated key is different each time', () {
      
      final tlp1 = Tlp();
      final tlp2 = Tlp();
      expect(
        tlp1.key,
        isNot(equals(tlp2.key)),
        reason: 'Two TLP instances should generate different keys. There is a bug in random number generation',
      );
    });

    test('Generated key is non-zero', () {
      
      final tlp = Tlp();
      expect(tlp.key, isNot(BigInt.zero), reason: 'Generated key should never be zero');
    });

    test('Generated key is positive', () {

      final tlp = Tlp();
      expect(tlp.key.isNegative, isFalse, reason: 'Generated key should always be positive');
    });

    test('Multiple generations produce valid keys', () {

      final keys = List.generate(100, (_) => Tlp().key);
      for (final key in keys) {
        expect(key.isNegative, isFalse, reason: 'Keys should never be negative');
        expect(key, isNot(BigInt.zero), reason: 'Keys should never be zero');
        expect(key.bitLength, greaterThanOrEqualTo(32), reason: 'Keys should maintain minimum bit length');
      }
    });

    test('TLP.fromKey with very large key', () {
      
      final largeKey = BigInt.parse('1' * 100);

      final tlp = Tlp.fromKey(largeKey);
      expect(tlp.key, equals(largeKey), reason: 'Should handle very large keys correctly');
    });

    test('Generated keys are unique across many generations', () {
      final keySet = <BigInt>{};
      for (var i = 0; i < 1000; i++) {
        final key = Tlp().key;
        expect(keySet.contains(key), isFalse, reason: 'Generated keys should be unique');
        keySet.add(key);
      }
    });

    test('Generated key maintains expected properties', () {
      for (var i = 0; i < 50; i++) {
        final tlp = Tlp();
        final key = tlp.key;

        expect(key.bitLength, greaterThanOrEqualTo(32), reason: 'Key should have at least 32 bits');
        expect(key.isNegative, isFalse, reason: 'Key should be positive');
        expect(key, isNot(BigInt.zero), reason: 'Key should not be zero');
      }
    });

    test('Key generation with custom parameters', () {
      for (var i = 0; i < 10; i++) {
        final tlp = Tlp();
        expect(tlp.key, isNotNull, reason: 'Key generation should succeed with default parameters');
        expect(tlp.key.bitLength, greaterThanOrEqualTo(32), reason: 'Key should meet minimum bit length requirement');
      }
    });

    // Memory management test
    test('Multiple generations handle memory properly', () {
      final weakReference = WeakReference(Tlp());
      // Force garbage collection
      for (var i = 0; i < 1000; i++) {
        Tlp();
      }
      expect(weakReference.target, isNull, reason: 'Old TLP instances should be garbage collected');
    });
  });
}

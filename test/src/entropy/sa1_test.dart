import 'package:test/test.dart';
import 'package:t3_crypto_objects/src/entropy/sa0.dart';
import 'package:t3_crypto_objects/src/entropy/sa1.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa.dart';
import 'package:t3_crypto_objects/src/argon2/argon2_derivation_service.dart';

void main() {
  group('Sa1', () {
    test('Sa1 initializes with empty byte array of specified size', () {
      final sa1 = Sa1();
      expect(sa1.value.length, equals(Sa1.bytesSize));
      expect(sa1.value, everyElement(equals(0)));
    });

    test('Sa1 derivation updates value from Sa0', () {
      final formosa = Formosa.fromRandomWords();
      final sa0 = Sa0(formosa);
      final sa1 = Sa1();

      sa1.from(sa0);

      expect(sa1.value, isNot(equals(sa0.value)));
    });

    test('Sa1.toString returns correct format', () {
      final sa1 = Sa1();

      expect(sa1.toString(), equals('Sa1(seed: ${String.fromCharCodes(sa1.value)}'));
    });

    test('Sa1 generates intermediate states during derivation', () {
      final sa1 = Sa1();
      const iterations = 5;

      final finalHash = sa1.deriveWithIntermediateStates(iterations);

      expect(sa1.intermediates.length, equals(iterations));

      for (int i = 0; i < iterations; i++) {
        expect(sa1.intermediates[i].iteration, equals(i + 1));
        expect(sa1.intermediates[i].value, isNotEmpty);
      }

      expect(finalHash, equals(sa1.intermediates.last.value));
    });
  });
}

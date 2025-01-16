import 'package:t3_crypto_objects/src/entropy/sa1i.dart';
import 'package:test/test.dart';
import 'package:t3_crypto_objects/src/entropy/sa0.dart';
import 'package:t3_crypto_objects/src/entropy/sa1.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa.dart';

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

      expect(sa1.toString(), equals('Sa1(seed: ${sa1.value})'));
    });

    test('Sa1 generates intermediate states during derivation', () {
      final formosa = Formosa.fromRandomWords();
      final sa0 = Sa0(formosa);
      final sa1 = Sa1();

      sa1.from(sa0);

      const iterations = 5;

      final finalHash = sa1.deriveWithIntermediateStates(iterations);

      expect(sa1.intermediateStates.length, equals(5));
      expect(sa1.intermediateStates.last.value, equals(finalHash));
      expect(sa1.intermediateStates.last.currentIteration, equals(5));
      expect(sa1.intermediateStates.last.totalIterations, equals(5));
    });

    test('Sa1 resume derivation', () {
      final formosa = Formosa.fromRandomWords();
      final sa0 = Sa0(formosa);
      final sa1 = Sa1();

      sa1.from(sa0);

      final auxIntermediateHash1 = sa1.deriveWithIntermediateStates(1);
      final auxIntermediateHash2 = sa1.deriveWithIntermediateStates(2);
      final auxIntermediateHash3 = sa1.deriveWithIntermediateStates(3);

      final expectedFinalHash = sa1.deriveWithIntermediateStates(5);

      sa1.intermediateStates = List.of([
        Sa1i(auxIntermediateHash1, 1, 5),
        Sa1i(auxIntermediateHash2, 2, 5),
        Sa1i(auxIntermediateHash3, 3, 5)
      ]);

      final actualFinalHash = sa1.resumeDerivation();

      expect(actualFinalHash, equals(expectedFinalHash));
      expect(sa1.intermediateStates.last.value, actualFinalHash);
      expect(sa1.intermediateStates.last.currentIteration, equals(5));
      expect(sa1.intermediateStates.last.totalIterations, equals(5));
    });

    test('Sa1 check derivation step should return true when it is correct', () {
      final formosa = Formosa.fromRandomWords();
      final sa0 = Sa0(formosa);
      final sa1 = Sa1();

      sa1.from(sa0);

      final auxIntermediateHash1 = sa1.deriveWithIntermediateStates(1);
      final auxIntermediateHash2 = sa1.deriveWithIntermediateStates(2);
      final auxIntermediateHash3 = sa1.deriveWithIntermediateStates(3);

      sa1.intermediateStates = List.of([
        Sa1i(auxIntermediateHash1, 1, 5),
        Sa1i(auxIntermediateHash2, 2, 5),
        Sa1i(auxIntermediateHash3, 3, 5)
      ]);

      final intermediateState = sa1.deriveWithIntermediateStates(1);

      sa1.checkDerivationStep(Sa1i(intermediateState, 1, 3));
    });
  });
}

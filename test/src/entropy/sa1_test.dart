import 'dart:typed_data';

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
      final sa1 = Sa1();
      const iterations = 5;

      final finalHash = sa1.deriveWithIntermediateStates(iterations);

      expect(sa1.intermediateState.value, equals(finalHash));
      expect(sa1.intermediateState.currentIteration, equals(5));
      expect(sa1.intermediateState.totalIterations, equals(5));
    });

    test('Sa1 resume derivation', () {
      final sa1 = Sa1();

      final auxIntermediateHash = sa1.deriveWithIntermediateStates(3);

      sa1.intermediateState = Sa1i(auxIntermediateHash, 3, 5);

      final expectedFinalHash = sa1.deriveWithIntermediateStates(5);

      final actualFinalHash = sa1.resumeDerivation();

      expect(actualFinalHash, equals(expectedFinalHash));
      expect(sa1.intermediateState.value, actualFinalHash);
      expect(sa1.intermediateState.currentIteration, equals(5));
      expect(sa1.intermediateState.totalIterations, equals(5));
    });
  });
}

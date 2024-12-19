import 'package:t3_crypto_objects/src/entropy/formosa/formosa.dart';
import 'package:test/test.dart';
import 'dart:typed_data';
import 'package:t3_crypto_objects/src/entropy/sa0.dart';
import 'package:t3_crypto_objects/src/entropy/sa2.dart';
import 'package:t3_crypto_objects/src/entropy/sa3.dart';

void main() {
  group('Sa3', () {
    test('Sa3 initializes with empty byte array of specified size', () {
      final sa3 = Sa3();
      expect(sa3.value.length, equals(Sa3.bytesSize));
      expect(sa3.value, everyElement(equals(0)));
    });

    test('Sa3 derivation updates value from Sa0 and Sa2', () {
      final sa0 = Sa0(Formosa.fromRandomWords());
      final sa2 = Sa2();
      final initialValue = Uint8List(Sa2.bytesSize)..fillRange(0, Sa2.bytesSize, 84);
      sa2.value = initialValue;

      final sa3 = Sa3();
      sa3.from(sa0, sa2);

      expect(sa3.value, isNot(equals(Uint8List(Sa3.bytesSize))));
    });

    test('Sa3.toString returns correct format', () {
      final sa3 = Sa3();
      sa3.value.fillRange(0, sa3.value.length, 42);

      expect(sa3.toString(), equals('Sa3(seed: ${String.fromCharCodes(sa3.value)}'));
    });
  });
}

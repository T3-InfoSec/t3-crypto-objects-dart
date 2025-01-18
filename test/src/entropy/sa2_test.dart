import 'package:test/test.dart';
import 'dart:typed_data';
import 'package:t3_crypto_objects/src/entropy/sa1.dart';
import 'package:t3_crypto_objects/src/entropy/sa2.dart';

void main() {
  group('Sa2', () {
    test('Sa2 initializes with empty byte array of specified size', () {
      final sa2 = Sa2();
      expect(sa2.value.length, equals(Sa2.bytesSize));
      expect(sa2.value, everyElement(equals(0)));
    });

    test('Sa2 derivation updates value from Sa1', () async {
      final sa1 = Sa1();
      final initialValue = Uint8List(Sa1.bytesSize)..fillRange(0, Sa1.bytesSize, 42);
      sa1.value = initialValue;

      final sa2 = Sa2();
      await sa2.from(1, sa1);

      expect(sa2.value, isNot(equals(Uint8List(Sa2.bytesSize))));
      expect(sa2.value, isNot(contains(0)));
    });

    test('Sa2.toString returns correct format', () {
      final sa2 = Sa2();
      sa2.value.fillRange(0, sa2.value.length, 42);

      expect(sa2.toString(), equals('Sa2(seed: ${sa2.value})'));
    });
  });
}

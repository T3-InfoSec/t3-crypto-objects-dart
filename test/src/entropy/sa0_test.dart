import 'package:t3_crypto_objects/src/entropy/sa0.dart';
import 'package:test/test.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_base.dart';

void main() {
  group('Sa0', () {
    test('Sa0 initializes correctly with formosa', () {
      final formosa = Formosa.fromRandomWords();
      final sa0 = Sa0(formosa);

      expect(sa0.formosa, equals(formosa));
      expect(sa0.value, equals(formosa.value));
    });

    test('Sa0 has the correct bytesSize', () {
      expect(Sa0.bytesSize, equals(128));
    });

    test('Sa0.toString returns correct format', () {
      final formosa = Formosa.fromRandomWords();
      final sa0 = Sa0(formosa);

      expect(sa0.toString(), equals('Sa0(value: ${String.fromCharCodes(formosa.value)}'));
    });
  });
}

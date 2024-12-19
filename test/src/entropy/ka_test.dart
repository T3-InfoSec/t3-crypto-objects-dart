import 'package:t3_crypto_objects/src/entropy/ka.dart';
import 'package:test/test.dart';
import 'package:convert/convert.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa.dart';

void main() {
  group('KA', () {
    test('KA initializes correctly with valid Formosa', () {
      final formosa = Formosa.fromRandomWords();
      final ka = KA(formosa);

      expect(ka.hexadecimalValue, equals(hex.encode(formosa.value)));
      expect(ka.formosa, equals(formosa));
      expect(ka.value, equals(formosa.value));
    });


    test('KA generates correct hexadecimal value', () {
      final formosa = Formosa.fromRandomWords();
      final ka = KA(formosa);

      expect(ka.hexadecimalValue, equals(hex.encode(formosa.value)));
      expect(ka.formosa, equals(formosa));
    });
  });
}

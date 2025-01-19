import 'package:t3_crypto_objects/src/argon2/argon2_derivation_service.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bytes.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_theme.dart';
import 'package:t3_crypto_objects/src/entropy/ka.dart';
import 'package:test/test.dart';
import 'package:convert/convert.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa.dart';

void main() {
  group('KA', () {
    test('KA initializes correctly with valid hexadecimal Value Formosa', () {
      final entropy = EntropyBytes.fromRandom(1024);
      final ka = KA(entropy.value);

      final expectedFormosa = Formosa(
            Argon2DerivationService()
                .lowMemoryDerivation(EntropyBytes(entropy.value))
                .value, FormosaTheme.bip39);

      expect(ka.hexadecimalValue, equals(hex.encode(entropy.value)));
      expect(ka.formosa, equals(expectedFormosa));
      expect(ka.value, equals(entropy.value));
    });
  });
}

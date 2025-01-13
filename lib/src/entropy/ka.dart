import 'package:convert/convert.dart';
import 'package:t3_crypto_objects/src/argon2/argon2_derivation_service.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bytes.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_theme.dart';
import 'package:t3_crypto_objects/src/entropy/node.dart';

/// The final node in the tacit derivation process, derived from the PA0 seed.
///
/// Represents the final derived state that generates the secret key, derived into
/// [formosa] and encoded in hexadecimal [hexadecimalValue]
class KA extends Node {
  final Formosa formosa;
  final String hexadecimalValue;

  /// Initializes the [KA] node instance with an entropy [value].
  ///
  /// Automatically encodes [hexadecimalValue] from entropy [value]
  /// and generate Formosa bip39 during construction.
  KA(super.value)
      : hexadecimalValue = hex.encode(value),
        formosa = Formosa(
            Argon2DerivationService()
                .deriveWithLowMemory(EntropyBytes(value))
                .value,
            FormosaTheme.bip39);
}

import 'package:convert/convert.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa.dart';
import 'package:t3_crypto_objects/src/entropy/node.dart';

/// The final node in the tacit derivation process, derived from the PA0 seed.
///
/// Represents the final derived state that generates the secret key, derived into
/// [formosa] and encoded in hexadecimal [hexadecimalValue]
class KA extends Node {
  final FormosaEntropy formosa;
  final String hexadecimalValue;

  /// Initializes the [KA] node instance with a [formosa] entropy.
  ///
  /// Automatically encodes [hexadecimalValue] from formosa entropy [value] during construction.
  KA(this.formosa)
      : hexadecimalValue = hex.encode(formosa.value),
        super(formosa.value);
}

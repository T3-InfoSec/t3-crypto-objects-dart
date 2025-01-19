import 'package:t3_crypto_objects/src/encryption/plaintext.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa.dart';

/// Sa0 represents the initial entropy entered into the derivation protocol.
///
/// This seed is Critical so it has to be encrypted using a key for secure storage.
class Sa0 extends Plaintext {
  Formosa formosa;

  /// Constructs an [Sa0] instance
  ///
  /// with an initial [formosa]
  Sa0(this.formosa)
      : super(formosa.value);

  @override
  String toString() => 'Sa0(value: $value';
}

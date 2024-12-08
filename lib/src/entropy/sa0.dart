import 'package:t3_crypto_objects/src/encryption/critical.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa.dart';

/// Sa0 represents the initial entropy entered into the derivation protocol.
///
/// This seed is Critical so it has to be encrypted using a key for secure storage.
class Sa0 extends Critical {
  static final int bytesSize = 128;

  FormosaEntropy formosa;

  /// Constructs an [Sa0] instance
  ///
  /// with an initial [value] of [bytesSize]
  Sa0(this.formosa)
      : super(formosa.entropy.value);

  @override
  String toString() => 'Sa0(value: ${String.fromCharCodes(value)}';
}

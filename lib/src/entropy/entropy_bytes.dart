import 'dart:math';
import 'dart:typed_data';

import 'package:t3_crypto_objects/src/entropy/entropy_bits.dart';

/// Represents entropy in a generic sense, serving as the information 
/// required in processes that generate a secret or manage uncertainty.
/// 
/// The [EntropyBytes] class encapsulates a [Uint8List] value, which can hold
/// raw data used in cryptographic derivations, secret generation, or other
/// processes where controlled randomness or uncertainty is needed.
class EntropyBytes  extends EntropyBits {
  static const int byteMaxValue = 256;

  /// Constructs a [EntropyBytes] from a [Uint8List].
  EntropyBytes(Uint8List value)
      : super(EntropyBits.bytesToBits(value));

  /// Accesses the internal bytes of the entropy.
  Uint8List get value => toBytes();

  /// Setter for the internal bytes of the entropy.
  set value(Uint8List newValue) {
    bits = EntropyBits.bytesToBits(newValue);
  }

  factory EntropyBytes.fromRandom(int entropyByteLength) {
    Uint8List value = Uint8List(entropyByteLength);
    Random random = Random.secure();
    for (int i = 0; i < value.length; i++) {
      value[i] = random.nextInt(byteMaxValue);
    }
    return EntropyBytes(value);
  }
}

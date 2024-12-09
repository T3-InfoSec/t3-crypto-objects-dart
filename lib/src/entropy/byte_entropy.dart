import 'dart:math';
import 'dart:typed_data';

import 'package:t3_crypto_objects/src/entropy/bit_entropy.dart';

/// Represents entropy in a generic sense, serving as the information 
/// required in processes that generate a secret or manage uncertainty.
/// 
/// The [ByteEntropy] class encapsulates a [Uint8List] value, which can hold
/// raw data used in cryptographic derivations, secret generation, or other
/// processes where controlled randomness or uncertainty is needed.
class ByteEntropy  extends BitEntropy {

  /// Constructs a [ByteEntropy] from a [Uint8List].
  ByteEntropy(Uint8List value)
      : super(_bytesToBits(value));

  factory ByteEntropy.fromRandom({int wordsNumber = 12}) {
    const int byteMaxValue = 256;
    const double bytesPerWord = 1.33;    
    final int entropyBytesForSeed = (wordsNumber * bytesPerWord).ceil();

    Uint8List value = Uint8List(entropyBytesForSeed);
    Random random = Random.secure();
    for (int i = 0; i < value.length; i++) {
      value[i] = random.nextInt(byteMaxValue);
    }
    return ByteEntropy(value);
  }

  /// Accesses the internal bytes of the entropy.
  Uint8List get value => toBytes();

  /// Setter for the internal bytes of the entropy.
  set value(Uint8List newValue) {
    bits = _bytesToBits(newValue);
  }

  /// Converts a [Uint8List] to a list of bits (`List<bool>`).
  static List<bool> _bytesToBits(Uint8List bytes) {
    return bytes.expand((byte) => _byteToBits(byte)).toList();
  }

  /// Converts a single byte to a list of 8 bits (`List<bool>`).
  static List<bool> _byteToBits(int byte) {
    return List.generate(8, (i) => (byte & (1 << (7 - i))) != 0);
  }
}

import 'dart:math';
import 'dart:typed_data';

/// Represents entropy in a generic sense, serving as the information 
/// required in processes that generate a secret or manage uncertainty.
/// 
/// The [Entropy] class encapsulates a [Uint8List] value, which can hold
/// raw data used in cryptographic derivations, secret generation, or other
/// processes where controlled randomness or uncertainty is needed.
class Entropy {
  Uint8List value;

  /// Constructs an [Entropy] instance with the provided [value].
  /// 
  /// The [value] parameter is a [Uint8List] containing the data required
  /// for processes that depend on entropy, such as cryptographic operations,
  /// secret derivation, or state tracking. This class provides a flexible
  /// abstraction for representing such data.
  Entropy(this.value);

  factory Entropy.fromRandom({int wordsNumber = 12}) {
    const int byteMaxValue = 256;
    const double bytesPerWord = 1.33;    
    final int entropyBytesForSeed = (wordsNumber * bytesPerWord).ceil();

    Uint8List value = Uint8List(entropyBytesForSeed);
    Random random = Random.secure();
    for (int i = 0; i < value.length; i++) {
      value[i] = random.nextInt(byteMaxValue);
    }
    return Entropy(value);
  }
}

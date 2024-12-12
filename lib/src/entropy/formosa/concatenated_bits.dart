import 'package:t3_crypto_objects/src/entropy/entropy_bits.dart';

/// This class represents the concatenation in [bits]
/// of the entropy and checksum bits in [Formosa].
class ConcatenatedBits extends EntropyBits {
  ConcatenatedBits(super.bits);
}
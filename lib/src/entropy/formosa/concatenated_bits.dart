import 'package:t3_crypto_objects/src/entropy/checksum_bits.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bits.dart';

/// This class represents the concatenation in [bits]
/// of the entropy and checksum bits in [Formosa].
class ConcatenatedBits extends EntropyBits {
  static const int bitsPerGroup = 33;
  static const int entropyBitsPerGroup = 32;

  EntropyBits entropyBits;
  ChecksumBits checksumBits;

  ConcatenatedBits(super.bits)
      : entropyBits = _getEntropyBits(bits),
        checksumBits = _getChecksumBits(bits);

  static EntropyBits _getEntropyBits(List<bool> bits) {
    final totalBitCount = bits.length;
    final checksumLength =
        totalBitCount ~/ bitsPerGroup;

    return EntropyBits(bits.take(totalBitCount - checksumLength).toList());
  }

  static ChecksumBits _getChecksumBits(List<bool> bits) {
    final totalBitCount = bits.length;
    final checksumLength =
        totalBitCount ~/ bitsPerGroup;

    return ChecksumBits(bits.skip(totalBitCount - checksumLength).toList());
  }

  static int getEntropyBitsLength(int concatenatedBitsLength) {
    return concatenatedBitsLength ~/ bitsPerGroup * entropyBitsPerGroup;
  }
}

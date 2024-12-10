import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';

import 'entropy_bits.dart';

/// Represents checksum bits used for entropy validation.
///
/// A checksum ensures data integrity by verifying that the entropy value
/// matches the expected checksum derived from a cryptographic hash function.
class ChecksumBits extends EntropyBits {
  
  /// Constructor to initialise the checksum bits.
  /// Ensures that it contains only 4 bits.
  ChecksumBits(super.bits);

  /// Checks if the checksum is valid for a given entropy value.
  bool isValid(Uint8List entropy) {
    final hashObject = sha256.convert(entropy);

    int checksumLengthBits = (entropy.length * 8) ~/ 32;

    final expectedChecksumBits = hashObject.bytes
        .expand((byte) => EntropyBits.byteToBits(byte))
        .take(checksumLengthBits)
        .toList();

    return ListEquality().equals(bits, expectedChecksumBits);
  }
}

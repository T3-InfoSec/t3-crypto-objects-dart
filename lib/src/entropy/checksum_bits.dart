import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'entropy_bits.dart';

/// Represents checksum bits used for entropy validation.
class ChecksumBits extends EntropyBits {
  /// Constructor to initialise the checksum bits.
  ChecksumBits(super.bits);

  /// Constructor to initialise the checksum bits from entropy hash.
  factory ChecksumBits.fromEntropyHash(Uint8List value) {
    final hash = sha256.convert(value);
    final checksumLengthBits = (value.length * 8) ~/ 32;
    final checksumBits = hash.bytes
        .expand((byte) => EntropyBits.byteToBits(byte))
        .take(checksumLengthBits)
        .toList();
    return ChecksumBits(checksumBits);
  }
}

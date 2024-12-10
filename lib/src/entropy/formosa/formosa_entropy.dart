import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:t3_crypto_objects/src/entropy/checksum_bits.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bits.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bytes.dart';

abstract class FormosaEntropy extends EntropyBytes {
  static final leastMultiple = 4;
  dynamic formosaTheme;
  late final ChecksumBits checksumBits;

  /// Creates an instance of Formosa using the given formosaTheme and initial entropy.
  FormosaEntropy(Uint8List value, this.formosaTheme) : super(value) {
    if (value.length % leastMultiple != 0) {
      throw ArgumentError(
          'Formosa entropy length must be multiple of $leastMultiple');
    }
    checksumBits = _calculateChecksumBits();
  }

  factory FormosaEntropy.fromMnemonic(String mnemonic, dynamic formosaTheme) {
    throw UnimplementedError('fromMnemonic must be implemented in subclasses');
  }

  /// Return derived mnemonic based on the entropy [value]
  /// and the words defined by the specified FormosaTheme.
  String getMnemonic();

  /// Validates whether the entropy value is correct according to the checksum bits.
  bool validate() {
    return checksumBits.isValid(value);
  }

  /// Calculates the checksum bits from the entropy value using BIP39 standard
  ChecksumBits _calculateChecksumBits() {
    final hashObject = sha256.convert(value);

    int checksumLengthBits = (value.length * 8) ~/ 32;
    
    final checksumBitsList = hashObject.bytes
        .expand((byte) => EntropyBits.byteToBits(byte))
        .take(checksumLengthBits)
        .toList();

    return ChecksumBits(checksumBitsList);
  }
}

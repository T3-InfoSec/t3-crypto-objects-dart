import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:t3_crypto_objects/src/entropy/checksum_bits.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bits.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bytes.dart';

import 'formosa_theme.dart';

/// A wrap implementation upon bip39 for supporting semantically connected
/// words implementation upon multiple supported themes.
class Formosa extends EntropyBytes {
  static const leastMultiple = 4;
  static var invalidFormosa = Formosa(Uint8List(0), FormosaTheme.bip39);

  final dynamic formosaTheme;
  final ChecksumBits checksumBits;

  Formosa(super.value, this.formosaTheme, {ChecksumBits? checksumBits})
      : checksumBits = checksumBits ?? _generateChecksumBits(value) {
    if (length % leastMultiple != 0) {
      throw ArgumentError(
          'Formosa entropy length must be a multiple of $leastMultiple');
    }
  }

  /// Constructor that  creates a formosa instance from [concatenatedBits].
  factory Formosa.fromConcatenatedBits(
    List<bool> concatenatedBits, {
    required FormosaTheme formosaTheme,
  }) {
    final totalBits = concatenatedBits.length;
    final checksumLength = totalBits ~/ 33;

    final entropyBits = concatenatedBits.take(totalBits - checksumLength).toList();
    final checksumBits = concatenatedBits.skip(totalBits - checksumLength).toList();

    final entropyBytes = EntropyBits.boolBitsToBytes(entropyBits);

    return Formosa(
      entropyBytes,
      formosaTheme,
      checksumBits: ChecksumBits(checksumBits),
    );
  }

  /// Constructor that  creates a formosa instance from [mnemonic].
  factory Formosa.fromMnemonic(
    String mnemonic, {
    FormosaTheme formosaTheme = FormosaTheme.bip39,
  }) {
    List<String> words = mnemonic.split(' ');
    var wordsDict = formosaTheme.data;

    int phraseSize = wordsDict.wordsPerPhrase();

    // Check if the number of words is a multiple of the expected size per phrase
    if (words.length % phraseSize != 0) {
      return invalidFormosa;
    }

    // Calculate the length of the concatenated bits, and determine the checksum and entropy lengths
    int concatenationLenBits = words.length * wordsDict.bitsPerPhrase();
    int checksumLengthBits = concatenationLenBits ~/ 33;
    int entropyLengthBits = concatenationLenBits - checksumLengthBits;

    // Get the phrase indexes based on the word list
    List<int> phraseIndexes = wordsDict.getPhraseIndexes(words);

    // Convert phrase indexes to a concatenated bit string
    String concatenationBits = phraseIndexes
        .map((index) => index.toRadixString(2).padLeft(11, '0'))
        .join();

    // Extract the entropy bits from the concatenation (excluding the checksum bits)
    String entropyBits = concatenationBits.substring(0, entropyLengthBits);

    // Convert the string of bits to a Uint8List entropy bytes.
    Uint8List entropy = EntropyBits.stringBitsToBytes(entropyBits);

    // Create the ChecksumBits from the corresponding bits of the concatenation
    List<bool> bits = concatenationBits
        .substring(entropyLengthBits)  // Get the checksum part
        .split('')
        .map((bit) => bit == '1')
        .toList();

    ChecksumBits checksumBits = ChecksumBits(bits);

    return Formosa(entropy, formosaTheme, checksumBits: checksumBits);
  }

  String getMnemonic() => _entropyToMnemonic(value);

  bool isValid() => _validateChecksum(value, checksumBits);

  static ChecksumBits _generateChecksumBits(Uint8List value) {
    final hash = sha256.convert(value);
    final checksumLengthBits = (value.length * 8) ~/ 32;
    final checksumBits = hash.bytes
        .expand((byte) => EntropyBits.byteToBits(byte))
        .take(checksumLengthBits)
        .toList();
    return ChecksumBits(checksumBits);
  }

  String _entropyToMnemonic(Uint8List entropy) {
    final entropyBits = entropy
        .map((byte) => byte.toRadixString(2).padLeft(8, '0'))
        .join();
    final checksumBitsString =
        checksumBits.bits.map((bit) => bit ? '1' : '0').join();
    final concatenatedBits = entropyBits + checksumBitsString;
    return formosaTheme.data.getSentencesFromBits(concatenatedBits).join(' ');
  }

  static bool _validateChecksum(Uint8List entropy, ChecksumBits checksum) {
    final hash = sha256.convert(entropy);
    final checksumLengthBits = (entropy.length * 8) ~/ 32;
    final expectedChecksumBits = hash.bytes
        .expand((byte) => EntropyBits.byteToBits(byte))
        .take(checksumLengthBits)
        .toList();
    return ListEquality().equals(checksum.bits, expectedChecksumBits);
  }
}


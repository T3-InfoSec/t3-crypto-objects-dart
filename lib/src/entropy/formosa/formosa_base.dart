import 'dart:typed_data';

import 'package:t3_crypto_objects/src/entropy/checksum_bits.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bits.dart';

import 'formosa_entropy.dart';
import 'formosa_theme.dart';

/// A wrap implementation upon bip39 for supporting semantically connected
/// words implementation upon multiple supported themes.
class Formosa extends FormosaEntropy {
  Formosa(super.value, FormosaTheme super.formosaTheme);

  /// Creates an instance of Formosa using the given [formosaTheme] and initial [mnemonic].
  ///
  /// The [entropy] is automatically derived based on the initial mnemonic provided
  /// and the words defined by the specified FormosaTheme.
  @override
  factory Formosa.fromMnemonic(
    String mnemonic, {
    FormosaTheme formosaTheme = FormosaTheme.bip39,
  }) {
    Uint8List entropy = _toEntropy(mnemonic, formosaTheme);
    final formosa = Formosa(entropy, formosaTheme);
    if (!formosa.validate()) {
      throw ArgumentError('The derived entropy does not match the checksum.');
    }
    return formosa;
  }

  @override
  String getMnemonic() {
    return _toMnemonic(value);
  }

  /// Generates the mnemonic phrase based on the given [value].
  ///
  /// This process involves converting entropy bits into mnemonic phrases
  /// using the logic defined in the associated FormosaTheme. The mnemonic
  /// reflects the checksum-integrated mnemonic representation of the entropy.
  String _toMnemonic(Uint8List value) {
    String entropyBits = value
        .map((e) => e.toRadixString(2).padLeft(8, '0'))
        .join();

    String checksumBitsString = checksumBits.bits.map((bit) => bit ? '1' : '0').join();

    String dataBits = entropyBits + checksumBitsString;

    List sentences = formosaTheme.data.getSentencesFromBits(dataBits);
    return sentences.join(' ');
  }

  /// Returns the entropy [value] from a given [mnemonic] and [formosaTheme].
  /// This method now also validates the checksum before proceeding with entropy conversion.
  static Uint8List _toEntropy(String mnemonic, FormosaTheme formosaTheme) {
    List<String> words = mnemonic.split(' ');
    var wordsDict = formosaTheme.data;

    int phraseSize = wordsDict.wordsPerPhrase();

    // Check if the number of words is a multiple of the expected size per phrase
    if (words.length % phraseSize != 0) {
      throw ArgumentError('The number of words is not a multiple of the expected size per sentence.');
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

    // Convert the bits to a Uint8List (entropy)
    Uint8List entropy = EntropyBits.bitsToUint8List(entropyBits);

    // Now we need to validate the checksum
    // Create the ChecksumBits from the corresponding bits of the concatenation
    List<bool> checksumBits = concatenationBits
        .substring(entropyLengthBits)  // Get the checksum part
        .split('')
        .map((bit) => bit == '1')
        .toList();

    ChecksumBits checksum = ChecksumBits(checksumBits);

    // Validate the checksum against the entropy
    if (!checksum.isValid(entropy)) {
      throw ArgumentError('The checksum is invalid for the given mnemonic.');
    }

    return entropy;  // Return the valid entropy if checksum is valid
  }
}

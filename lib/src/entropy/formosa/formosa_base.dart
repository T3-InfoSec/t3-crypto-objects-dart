import 'dart:math';
import 'dart:typed_data';

import 'package:t3_crypto_objects/src/entropy/checksum_bits.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bits.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bytes.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/concatenated_bits.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_service.dart';

import 'formosa_theme.dart';

/// A class that implements BIP39 with support for semantically connected word
/// implementations across multiple themes.
///
/// This class encapsulates entropy bytes and provides methods to generate a
/// mnemonic, validate checksums, and convert between bits and entropy. It supports
/// different themes for the word list and checksum mechanisms. This class is
/// designed to ensure that entropy lengths are valid and that the formosa
/// instance is correctly validated after creation.
class Formosa extends EntropyBytes {
  static const leastMultiple = 4;

  final dynamic formosaTheme;
  final ChecksumBits checksumBits;

  Formosa(super.value, this.formosaTheme, {ChecksumBits? checksumBits})
      : checksumBits =
            checksumBits ?? ChecksumBits.fromEntropyHash(value) {
    if (!FormosaService.isValidEntropyLength(value)) {
      throw ArgumentError(
          'Formosa entropy length must be a multiple of ${FormosaService.leastMultiple}');
    }
    if (!FormosaService.isValidEntropyChecksum(value, this.checksumBits)) {
      throw ArgumentError('Invalid checksum for the given entropy.');
    }
  }

  /// Creates a [Formosa] instance from a concatenated list of bits.
  ///
  /// This constructor takes a list of boolean values representing concatenated
  /// bits (including both entropy and checksum bits) and constructs a [Formosa]
  /// object. The method ensures that the checksum and entropy are correctly
  /// parsed from the [concatenatedBits].
  factory Formosa.fromConcatenatedBits(
    ConcatenatedBits concatenatedBits, {
    required FormosaTheme formosaTheme,
  }) {
    return generateFormosaFromContatenatedBits(
        concatenatedBits.bits, formosaTheme);
  }

  /// Creates a [Formosa] instance from a mnemonic string.
  ///
  /// This constructor takes a [mnemonic] (a space-separated list of words) and
  /// converts it into a [Formosa] instance. The mnemonic is parsed into bits,
  /// with the entropy and checksum being separated and validated. The mnemonic
  /// must conform to the expected word count and structure for the chosen theme.
  factory Formosa.fromMnemonic(
    String mnemonic, {
    FormosaTheme formosaTheme = FormosaTheme.bip39,
  }) {
    List<String> words = mnemonic.split(' ');
    int phraseSize = formosaTheme.data.wordsPerPhrase();

    if (!FormosaService.wordsExistInTheme(words, formosaTheme)) {
      throw ArgumentError(
          'Some word of the nemonic phrase is not contained in the given theme.');
    }
    if (!FormosaService.isValidWordCount(words.length, phraseSize)) {
      throw ArgumentError(
          'The number of words is not a multiple of the expected size for a given sentence.');
    }
    Formosa formosa = generateFormosaFromMnemonic(mnemonic, formosaTheme);
    if (!FormosaService.isValidEntropyChecksum(
        formosa.value, formosa.checksumBits)) {
      throw ArgumentError('Checksumbits don\'t match');
    }
    return formosa;
  }

  factory Formosa.fromRandomWords({
    int wordsNumber = 12,
    FormosaTheme formosaTheme = FormosaTheme.bip39,
  }) {
    const int byteMaxValue = 256;
    if (!FormosaService.isValidWordCount(wordsNumber, formosaTheme.data.wordsPerPhrase())) {
      throw ArgumentError(
          'The number of words is not a multiple of the expected size for a given sentence.');
    }
    int phrasesNumber = wordsNumber ~/ formosaTheme.data.wordsPerPhrase();
    int totalBits = phrasesNumber * formosaTheme.data.bitsPerPhrase(); 
    int totalBytes = totalBits ~/ 8;

    Uint8List value = Uint8List(totalBytes);
    Random random = Random.secure();
    for (int i = 0; i < value.length; i++) {
      value[i] = random.nextInt(byteMaxValue);
    }
    
    return Formosa(value, formosaTheme);
  }

  /// Returns the mnemonic phrase corresponding to the current entropy value.
  ///
  /// This method converts the current entropy bytes into a mnemonic string
  /// based on the theme's word list.
  String getMnemonic() => _entropyToMnemonic(value);

  static Formosa generateFormosaFromContatenatedBits(
      List<bool> concatenatedBits, FormosaTheme formosaTheme) {
    final totalBits = concatenatedBits.length;
    final checksumLength = totalBits ~/ 33;

    final entropyBits =
        concatenatedBits.take(totalBits - checksumLength).toList();
    final checksumBits =
        concatenatedBits.skip(totalBits - checksumLength).toList();

    final entropyBytes = EntropyBits.boolBitsToBytes(entropyBits);

    return Formosa(
      entropyBytes,
      formosaTheme,
      checksumBits: ChecksumBits(checksumBits),
    );
  }

  static Formosa generateFormosaFromMnemonic(
      String mnemonic, FormosaTheme formosaTheme) {
    List<String> words = mnemonic.split(' ');
    var wordsDict = formosaTheme.data;

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
        .substring(entropyLengthBits) // Get the checksum part
        .split('')
        .map((bit) => bit == '1')
        .toList();

    ChecksumBits checksumBits = ChecksumBits(bits);

    return Formosa(entropy, formosaTheme, checksumBits: checksumBits);
  }

  String _entropyToMnemonic(Uint8List entropy) {
    final entropyBits =
        entropy.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join();
    final checksumBitsString =
        checksumBits.bits.map((bit) => bit ? '1' : '0').join();
    final concatenatedBits = entropyBits + checksumBitsString;
    return formosaTheme.data.getSentencesFromBits(concatenatedBits).join(' ');
  }
}

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
  final FormosaTheme formosaTheme;
  final ChecksumBits checksumBits;

  late String mnemonic;

  Formosa(super.value, this.formosaTheme, {ChecksumBits? checksumBits})
      : checksumBits = checksumBits ?? ChecksumBits.fromEntropyHash(value) {
    mnemonic =
        _generateMnemonic(EntropyBytes(value), this.checksumBits, formosaTheme);
    validate();
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
    var value = EntropyBits.boolBitsToBytes(concatenatedBits.entropyBits.bits);
    return Formosa(
      value,
      formosaTheme,
      checksumBits: concatenatedBits.checksumBits,
    );
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

    int concatenatedBitsLength =
        FormosaService.getConcatenatedBitsLength(words.length, formosaTheme);

    EntropyBytes entropyBytes =
        FormosaService.getEntropyBytesFromFormosaThemeWords(
            concatenatedBitsLength, formosaTheme, words);
    ChecksumBits checksumBits =
        FormosaService.getChecksumBitsFromFormosaThemeWords(
            concatenatedBitsLength, formosaTheme, words);

    return Formosa(entropyBytes.value, formosaTheme,
        checksumBits: checksumBits);
  }

  factory Formosa.fromRandomWords({
    int wordCount = 12,
    FormosaTheme formosaTheme = FormosaTheme.bip39,
  }) {
    int concatenatedBitsLength =
        FormosaService.getConcatenatedBitsLength(wordCount, formosaTheme);

    int entropyBitsLength =
        ConcatenatedBits.getEntropyBitsLength(concatenatedBitsLength);
    int entropyByteLength = entropyBitsLength ~/ 8;

    EntropyBytes entropyBytes = EntropyBytes.fromRandom(entropyByteLength);

    return Formosa(entropyBytes.value, formosaTheme);
  }

  /// Returns the mnemonic phrase corresponding to the current entropy value.
  ///
  /// This method converts the current entropy bytes into a mnemonic string
  /// based on the theme's word list.
  static String _generateMnemonic(EntropyBytes entropyBytes,
      ChecksumBits checksumBits, FormosaTheme formosaTheme) {
    final entropyBits = entropyBytes.value
        .map((byte) => byte.toRadixString(2).padLeft(8, '0'))
        .join();
    final checksumBitsString =
        checksumBits.bits.map((bit) => bit ? '1' : '0').join();
    final concatenatedBits = entropyBits + checksumBitsString;
    return formosaTheme.data.getSentencesFromBits(concatenatedBits).join(' ');
  }

  void validate() {
    var concatenatedBitsLength = bits.length + checksumBits.length;
    var words = mnemonic.split(' ');
    var wordsPerPhrase = formosaTheme.data.wordsPerPhrase();

    if (!FormosaService.isValidEntropyLength(value)) {
      throw ArgumentError(
          'Formosa entropy length must be a multiple of ${FormosaService.leastMultiple}');
    }
    if (!FormosaService.isValidEntropyChecksum(value, this.checksumBits)) {
      throw ArgumentError('Invalid checksum for the given entropy.');
    }
    if (!FormosaService.wordsExistInTheme(words, formosaTheme)) {
      throw ArgumentError(
          'Some word of the mnemonic phrase is not contained in the given theme.');
    }
    if (!FormosaService.isValidWordLength(words.length, wordsPerPhrase)) {
      throw ArgumentError(
          'The number of words is not a multiple of the expected size for a given sentence.');
    }
    if (!FormosaService.isConcatenatedBitsLengthMultipleOf33(
        concatenatedBitsLength)) {
      throw ArgumentError('The bits count is not multiple of 33');
    }
  }
}

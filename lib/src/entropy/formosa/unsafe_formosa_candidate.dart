import 'package:t3_crypto_objects/crypto_objects.dart';
import 'package:t3_crypto_objects/src/entropy/checksum_bits.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bits.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/concatenated_bits.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_service.dart';

class UnsafeFormosaCandidate extends EntropyBytes {
  final FormosaTheme formosaTheme;
  final ChecksumBits checksumBits;

  late String mnemonic;

  late bool isValidEntropyLength;
  late bool isValidEntropyChecksum;
  late bool isValidWordLength;
  late bool wordsExistInTheme;
  late bool isConcatenatedBitsMultipleOf33;

  UnsafeFormosaCandidate(super.value, this.formosaTheme,
      {ChecksumBits? checksumBits})
      : checksumBits = checksumBits ?? ChecksumBits.fromEntropyHash(value) {
    mnemonic =
        _generateMnemonic(EntropyBytes(value), this.checksumBits, formosaTheme);
    validate();
  }

  factory UnsafeFormosaCandidate.fromConcatenatedBits(
    ConcatenatedBits concatenatedBits, {
    required FormosaTheme formosaTheme,
  }) {
    var value = EntropyBits.boolBitsToBytes(concatenatedBits.entropyBits.bits);
    return UnsafeFormosaCandidate(
      value,
      formosaTheme,
      checksumBits: concatenatedBits.checksumBits,
    );
  }

  factory UnsafeFormosaCandidate.fromMnemonic(String mnemonic,
      {FormosaTheme formosaTheme = FormosaTheme.bip39}) {
    List<String> words = mnemonic.split(' ');

    int concatenatedBitsLength =
        FormosaService.getConcatenatedBitsLength(words.length, formosaTheme);
    EntropyBytes entropyBytes =
        FormosaService.getEntropyBytesFromFormosaThemeWords(
            concatenatedBitsLength, formosaTheme, words);
    ChecksumBits checksumBits =
        FormosaService.getChecksumBitsFromFormosaThemeWords(
            concatenatedBitsLength, formosaTheme, words);
            
    return UnsafeFormosaCandidate(entropyBytes.value, formosaTheme,
        checksumBits: checksumBits);
  }

  factory UnsafeFormosaCandidate.fromRandomWords({
    int wordCount = 12,
    FormosaTheme formosaTheme = FormosaTheme.bip39,
  }) {
    int concatenatedBitsLength =
        FormosaService.getConcatenatedBitsLength(wordCount, formosaTheme);

    int entropyBitsLength =
        ConcatenatedBits.getEntropyBitsLength(concatenatedBitsLength);
    int entropyByteLength = entropyBitsLength ~/ 8;

    EntropyBytes entropyBytes = EntropyBytes.fromRandom(entropyByteLength);

    return UnsafeFormosaCandidate(entropyBytes.value, formosaTheme);
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

  /// Convert to a valid [Formosa] instance if [isValidFormosa] is true.
  Formosa? toFormosa() {
    if (isValidFormosa()) {
      return Formosa(value, formosaTheme);
    }
    return null;
  }

  void validate() {
    var concatenatedBitsLength = bits.length + checksumBits.length;
    var words = mnemonic.split(' ');
    var wordsPerPhrase = formosaTheme.data.wordsPerPhrase();

    isValidEntropyLength = FormosaService.isValidEntropyLength(value);
    isValidEntropyChecksum =
        FormosaService.isValidEntropyChecksum(value, checksumBits);
    isConcatenatedBitsMultipleOf33 =
        FormosaService.isConcatenatedBitsLengthMultipleOf33(
            concatenatedBitsLength);
    isValidWordLength =
        FormosaService.isValidWordLength(words.length, wordsPerPhrase);
    wordsExistInTheme = FormosaService.wordsExistInTheme(words, formosaTheme);
  }

  bool isValidFormosa() {
    return isValidEntropyLength &&
        isValidEntropyChecksum &&
        isValidWordLength &&
        wordsExistInTheme &&
        isConcatenatedBitsMultipleOf33;
  }
}

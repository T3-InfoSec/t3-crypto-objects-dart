import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:t3_crypto_objects/src/entropy/checksum_bits.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bits.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bytes.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/concatenated_bits.dart';
import 'formosa_theme.dart';

class FormosaService {
  static const int leastMultiple = 4;

  /// Validate entropy length.
  static bool isValidEntropyLength(Uint8List value) {
    return value.length % leastMultiple == 0;
  }

  /// Validate checksum.
  static bool isValidEntropyChecksum(Uint8List entropy, ChecksumBits checksum) {
    final hash = sha256.convert(entropy);
    final checksumLengthBits = (entropy.length * 8) ~/ 32;
    final expectedChecksumBits = hash.bytes
        .expand((byte) => EntropyBits.byteToBits(byte))
        .take(checksumLengthBits)
        .toList();
    return ListEquality().equals(checksum.bits, expectedChecksumBits);
  }

  /// Validate if words exist in theme.
  static bool wordsExistInTheme(List<String> words, FormosaTheme theme) {
    return words.every(theme.data.totalWords().contains);
  }

  /// Validate word count against phrase size.
  static bool isValidWordLength(int wordsLength, int phraseSize) {
    return wordsLength % phraseSize == 0;
  }

  /// Validate concatenated bits is multiple of 33
  static bool isConcatenatedBitsLengthMultipleOf33(int concatenatedBitsLength) {
    return concatenatedBitsLength % ConcatenatedBits.bitsPerGroup == 0;
  }

  static EntropyBytes getEntropyBytesFromFormosaThemeWords(
    int concatenatedBitsLength,
    FormosaTheme formosaTheme,
    List<String> words) {

    int entropyBitsLength = ConcatenatedBits.getEntropyBitsLength(concatenatedBitsLength);

    // Get the phrase indexes based on the word list
    List<int> phraseIndexes = formosaTheme.data.getPhraseIndexes(words);

    // Convert phrase indexes to a concatenated bit string
    String concatenationBits = phraseIndexes
        .map((index) => index.toRadixString(2).padLeft(11, '0'))
        .join();

    // Extract the entropy bits from the concatenation (excluding the checksum bits)
    String entropyBits = concatenationBits.substring(0, entropyBitsLength);

    return EntropyBytes(EntropyBits.stringBitsToBytes(entropyBits));
  }

  static ChecksumBits getChecksumBitsFromFormosaThemeWords(
    int concatenatedBitsLength,
    FormosaTheme formosaTheme,
    List<String> words) {

    int entropyBitsLength = ConcatenatedBits.getEntropyBitsLength(concatenatedBitsLength);

    // Get the phrase indexes based on the word list
    List<int> phraseIndexes = formosaTheme.data.getPhraseIndexes(words);

    // Convert phrase indexes to a concatenated bit string
    String concatenationBits = phraseIndexes
        .map((index) => index.toRadixString(2).padLeft(11, '0'))
        .join();

    List<bool> bits = concatenationBits
        .substring(entropyBitsLength) // Get the checksum part
        .split('')
        .map((bit) => bit == '1')
        .toList();

    return ChecksumBits(bits);
  }

  static int getConcatenatedBitsLength(int wordsLength, FormosaTheme formosaTheme) {
    int phrasesCount = wordsLength ~/ formosaTheme.data.wordsPerPhrase();
    return phrasesCount * formosaTheme.data.bitsPerPhrase();
  }
}
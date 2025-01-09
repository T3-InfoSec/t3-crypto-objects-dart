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

    List<String> fillingOrder = formosaTheme.data["FILLING_ORDER"];

    List<int> phraseIndexes = formosaTheme.data.getPhraseIndexes(words);

    print("phraseIndexes: $phraseIndexes");

    String concatenationBits = '';
    int wordIndex = 0;

    for (String category in fillingOrder) {
      int bitLength = formosaTheme.data[category]["BIT_LENGTH"];
      List<String> categoryList = formosaTheme.data[category]["TOTAL_LIST"];

      print("Processing category: $category, bitLength: $bitLength, categoryList: $categoryList");

      for (int i = 0; i < categoryList.length && wordIndex < phraseIndexes.length; i++) {
        String wordBinary = phraseIndexes[wordIndex].toRadixString(2).padLeft(bitLength, '0');
        print("wordIndex: $wordIndex, wordBinary: $wordBinary");

        concatenationBits += wordBinary;
        wordIndex++;
      }
    }

    int entropyBitsLength = ConcatenatedBits.getEntropyBitsLength(concatenatedBitsLength);

    String entropyBits = concatenationBits.substring(0, entropyBitsLength);

    print("Concatenated bits: $concatenationBits");
    print("Entropy bits: $entropyBits");

    return EntropyBytes(EntropyBits.stringBitsToBytes(entropyBits));
  }

  static ChecksumBits getChecksumBitsFromFormosaThemeWords(
      int concatenatedBitsLength,
      FormosaTheme formosaTheme,
      List<String> words) {

    int entropyBitsLength = ConcatenatedBits.getEntropyBitsLength(concatenatedBitsLength);

    List<String> fillingOrder = formosaTheme.data["FILLING_ORDER"];

    List<int> phraseIndexes = formosaTheme.data.getPhraseIndexes(words);

    print("phraseIndexes: $phraseIndexes");

    String concatenationBits = '';
    int wordIndex = 0;

    for (String category in fillingOrder) {
      int bitLength = formosaTheme.data[category]["BIT_LENGTH"];
      List<String> categoryList = formosaTheme.data[category]["TOTAL_LIST"];

      print("Processing category: $category, bitLength: $bitLength, categoryList: $categoryList");

      for (int i = 0; i < categoryList.length && wordIndex < phraseIndexes.length; i++) {
        String wordBinary = phraseIndexes[wordIndex].toRadixString(2).padLeft(bitLength, '0');
        print("wordIndex: $wordIndex, wordBinary: $wordBinary");

        concatenationBits += wordBinary;
        wordIndex++;
      }
    }

    String checksumBitsString = concatenationBits.substring(entropyBitsLength);

    print("Concatenated bits: $concatenationBits");
    print("Checksum bits: $checksumBitsString");

    List<bool> bits = checksumBitsString
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
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

  /// Converts a mnemonic into the original entropy bytes that generated it.
  ///
  /// This method processes a mnemonic list (`words`) based on the structure defined
  /// in the theme (`formosaTheme`). It reconstructs the entropy bits by mapping the
  /// mnemonic words to their indices, arranging them according to the `FILLING_ORDER`,
  /// and converting these indices into binary strings.
  /// For themes with a single category (e.g., `WORDS`), a simplified process is used.
  static EntropyBytes getEntropyBytesFromFormosaThemeWords(
      int concatenatedBitsLength,
      FormosaTheme formosaTheme,
      List<String> words) {
    List<String> fillingOrder = formosaTheme.data["FILLING_ORDER"];
    List<int> phraseIndexes = formosaTheme.data.getPhraseIndexes(words);

    // Handle single-category themes (e.g., bip39)
    if (fillingOrder.length == 1 && fillingOrder[0] == "WORDS") {
      return _getEntropyBytesSingleCategory(
          concatenatedBitsLength, phraseIndexes, formosaTheme);
    }

    // Handle multi-category themes
    return _getEntropyBytesMultiCategory(
        concatenatedBitsLength, phraseIndexes, formosaTheme);
  }

  /// Extracts the checksum bits from a given mnemonic.
  ///
  /// This method processes a mnemonic list (`words`) based on the structure defined
  /// in the theme (`formosaTheme`). It reconstructs the concatenated bits (entropy + checksum)
  /// by mapping the mnemonic words to their indices, arranging them according to the
  /// `FILLING_ORDER`, and converting these indices into binary strings.
  /// For themes with a single category (e.g., `WORDS`), a simplified process is used.
  static ChecksumBits getChecksumBitsFromFormosaThemeWords(
      int concatenatedBitsLength,
      FormosaTheme formosaTheme,
      List<String> words) {
    List<String> fillingOrder = formosaTheme.data["FILLING_ORDER"];
    List<int> phraseIndexes = formosaTheme.data.getPhraseIndexes(words);

    // Handle single-category themes (e.g., bip39)
    if (fillingOrder.length == 1 && fillingOrder[0] == "WORDS") {
      return _getChecksumBitsSingleCategory(
          concatenatedBitsLength, phraseIndexes, formosaTheme);
    }

    // Handle multi-category themes
    return _getChecksumBitsMultiCategory(
        concatenatedBitsLength, phraseIndexes, formosaTheme);
  }

  /// Helper method for single-category themes like bip39.
  static EntropyBytes _getEntropyBytesSingleCategory(int concatenatedBitsLength,
      List<int> phraseIndexes, FormosaTheme formosaTheme) {
    int entropyBitsLength =
        ConcatenatedBits.getEntropyBitsLength(concatenatedBitsLength);

    // Convert phrase indexes to a concatenated bit string
    String concatenationBits = phraseIndexes
        .map((index) => index
            .toRadixString(2)
            .padLeft(formosaTheme.data["WORDS"]["BIT_LENGTH"], '0'))
        .join();

    // Extract the entropy bits
    String entropyBits = concatenationBits.substring(0, entropyBitsLength);

    return EntropyBytes(EntropyBits.stringBitsToBytes(entropyBits));
  }

  /// Helper method for multi-category themes.
  static EntropyBytes _getEntropyBytesMultiCategory(int concatenatedBitsLength,
      List<int> phraseIndexes, FormosaTheme formosaTheme) {
    List<String> fillingOrder = formosaTheme.data["FILLING_ORDER"];
    List<String> naturalOrder = formosaTheme.data["NATURAL_ORDER"];

    Map<String, int> naturalToFillingIndexMap = {
      for (var i = 0; i < naturalOrder.length; i++) naturalOrder[i]: i
    };

    // Reorder phrase indexes based on the filling order
    List<int> reorderedIndexes = List.filled(fillingOrder.length, -1);
    for (int i = 0; i < naturalOrder.length; i++) {
      String naturalCategory = naturalOrder[i];
      int fillingIndex = naturalToFillingIndexMap[naturalCategory]!;
      reorderedIndexes[fillingIndex] = phraseIndexes[i];
    }

    // Build concatenated bits based on the filling order
    String concatenationBits =
        _buildConcatenatedBits(reorderedIndexes, fillingOrder, formosaTheme);

    // Extract the entropy bits
    int entropyBitsLength =
        ConcatenatedBits.getEntropyBitsLength(concatenatedBitsLength);
    String entropyBits = concatenationBits.substring(0, entropyBitsLength);

    return EntropyBytes(EntropyBits.stringBitsToBytes(entropyBits));
  }

  /// Helper method for single-category themes like bip39.
  static ChecksumBits _getChecksumBitsSingleCategory(int concatenatedBitsLength,
      List<int> phraseIndexes, FormosaTheme formosaTheme) {
    int entropyBitsLength =
        ConcatenatedBits.getEntropyBitsLength(concatenatedBitsLength);

    // Convert phrase indexes to a concatenated bit string
    String concatenationBits = phraseIndexes
        .map((index) => index
            .toRadixString(2)
            .padLeft(formosaTheme.data["WORDS"]["BIT_LENGTH"], '0'))
        .join();

    // Extract the checksum bits
    String checksumBitsString = concatenationBits.substring(entropyBitsLength);

    List<bool> checksumBits =
        checksumBitsString.split('').map((bit) => bit == '1').toList();
    return ChecksumBits(checksumBits);
  }

  /// Helper method for multi-category themes.
  static ChecksumBits _getChecksumBitsMultiCategory(int concatenatedBitsLength,
      List<int> phraseIndexes, FormosaTheme formosaTheme) {
    List<String> fillingOrder = formosaTheme.data["FILLING_ORDER"];
    List<String> naturalOrder = formosaTheme.data["NATURAL_ORDER"];

    Map<String, int> naturalToFillingIndexMap = {
      for (var i = 0; i < naturalOrder.length; i++) naturalOrder[i]: i
    };

    // Reorder phrase indexes based on the filling order
    List<int> reorderedIndexes = List.filled(fillingOrder.length, -1);
    for (int i = 0; i < naturalOrder.length; i++) {
      String naturalCategory = naturalOrder[i];
      int fillingIndex = naturalToFillingIndexMap[naturalCategory]!;
      reorderedIndexes[fillingIndex] = phraseIndexes[i];
    }

    // Build concatenated bits based on the filling order
    String concatenationBits =
        _buildConcatenatedBits(reorderedIndexes, fillingOrder, formosaTheme);

    // Extract the checksum bits
    int entropyBitsLength =
        ConcatenatedBits.getEntropyBitsLength(concatenatedBitsLength);
    String checksumBitsString = concatenationBits.substring(entropyBitsLength);

    List<bool> checksumBits =
        checksumBitsString.split('').map((bit) => bit == '1').toList();
    return ChecksumBits(checksumBits);
  }

  /// Builds concatenated bits from reordered indexes and the filling order.
  static String _buildConcatenatedBits(List<int> reorderedIndexes,
      List<String> fillingOrder, FormosaTheme formosaTheme) {
    String concatenationBits = '';
    for (int i = 0; i < fillingOrder.length; i++) {
      String category = fillingOrder[i];
      int bitLength = formosaTheme.data[category]["BIT_LENGTH"];
      int index = reorderedIndexes[i];
      concatenationBits += index.toRadixString(2).padLeft(bitLength, '0');
    }
    return concatenationBits;
  }

  static int getConcatenatedBitsLength(
      int wordsLength, FormosaTheme formosaTheme) {
    int phrasesCount = wordsLength ~/ formosaTheme.data.wordsPerPhrase();
    return phrasesCount * formosaTheme.data.bitsPerPhrase();
  }
}

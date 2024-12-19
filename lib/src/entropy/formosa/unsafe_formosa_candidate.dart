import 'dart:typed_data';

import 'package:t3_crypto_objects/crypto_objects.dart';
import 'package:t3_crypto_objects/src/entropy/checksum_bits.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/concatenated_bits.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_service.dart';

class UnsafeFormosaCandidate {
  late bool isValidFormosa;

  late bool isValidEntropyLength;
  late bool isValidEntropyChecksum;
  late bool isValidWordCount;
  late bool wordsExistInTheme;

  Formosa? _formosa;

  UnsafeFormosaCandidate(Uint8List value, dynamic formosaTheme,
      {ChecksumBits? checksumBits}) {
    try {
      _formosa = Formosa(value, formosaTheme, checksumBits: checksumBits);

      isValidEntropyLength = FormosaService.isValidEntropyLength(value);
      isValidEntropyChecksum =
          FormosaService.isValidEntropyChecksum(value, _formosa!.checksumBits);
      isValidFormosa = isValidEntropyLength && isValidEntropyChecksum;
    } catch (_) {
      isValidEntropyLength = false;
      isValidEntropyChecksum = false;
      isValidFormosa = false;
    }

    // These validations are not applicable in this constructor
    isValidWordCount = true;
    wordsExistInTheme = true;
  }

  factory UnsafeFormosaCandidate.fromMnemonic(String mnemonic,
      {FormosaTheme formosaTheme = FormosaTheme.bip39}) {
    try {
      List<String> words = mnemonic.split(' ');
      int phraseSize = formosaTheme.data.wordsPerPhrase();

      bool isValidWordCount =
          FormosaService.isValidWordCount(words.length, phraseSize);
      bool wordsExistInTheme =
          FormosaService.wordsExistInTheme(words, formosaTheme);

      if (!isValidWordCount || !wordsExistInTheme) {
        return UnsafeFormosaCandidate(Uint8List(0), formosaTheme)
          ..isValidFormosa = false
          ..isValidWordCount = isValidWordCount
          ..wordsExistInTheme = wordsExistInTheme;
      }

      Formosa formosa =
          Formosa.generateFormosaFromMnemonic(mnemonic, formosaTheme);
      bool isValidEntropyChecksum =
          FormosaService.isValidEntropyChecksum(formosa.value, formosa.checksumBits);

      if (!isValidEntropyChecksum) {
        return UnsafeFormosaCandidate(Uint8List(0), formosaTheme)
          ..isValidFormosa = false
          ..isValidEntropyChecksum = false;
      }

      return UnsafeFormosaCandidate(formosa.value, formosa.formosaTheme)
        ..isValidWordCount = isValidWordCount
        ..wordsExistInTheme = wordsExistInTheme
        ..isValidEntropyChecksum = isValidEntropyChecksum;
    } catch (_) {
      return UnsafeFormosaCandidate(Uint8List(0), formosaTheme)
        ..isValidFormosa = false
        ..isValidWordCount = false
        ..wordsExistInTheme = false
        ..isValidEntropyChecksum = false;
    }
  }

  factory UnsafeFormosaCandidate.fromConcatenatedBits(
    ConcatenatedBits concatenatedBits, {
    required FormosaTheme formosaTheme,
  }) {
    Formosa formosa = Formosa.generateFormosaFromContatenatedBits(
        concatenatedBits.bits, formosaTheme);
    return UnsafeFormosaCandidate(formosa.value, formosa.formosaTheme);
  }

  /// Convert to a valid [Formosa] instance if [isValidFormosa] is true.
  Formosa? toFormosa() {
    if (isValidFormosa) {
      return _formosa;
    }
    return null;
  }
}

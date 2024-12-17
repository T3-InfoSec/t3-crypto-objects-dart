import 'dart:typed_data';

import 'package:t3_crypto_objects/crypto_objects.dart';
import 'package:t3_crypto_objects/src/entropy/checksum_bits.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/concatenated_bits.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_service.dart';

class UnsafeFormosaCandidate {
  bool isValidFormosa = true;
  Formosa? _formosa;

  UnsafeFormosaCandidate(Uint8List value, dynamic formosaTheme,
      {ChecksumBits? checksumBits}) {
    try {
      _formosa = Formosa(value, formosaTheme, checksumBits: checksumBits);
      if (!FormosaService.isValidEntropyLength(value)) {
        isValidFormosa = false;
      }
      if (!FormosaService.isValidEntropyChecksum(value, _formosa!.checksumBits)) {
        isValidFormosa = false;
      }
    } catch (_) {
      isValidFormosa = false;
    }
  }

  factory UnsafeFormosaCandidate.fromMnemonic(String mnemonic,
      {FormosaTheme formosaTheme = FormosaTheme.bip39}) {
    try {
      List<String> words = mnemonic.split(' ');
      int phraseSize = formosaTheme.data.wordsPerPhrase();

      if (!FormosaService.isValidWordCount(words.length, phraseSize) ||
          !FormosaService.wordsExistInTheme(words, formosaTheme)) {
        return UnsafeFormosaCandidate(Uint8List(0), formosaTheme)
          ..isValidFormosa = false;
      }

      Formosa formosa =
          Formosa.generateFormosaFromMnemonic(mnemonic, formosaTheme);
      if (!FormosaService.isValidEntropyChecksum(
          formosa.value, formosa.checksumBits)) {
        return UnsafeFormosaCandidate(Uint8List(0), formosaTheme)
          ..isValidFormosa = false;
      }
      return UnsafeFormosaCandidate(formosa.value, formosa.formosaTheme);
    } catch (_) {
      return UnsafeFormosaCandidate(Uint8List(0), formosaTheme)
        ..isValidFormosa = false;
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

  Formosa? toFormosa() {
    if (isValidFormosa) {
      return _formosa;
    }
    return null;
  }
}


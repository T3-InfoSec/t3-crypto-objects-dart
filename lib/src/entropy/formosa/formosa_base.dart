import 'dart:typed_data';

import 'package:crypto/crypto.dart';

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
    return Formosa(entropy, formosaTheme);
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
    var hashObject = sha256.convert(value);

    String entropyBits = value
        .map((e) => e.toRadixString(2).padLeft(8, '0'))
        .join();

    String checksumBits = hashObject.bytes
        .map((e) => e.toRadixString(2).padLeft(8, '0'))
        .join()
        .substring(0, value.length * 8 ~/ 32);

    String dataBits = entropyBits + checksumBits;

    List sentences = formosaTheme.data.getSentencesFromBits(dataBits);
    return sentences.join(' ');
  }

  /// Returns the entropy [value] from a given [mnemonic] and [formosaTheme]
  static Uint8List _toEntropy(String mnemonic, FormosaTheme formosaTheme) {
    List<String> words = mnemonic.split(' ');

    int wordsSize = words.length;
    var wordsDict = formosaTheme.data;
    
    // Check if the number of words is a multiple of phraseSize
    int phraseSize = wordsDict.wordsPerPhrase();
    if (wordsSize % phraseSize != 0) {
      return Uint8List(0); 
    }

    // Calculation of the total length in bits
    int numberPhrases = wordsSize ~/ phraseSize;
    int concatenationLenBits = numberPhrases * wordsDict.bitsPerPhrase();
    int checksumLengthBits = concatenationLenBits ~/ 33;  
    int entropyLengthBits = concatenationLenBits - checksumLengthBits;

    // Get the word indexes
    List<int> phraseIndexes = wordsDict.getPhraseIndexes(words);

    // Construct the concatenation bit sequence
    String concatenationBits = phraseIndexes.map((index) {
      return index.toRadixString(2).padLeft(11, '0'); 
    }).join();

    // Create Uint8List to store the result
    int byteLength = entropyLengthBits ~/ 8;
    Uint8List entropy = Uint8List(byteLength);

    // Fill the Uint8List with the corresponding bits
    for (int i = 0; i < byteLength; i++) {
      int byteStartIndex = i * 8;
      int byteValue = 0;

      // Extract the 8 bits corresponding to this byte
      for (int j = 0; j < 8; j++) {
        if (concatenationBits[byteStartIndex + j] == '1') {
          byteValue |= (1 << (7 - j));
        }
      }

      entropy[i] = byteValue;
    }

    return entropy;
  }
}

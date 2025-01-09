
import 'dart:typed_data';

import 'package:t3_crypto_objects/src/entropy/formosa/formosa.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_theme.dart';

void main() {
  // Formosa formosa = Formosa.fromRandomWords(wordCount: 12, formosaTheme: FormosaTheme.bip39);
  Formosa formosa = Formosa(Uint8List.fromList([99, 254, 92, 48, 241, 246, 120, 110, 41, 135, 122, 79, 49, 43, 171, 68,]), FormosaTheme.bip39);
  print(formosa.bits.length);
  print(formosa.mnemonic);

  Formosa formosaFromMnemonic = Formosa.fromMnemonic(formosa.mnemonic);
  print(formosaFromMnemonic.value);
  print(formosa.mnemonic);
}
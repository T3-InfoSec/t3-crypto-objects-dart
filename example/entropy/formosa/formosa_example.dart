
import 'package:t3_crypto_objects/src/entropy/formosa/formosa.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_theme.dart';

void main() {
  Formosa formosa = Formosa.fromRandomWords(wordCount: 12, formosaTheme: FormosaTheme.bip39);
  print(formosa.value);
  print(formosa.mnemonic);

  Formosa formosaFromMnemonic = Formosa.fromMnemonic(formosa.mnemonic);
  print(formosaFromMnemonic.value);
  print(formosa.mnemonic);
}
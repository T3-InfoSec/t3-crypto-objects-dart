
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_base.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_theme.dart';

void main() {
  Formosa formosa = Formosa.fromRandomWords(wordsNumber: 9, formosaTheme: FormosaTheme.bip39);
  print(formosa.value);

  String mnemonic = formosa.getMnemonic();
  print(mnemonic);

  Formosa formosaFromMnemonic = Formosa.fromMnemonic(mnemonic);
  print(formosaFromMnemonic.value);
}
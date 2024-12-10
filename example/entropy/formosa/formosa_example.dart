
import 'package:t3_crypto_objects/src/entropy/entropy_bytes.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_base.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_theme.dart';

void main() {
  EntropyBytes randomEntropy = EntropyBytes.fromRandom(wordsNumber: 12);

  Formosa formosa = Formosa(randomEntropy.value, FormosaTheme.bip39);
  print(formosa.value);

  String mnemonic = formosa.getMnemonic();
  print(mnemonic);

  Formosa formosaFromMnemonic = Formosa.fromMnemonic(mnemonic);
  print(formosaFromMnemonic.value);
  print("Is valid formosa: ${formosaFromMnemonic.isValid()}");
}

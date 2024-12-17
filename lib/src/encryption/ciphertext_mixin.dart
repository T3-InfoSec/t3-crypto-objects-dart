import 'package:cryptography/cryptography.dart';

// Mixin renaming cipherText to cipherTextPayload
mixin CiphertextMixin on SecretBox {
  List<int> get ciphertextPayload => cipherText;
}
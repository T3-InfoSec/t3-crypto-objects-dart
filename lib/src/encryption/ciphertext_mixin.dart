import 'package:cryptography/cryptography.dart';

// Mixin renaming ciphertext to ciphertextPayload
mixin CiphertextMixin on SecretBox {
  List<int> get ciphertextPayload => cipherText;
}
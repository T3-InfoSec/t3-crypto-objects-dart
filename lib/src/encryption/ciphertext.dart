import 'package:cryptography/cryptography.dart';
import 'package:t3_crypto_objects/src/encryption/ciphertext_mixin.dart';

class Ciphertext extends SecretBox with CiphertextMixin {
  Ciphertext(super.cipherTextPayload, {required super.nonce, required super.mac});
}
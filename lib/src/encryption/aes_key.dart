import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:t3_crypto_objects/src/argon2/argon2_derivation_service.dart';
import 'package:t3_crypto_objects/src/encryption/plaintext.dart';

abstract class AesKey {
  final AesGcm algorithm = AesGcm.with256bits();

  final String key;
  late SecretKey? _secretKey;

  AesKey(this.key) {
    _secretKey = null; // Explicitly set default to null.
  }

  /// Encrypts a [plaintext] list of bytes using AES-GCM [algorithm] and [key].
  ///
  /// Derives the encryption key if it hasn't already been derived, then encrypts the provided data.
  /// The encryption process returns a  `SecretBox`, which includes the ciphertext, a nonce (randomly generated
  /// for each encryption operation), and a MAC (Message Authentication Code) that
  /// protects the integrity and authenticity of the encrypted data.
  Future<SecretBox> encrypt(Plaintext plaintext) async {
    _secretKey ??= await Argon2DerivationService().deriveKey(key);
    return await algorithm.encrypt(
      plaintext.value,
      secretKey: _secretKey!,
      // default randomness unique nonce (aka initialization vector, or "salt") https://pub.dev/documentation/cryptography/latest/cryptography/Cipher/encrypt.html
    );
  }

  /// Decrypts an encrypted byte list [ciphertextPayload] using AES-GCM with the derived [key].
  ///
  /// The [ciphertextPayload] parameter should be a single `List<int>` containing a concatenation
  /// of the nonce, ciphertext, and MAC (Message Authentication Code).
  ///
  /// This method extracts a `SecretBox` object from concatenated [ciphertextPayload],
  /// which the AES-GCM algorithm uses for decryption. Finally, the method returns the [Plaintext] date from byte list.
  Future<Plaintext> decrypt(List<int> ciphertextPayload) async {
    _secretKey ??= await Argon2DerivationService().deriveKey(key);
    SecretBox secretBox = SecretBox.fromConcatenation(ciphertextPayload,
        nonceLength: AesGcm.defaultNonceLength, // 12 Bytes
        macLength: algorithm.macAlgorithm.macLength); // 16 Bytes

    final decryptedBytes = await algorithm.decrypt(
      secretBox,
      secretKey: _secretKey!,
    );

    return Plaintext(Uint8List.fromList(decryptedBytes));
  }
}

import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:t3_crypto_objects/src/argon2/argon2_derivation_service.dart';
import 'package:t3_crypto_objects/src/encryption/critical.dart';

abstract class AesKey {
  static const int nonceLengthBytes = 12;
  static const int macLengthBytes = 16;

  final AesGcm algorithm = AesGcm.with256bits();

  final String key;
  late SecretKey? _secretKey;  

  AesKey(this.key) {
      _secretKey = null; // Explicitly set default to null.
  }

  /// Encrypts a [critical] list of bytes using AES-GCM [algorithm] and [key].
  ///
  /// Derives the encryption key if it hasn't already been derived, then encrypts the provided data.
  /// The encryption process returns a `List<int>` containing the concatenated result
  /// of the `SecretBox`, which includes the ciphertext, a nonce (randomly generated 
  /// for each encryption operation), and a MAC (Message Authentication Code) that 
  /// protects the integrity and authenticity of the encrypted data.
  Future<void> encrypt(Critical critical) async {
    _secretKey ??= await Argon2DerivationService().deriveKey(key);
    critical.secretBox = await algorithm.encrypt(
      critical.value,
      secretKey: _secretKey!,
      // default randomness unique nonce (aka initialization vector, or "salt") https://pub.dev/documentation/cryptography/latest/cryptography/Cipher/encrypt.html
    );
  }

  /// Decrypts an encrypted byte list [cipherText] using AES-GCM with the derived [key].
  ///
  /// The [cipherText] parameter should be a single `List<int>` containing a concatenation
  /// of the nonce, ciphertext, and MAC (Message Authentication Code).
  ///
  /// This method extracts a `SecretBox` object from concatenated [cipherText], 
  /// which the AES-GCM algorithm uses for decryption. Finally, the method returns the [Critical] date from byte list.
  Future<Critical> decrypt(List<int> cipherText) async {
    _secretKey ??= await Argon2DerivationService().deriveKey(key);
    SecretBox secretBox = SecretBox.fromConcatenation(cipherText, nonceLength: nonceLengthBytes, macLength: macLengthBytes);

    final decryptedBytes = await algorithm.decrypt(
      secretBox,
      secretKey: _secretKey!,
    );
    
    return Critical(Uint8List.fromList(decryptedBytes));
  }
}
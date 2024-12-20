import 'dart:math';

import 'package:t3_crypto_objects/src/encryption/aes_key.dart';

/// Eka is an ephemeral encryption key used to encrypt critical data.
/// 
/// Eka acts as a last resort option for retrieving PA0 if the original entry seed is forgotten.
class Eka extends AesKey {
  /// Constructor that automatically generates a new secure hexadecimal [key].
  Eka() : super(_generateHexadecimalKey());

  /// Constructor to create an instance of `Eka` with an existing [key].
  Eka.fromKey(super.key);
  
  /// Static helper to generate the key.
  static String _generateHexadecimalKey({
    int keyLength = 32,
    int digitsChunkSize = 4,
  }) {
    final random = Random.secure();
    final buffer = StringBuffer();

    for (int i = 0; i < keyLength; i++) {
      buffer.write(random.nextInt(16).toRadixString(16));
    }

    return buffer.toString().toUpperCase().replaceAllMapped(
      RegExp('.{$digitsChunkSize}'),
      (match) => "${match.group(0)} ",
    ).trim();
  }
}

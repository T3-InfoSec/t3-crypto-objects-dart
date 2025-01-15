import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:hashlib/hashlib.dart';
import 'package:t3_crypto_objects/crypto_objects.dart';

/// A service for performing hash derivation using the Argon2 algorithm.
///
/// This class provides methods to derive cryptographic hashes with different 
/// memory configurations using the Argon2i variant of the Argon2 algorithm.
class Argon2DerivationService {

  /// Derives a cryptographic hash using Argon2 with high memory usage given an [entropyBytes].
  ///
  /// To achieve a presumably high execution time, this method should be called 
  /// multiple times. It is designed for scenarios where stronger computational 
  /// resistance is required by increasing the cumulative processing time.
  EntropyBytes deriveWithHighMemory(int iterations, EntropyBytes entropyBytes) {
    final Argon2 highMemoryArgon2 = Argon2(
      version: Argon2Version.v13,
      type: Argon2Type.argon2i,
      hashLength: 128, // Bytes
      iterations: 1,
      parallelism: 1,
      memorySizeKB: 1024 * 1024, // 1 GB
      salt: Uint8List(32),
    );
    Uint8List derivedHash = entropyBytes.value;
    for (int step = 0; step < iterations; step++) {
      // if (_isCanceled) {print('Derivation canceled during long hashing.');return;} // TODO: Review unable to cancel flow during long bypass
      derivedHash = highMemoryArgon2.convert(derivedHash).bytes;
    }

    return EntropyBytes(derivedHash);
  }

  /// Derives a cryptographic hash using Argon2 with moderate memory usage given an [entropyBytes].
  ///
  /// This derivation is designed to require presumably little time, depending 
  /// on the specifications of the device running the process. It is suitable 
  /// for scenarios where a quick derivation process is desirable.
  ///
  /// This method allows you to specify the number of [iterations], which determines 
  /// the computational cost and security of the hash derivation process. Additionally, 
  /// you can provide a custom [salt] to add randomness to the hashing. If no salt is 
  /// provided, a default value of `Uint8List(32)` will be used.
  EntropyBytes deriveWithModerateMemory(int iterations, EntropyBytes entropyBytes, {Uint8List? salt}) {
    final Argon2 moderateMemoryArgon2 = Argon2(
      version: Argon2Version.v13,
      type: Argon2Type.argon2i,
      hashLength: 128, // Bytes
      iterations: iterations,
      parallelism: iterations,
      memorySizeKB: 10 * 1024, // 10 MB
      salt: salt ?? Uint8List(32),
    );
    return EntropyBytes(moderateMemoryArgon2.convert(entropyBytes.value).bytes);
  }

  /// Derives a cryptographic hash using Argon2 with low memory usage given an [inputHash].
  ///
  /// This derivation is designed to require presumably little time, depending 
  /// on the specifications of the device running the process. It is suitable 
  /// for scenarios where a quick derivation process is desirable.
  EntropyBytes deriveWithLowMemory(EntropyBytes entropyBytes) {
    final Argon2 lowMemoryArgon2 = Argon2(
      version: Argon2Version.v13,
      type: Argon2Type.argon2i,
      hashLength: 16, // Bytes
      iterations: 1,
      parallelism: 1,
      memorySizeKB: 1024, // 1 MB
      salt: Uint8List(32),
    );
    return EntropyBytes(lowMemoryArgon2.convert(entropyBytes.value).bytes);
  }

  /// Derives a 256-bit AES encryption key from the provided [key] string using the Argon2id algorithm.
  ///
  /// This method is designed to generate a secure key suitable for AES-GCM encryption by applying
  /// the Argon2id key derivation function on the input [key].
  Future<SecretKey> deriveKey(String key) async {
    final argon2 = Argon2id(
      parallelism: 4,
      iterations: 3,
      memory: 65536, // KB (64 MB),
      hashLength: 32, // 256 bits
    );

    final SecretKey secretKey = await argon2.deriveKey(
      secretKey: SecretKey(utf8.encode(key)),
      nonce: [], // TODO: Review fixed nonce
    );

    return secretKey;
  }
}

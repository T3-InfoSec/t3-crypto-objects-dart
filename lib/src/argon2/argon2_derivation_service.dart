import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:hashlib/hashlib.dart';

/// A service for performing hash derivation using the Argon2 algorithm.
///
/// This class provides methods to derive cryptographic hashes with different 
/// memory configurations using the Argon2i variant of the Argon2 algorithm.
class Argon2DerivationService {

  final Argon2 highMemoryArgon2 = Argon2(
      version: Argon2Version.v13,
      type: Argon2Type.argon2i,
      hashLength: 128, // Bytes
      iterations: 1,
      parallelism: 1,
      memorySizeKB: 1024 * 1024, // 1 GB
      salt: Uint8List(32),
    );
  
  final Argon2 moderateMemoryArgon2 = Argon2(
      version: Argon2Version.v13,
      type: Argon2Type.argon2i,
      hashLength: 128, // Bytes
      iterations: 1,
      parallelism: 1,
      memorySizeKB: 10 * 1024, // 10 MB
      salt: Uint8List(32),
    );

  /// Derives a cryptographic hash using Argon2 with high memory usage given an [inputHash].
  ///
  /// To achieve a presumably high execution time, this method should be called 
  /// multiple times. It is designed for scenarios where stronger computational 
  /// resistance is required by increasing the cumulative processing time.
  Uint8List deriveWithHighMemory(int iterations, Uint8List inputHash) {
    Uint8List derivedHash = inputHash;
    if (iterations > 0) {
      for (int step = 0; step < iterations; step++) {
        // if (_isCanceled) {print('Derivation canceled during long hashing.');return;} // TODO: Review unable to cancel flow during long bypass
        derivedHash = highMemoryArgon2.convert(derivedHash).bytes;
      }
    }
    return derivedHash;
  }

  /// Derives a cryptographic hash using Argon2 with moderate memory usage given an [inputHash].
  ///
  /// This derivation is designed to require presumably little time, depending 
  /// on the specifications of the device running the process. It is suitable 
  /// for scenarios where a quick derivation process is desirable.
  Uint8List deriveWithModerateMemory(Uint8List inputHash) {
    return moderateMemoryArgon2.convert(inputHash).bytes;
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

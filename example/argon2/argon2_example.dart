import 'dart:typed_data';
import 'dart:convert';

import 'package:t3_crypto_objects/src/argon2/argon2_derivation_service.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bytes.dart';

void main() async {
  final derivationService = Argon2DerivationService();

  final String input = "my_secure_password";
  final EntropyBytes entropyBytes = EntropyBytes(Uint8List.fromList(utf8.encode(input)));

  print("Deriving with high memory...");
  final highMemoryHash = derivationService.deriveWithHighMemory(2, entropyBytes);
  print("Derived hash: ${base64Encode(highMemoryHash.value)}");

  print("Deriving with moderate memory...");
  final moderateMemoryHash = derivationService.deriveWithModerateMemory(1, entropyBytes);
  print("Derived hash: ${base64Encode(moderateMemoryHash.value)}");

  print("Deriving key AES...");
  final derivedKey = await derivationService.deriveKey("my_secure_key");
  print("Derived key: ${base64Encode(await derivedKey.extractBytes())}");
}
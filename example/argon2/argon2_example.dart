import 'dart:typed_data';
import 'dart:convert';

import 'package:t3_crypto_objects/src/argon2/argon2_derivation_service.dart';

void main() async {
  final derivationService = Argon2DerivationService();

  final String input = "my_secure_password";
  final Uint8List inputHash = Uint8List.fromList(utf8.encode(input));

  print("Deriving with high memory...");
  final highMemoryHash = derivationService.deriveWithHighMemory(2, inputHash);
  print("Derived hash: ${base64Encode(highMemoryHash)}");

  print("Deriving with moderate memory...");
  final moderateMemoryHash = derivationService.deriveWithModerateMemory(inputHash);
  print("Derived hash: ${base64Encode(moderateMemoryHash)}");

  print("Deriving key AES...");
  final derivedKey = await derivationService.deriveKey("my_secure_key");
  print("Derived key: ${base64Encode(await derivedKey.extractBytes())}");
}
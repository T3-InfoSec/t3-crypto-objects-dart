import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:t3_crypto_objects/crypto_objects.dart';
import 'package:t3_crypto_objects/src/encryption/plaintext.dart';

void main() async {
  final eka = Eka();

  final plaintext = Plaintext(Uint8List.fromList([1, 2, 3, 4, 5]));
  print("Plaintext: ${plaintext.value}");

  SecretBox secretBox = await eka.encrypt(plaintext);

  print("Ciphertext: ${secretBox.cipherText}");

  final decryptedData = await eka.decrypt(secretBox.concatenation());
  print("Plain text: ${decryptedData.value}");
}

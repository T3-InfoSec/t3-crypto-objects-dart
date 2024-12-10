import 'dart:typed_data';

import 'package:t3_crypto_objects/crypto_objects.dart';
import 'package:t3_crypto_objects/src/encryption/critical.dart';

void main() async {
  final eka = Eka();

  final dataToEncrypt = Critical(Uint8List.fromList([1, 2, 3, 4, 5]));

  print("Plain text: ${dataToEncrypt.value}");

  await eka.encrypt(dataToEncrypt);

  final cipherText = dataToEncrypt.secretBox.concatenation();
  print("Cipher text (SecretBox): $cipherText");

  final decryptedData = await eka.decrypt(cipherText);
  print("Plain text: ${decryptedData.value}");
}

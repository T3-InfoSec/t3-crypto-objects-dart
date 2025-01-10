import 'dart:typed_data';

import 'package:t3_crypto_objects/src/encryption/ciphertext.dart';
import 'package:t3_crypto_objects/src/encryption/eka.dart';
import 'package:t3_crypto_objects/src/encryption/plaintext.dart';

void main() async {
  final eka = Eka();

  final plaintext = Plaintext(Uint8List.fromList([1, 2, 3, 4, 5]));
  print("Plaintext: ${plaintext.value}");

  Ciphertext ciphertext = await eka.encrypt(plaintext);

  print("Ciphertext: ${ciphertext.ciphertextPayload}");

  final decryptedData = await eka.decrypt(ciphertext.concatenation());
  print("Plain text: ${decryptedData.value}");
}

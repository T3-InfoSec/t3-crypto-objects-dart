import 'dart:typed_data';

import 'package:t3_crypto_objects/crypto_objects.dart';


void main() async {
  final eka = Eka();

  final plaintext = Plaintext(Uint8List.fromList([1, 2, 3, 4, 5]));
  print("Plaintext: ${plaintext.value}");

  Ciphertext ciphertext = await eka.encrypt(plaintext);

  print("Ciphertext: ${ciphertext.ciphertextPayload}");

  final decryptedData = await eka.decrypt(ciphertext.concatenation());
  print("Plain text: ${decryptedData.value}");

  final tlp = Tlp();
  print("Tlp key: ${tlp.key}");
  Ciphertext tlpCiphertext = await tlp.encrypt(plaintext);
  print("Tlp Ciphertext: ${tlpCiphertext.ciphertextPayload}");

  final tlpDecryptedData = await tlp.decrypt(tlpCiphertext.concatenation());
  print("Tlp Plain text: ${tlpDecryptedData.value}");
  
}

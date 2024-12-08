import 'package:t3_crypto_objects/crypto_objects.dart';

abstract class FormosaEntropy {
  Entropy get entropy;
  set entropy(Entropy newEntropy);
  String get mnemonic;
}
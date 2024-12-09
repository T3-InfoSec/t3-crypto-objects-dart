
import 'package:cryptography/cryptography.dart';

import '../entropy/byte_entropy.dart';

class Critical extends ByteEntropy {

  late SecretBox secretBox;

  Critical(super.value);

}
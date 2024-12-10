
import 'package:cryptography/cryptography.dart';

import '../entropy/entropy_bytes.dart';

class Critical extends EntropyBytes {

  late SecretBox secretBox;

  Critical(super.value);

}
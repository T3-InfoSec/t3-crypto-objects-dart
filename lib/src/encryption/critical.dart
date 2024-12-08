
import 'package:cryptography/cryptography.dart';

import '../entropy/entropy.dart';

class Critical extends Entropy {

  late SecretBox secretBox;

  Critical(super.value);

}
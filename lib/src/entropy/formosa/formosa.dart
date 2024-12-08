import 'package:t3_crypto_objects/crypto_objects.dart';

abstract class FormosaEntropy extends Entropy {
  dynamic formosaTheme;

  /// Creates an instance of Formosa using the given formosaTheme and initial entropy.
  FormosaEntropy(super.value, this.formosaTheme);

  factory FormosaEntropy.fromMnemonic(String mnemonic, dynamic formosaTheme) {
    throw UnimplementedError('fromMnemonic must be implemented in subclasses');
  }
  
  /// Return derived mnemonic based on the entropy [value]
  /// and the words defined by the specified FormosaTheme.
  String getMnemonic();
}
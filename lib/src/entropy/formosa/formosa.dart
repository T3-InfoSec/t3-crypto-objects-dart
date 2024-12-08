import 'dart:typed_data';

import 'package:t3_crypto_objects/crypto_objects.dart';

abstract class FormosaEntropy extends Entropy {
  dynamic formosaTheme;
  late String mnemonic;

  /// Creates an instance of Formosa using the given formosaTheme and initial entropy.
  ///
  /// The [mnemonic] is automatically derived based on the initial entropy [value] provided
  /// and the words defined by the specified FormosaTheme.
  FormosaEntropy(super.value, this.formosaTheme) {
    mnemonic = _toMnemonic(value);
  }

  factory FormosaEntropy.fromMnemonic(String mnemonic, dynamic formosaTheme) {
    throw UnimplementedError('fromMnemonic must be implemented in subclasses');
  }
  
  String _toMnemonic(Uint8List entropy);
}
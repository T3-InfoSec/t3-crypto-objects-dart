import 'dart:typed_data';

import 'package:t3_crypto_objects/src/entropy/byte_entropy.dart';


abstract class FormosaEntropy extends ByteEntropy {
  static final leastMultiple = 4;
  dynamic formosaTheme;

  /// Creates an instance of Formosa using the given formosaTheme and initial entropy.
  FormosaEntropy(Uint8List value, this.formosaTheme) : super(value) {
    if (value.length % leastMultiple != 0) {
      throw ArgumentError('Formosa entropy length must be multiple of $leastMultiple');
    }
  }

  factory FormosaEntropy.fromMnemonic(String mnemonic, dynamic formosaTheme) {
    throw UnimplementedError('fromMnemonic must be implemented in subclasses');
  }
  
  /// Return derived mnemonic based on the entropy [value]
  /// and the words defined by the specified FormosaTheme.
  String getMnemonic();
}
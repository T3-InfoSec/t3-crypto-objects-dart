import 'dart:typed_data';

import 'package:t3_crypto_objects/src/argon2/argon2_derivation_service.dart';

import 'entropy_bytes.dart';
import 'sa1.dart';

/// Represents the second derived state (`Sa2`) in the cryptographic protocol derivation process.
/// 
/// `Sa2` is derived from `Sa1` with a long hash derivation.
class Sa2 extends EntropyBytes {
  static final int bytesSize = 128;

  /// Constructs an instance of [Sa2] with an initial entropy [value]
  /// of [bytesSize] bytes.
  /// 
  /// The initial entropy is initialized as an empty byte array of the specified size.
  Sa2() : super(Uint8List(bytesSize));

  // Deprecated
  // void from(int iterations, Sa1 sa1) {
  //   print('Deriving SA2 form SA1');
  //   value = Argon2DerivationService().highMemoryIterativeDerivation(iterations, sa1).value;
  // }

  /// Derives the entropy [value] based on the value from [sa1].
  /// Automatically updates [sa1]'s intermediates.
  void from(int iterations, Sa1 sa1) {
    print('Deriving SA2 from SA1 with intermediate states');
    value = sa1.deriveWithIntermediateStates(iterations);
  }

  @override
  String toString() => 'Sa2(seed: $value';
}
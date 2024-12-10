import 'dart:typed_data';

import 'package:t3_crypto_objects/src/argon2/argon2_derivation_service.dart';

import 'entropy_bytes.dart';
import 'sa1.dart';

/// Represents the third derived state (`Sa3`) in the cryptographic protocol derivation process.
/// 
/// `Sa3` is derived from a combination of the initial entropy state (`Sa0`)
/// and the second derived state (`Sa2`), and it encapsulates
/// a fixed-size entropy [value] used in further derivation steps.
class Sa2 extends EntropyBytes {
  static final int bytesSize = 128;

  /// Constructs an instance of [Sa2] with an initial entropy [value]
  /// of [bytesSize] bytes.
  /// 
  /// The initial entropy is initialized as an empty byte array of the specified size.
  Sa2() : super(Uint8List(bytesSize));

  /// Derives the entropy [value] based on the value from [sa1].
  /// 
  /// This method updates the [value] of the current instance applying
  /// a derivation process [iterations] times.
  void from(int iterations, Sa1 sa1) {
    print('Deriving SA2 form SA1');
    value = Argon2DerivationService().deriveWithHighMemory(iterations, sa1.value);
  }

  @override
  String toString() => 'Sa2(seed: ${String.fromCharCodes(value)}';
}
import 'dart:typed_data';

import 'package:t3_crypto_objects/crypto_objects.dart';

/// Represents the third derived state [Sa3] in the protocol derivation process.
/// 
/// It is derived from a combination of the initial entropy state [Sa0]
/// and the second derived state [Sa2]
class Sa3 extends Entropy {
  static final int bytesSize = 128;

  /// Constructs an instance of [Sa3] with an initial entropy [value]
  /// of [bytesSize] bytes.
  /// 
  /// The initial entropy is initialized as an empty byte array of the specified size.
  Sa3() : super(Uint8List(bytesSize));

  /// Derives the entropy [value] based on the values from [sa0] and [sa2].
  /// 
  /// This method updates the [value] of the current instance by combining
  /// the seed from [sa0] and the entropy value from [sa2], then applying
  /// a derivation process.
  void from(Sa0 sa0, Sa2 sa2) {
    print('Deriving SA3 from SA2 and SA0');
    value = Argon2DerivationService()
        .deriveWithModerateMemory(Uint8List.fromList(sa0.formosa.entropy.value + sa2.value));
  }

  @override
  String toString() => 'Sa3(seed: ${String.fromCharCodes(value)}';
}

import 'dart:typed_data';

import 'package:t3_crypto_objects/src/argon2/argon2_derivation_service.dart';
import 'package:t3_crypto_objects/src/entropy/sa0.dart';
import 'package:t3_crypto_objects/src/entropy/sa1i.dart';

import 'entropy_bytes.dart';


/// Represents the first derived state [Sa1] in the protocol derivation process.
/// 
/// It is derived from the initial entropy state [Sa0]
class Sa1 extends EntropyBytes {
  static final int bytesSize = 128;

  /// List of intermediate states Sa1i produced during the derivation process.
  final List<Sa1i> intermediates = [];

  /// Constructs an instance of [Sa1] with an initial entropy [value]
  /// of [bytesSize] bytes.
  /// 
  /// The initial entropy is initialized as an empty byte array of the specified size.
  Sa1() : super(Uint8List(bytesSize));

  /// Derives the entropy [value] from the given initial entropy [sa0].
  /// 
  /// This method updates the [value] of the current instance by applying
  /// a derivation process using the seed from [sa0].
  void from(Sa0 sa0) {
    print('Deriving SA1 from SA0');
    value = Argon2DerivationService().moderateMemoryDerivation(sa0.formosa).value;
  }

  /// Performs a derivation process, generating intermediate states.
  /// Updates the list of intermediates and returns the final state.
  Uint8List deriveWithIntermediateStates(int iterations) {
    Uint8List currentHash = value;
    intermediates.clear(); // Clear previous states.

    for (int step = 0; step < iterations; step++) {
      currentHash = Argon2DerivationService().highMemoryDerivation(EntropyBytes(currentHash)).value;
      intermediates.add(Sa1i(currentHash, step + 1));
    }

    return currentHash;
  }

  @override
  String toString() => 'Sa1(seed: $value';
}

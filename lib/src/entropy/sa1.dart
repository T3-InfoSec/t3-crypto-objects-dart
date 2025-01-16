import 'dart:async';
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

  /// Intermediate state [Sa1i] produced during the derivation process.
  late Sa1i intermediateState;

  /// StreamController to emit updates when intermediateState changes.
  final StreamController<Sa1i> _intermediateStateController = StreamController<Sa1i>.broadcast();

  /// Constructs an instance of [Sa1] with an initial entropy [value]
  /// of [bytesSize] bytes.
  /// 
  /// The initial entropy is initialized as an empty byte array of the specified size.
  Sa1() : super(Uint8List(bytesSize));

  /// Exposes the Stream for subscribing to intermediate state changes.
  Stream<Sa1i> get intermediateStateStream => _intermediateStateController.stream;

  /// Derives the entropy [value] from the given initial entropy [sa0].
  /// 
  /// This method updates the [value] of the current instance by applying
  /// a derivation process using the seed from [sa0].
  void from(Sa0 sa0) {
    print('Deriving SA1 from SA0');
    value = Argon2DerivationService().moderateMemoryDerivation(sa0.formosa).value;
    intermediateState = Sa1i(value, 0, 0);
  }

  /// Performs a derivation process, generating intermediate states.
  /// Updates the list of intermediates and returns the final state.
  Uint8List deriveWithIntermediateStates(int iterations) {
    Uint8List currentHash = value;

    for (int step = 1; step <= iterations; step++) {
      currentHash = Argon2DerivationService().highMemoryDerivation(EntropyBytes(currentHash)).value;
      intermediateState = Sa1i(currentHash, step, iterations);
      print("Intermediate state $step: ${intermediateState.value}");
    }

    return currentHash;
  }

  /// Resumes the derivation process from a given intermediate state.
  /// This method updates the [value] and continues the derivation.
  Uint8List resumeDerivation() {
    Uint8List currentHash = intermediateState.value;
    int currentIteration = intermediateState.currentIteration + 1;
    int totalIterations = intermediateState.totalIterations;

    for (int step = currentIteration; step <= totalIterations; step++) {
      currentHash = Argon2DerivationService().highMemoryDerivation(EntropyBytes(currentHash)).value;
      intermediateState = Sa1i(currentHash, step, totalIterations);
    }

    return currentHash;
  }

  @override
  String toString() => 'Sa1(seed: $value)';
}

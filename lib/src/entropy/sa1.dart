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

  /// Intermediate state [Sa1i] list produced during the derivation process.
  late List<Sa1i> intermediateStates = [];

  /// StreamController to emit updates when intermediateState changes.
  final StreamController<List<Sa1i>> _intermediateStatesController = StreamController<List<Sa1i>>.broadcast();

  /// Constructs an instance of [Sa1] with an initial entropy [value]
  /// of [bytesSize] bytes.
  /// 
  /// The initial entropy is initialized as an empty byte array of the specified size.
  Sa1() : super(Uint8List(bytesSize));

  /// Exposes the Stream for subscribing to intermediate state changes.
  Stream<List<Sa1i>> get intermediateStatesStream => _intermediateStatesController.stream;

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
  Future<Uint8List> deriveWithIntermediateStates(int iterations) async {
    Uint8List currentHash = value;

    for (int step = 1; step <= iterations; step++) {
      currentHash = Argon2DerivationService()
          .highMemoryDerivation(EntropyBytes(currentHash))
          .value;

      intermediateStates.add(Sa1i(currentHash, step, iterations));
      _intermediateStatesController.add(List.unmodifiable(intermediateStates));

      // Briefly cede control to the main thread
      await Future.delayed(Duration.zero);
    }

    return currentHash;
  }

  /// Resumes the derivation process from a given intermediate state.
  /// This method updates the [value] and continues the derivation.
  Future<Uint8List> resumeDerivation() async {
    Uint8List currentHash = intermediateStates.last.value;
    int currentIteration = intermediateStates.last.currentIteration + 1;
    int totalIterations = intermediateStates.last.totalIterations;

    for (int step = currentIteration; step <= totalIterations; step++) {
      currentHash = Argon2DerivationService().highMemoryDerivation(EntropyBytes(currentHash)).value;
      intermediateStates.add(Sa1i(currentHash, step, totalIterations));
      _intermediateStatesController.add(List.unmodifiable(intermediateStates));

      // Briefly cede control to the main thread
      await Future.delayed(Duration.zero);
    }

    return currentHash;
  }

  /// Resumes the derivation process from a given intermediate state.
  /// This method updates the [value] and continues the derivation.
  bool checkDerivationStep(Sa1i intermediateState) {
    return intermediateState.value == intermediateStates[intermediateState.currentIteration].value;
  }

  /// Closes the StreamController when it's no longer needed.
  void dispose() {
    _intermediateStatesController.close();
  }

  @override
  String toString() => 'Sa1(seed: $value)';
}

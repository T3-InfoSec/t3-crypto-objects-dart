import 'entropy_bytes.dart';

/// Represents an intermediate state of the derivation process of `Sa1`.
/// 
/// This allows saving and resuming the derivation process at any iteration.
class Sa1i extends EntropyBytes {
  final int currentIteration;
  final int totalIterations;

  /// Constructs an instance of [Sa1i] with a specific [value] and [iteration].
  Sa1i(super.value, this.currentIteration, this.totalIterations);

  @override
  String toString() => 'Sa1i(value: $value, currentIteration: $currentIteration, totalIterations: $totalIterations)';
}

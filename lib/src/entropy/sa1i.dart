import 'entropy_bytes.dart';

/// Represents an intermediate state of the derivation process of `Sa1`.
/// 
/// This allows saving and resuming the derivation process at any iteration.
class Sa1i extends EntropyBytes {
  final int iteration;

  /// Constructs an instance of [Sa1i] with a specific [value] and [iteration].
  Sa1i(super.value, this.iteration);

  @override
  String toString() => 'Sa1i(iteration: $iteration, value: $value)';
}

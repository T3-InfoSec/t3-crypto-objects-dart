import 'dart:typed_data';

import 'package:t3_crypto_objects/src/encryption/plaintext.dart';


/// Represents a node in the derivation process of the protocol,
/// encapsulating critical value entropy and protocol metadata.
/// 
/// A [Node] extends [Plaintext], providing both the raw entropy [value]
/// and metadata such as [depth] and [arity] that describe its position
/// and configuration within the derivation hierarchy.
class Node extends Plaintext {
  final int? depth;
  final int? arity;
  
  /// Constructs a [Node] instance with an initial entropy [value],
  /// along with its [depth] and [arity].
  /// 
  /// The [value] represents the raw entropy of the node, while [depth]
  /// indicates its level in the derivation hierarchy, and [arity]
  /// specifies the branching factor used for its derivation.
  Node(super.value, {this.depth, this.arity});

  /// Creates a new [Node] by deriving it from a [previousNode]
  /// 
  /// The new node inherits its [arity] from the [previousNode] and
  /// its [depth] is incremented by one. The entropy [value] is
  /// constructed by concatenating the [value] of the [previousNode]
  /// with [shuffleArityIndex].
  Node.fromNode(Node previousNode, List<int> shuffleArityIndex):
        depth = previousNode.depth != null ? previousNode.depth! + 1 : previousNode.depth,
        arity = previousNode.arity,
        super(Uint8List.fromList(previousNode.value + shuffleArityIndex));

  @override
  String toString() => 'Node(currentHash: ${String.fromCharCodes(value)}';
}

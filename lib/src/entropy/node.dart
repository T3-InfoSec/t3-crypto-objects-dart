import 'dart:typed_data';

import 'package:t3_crypto_objects/src/encryption/plaintext.dart';


/// Represents a node in the derivation process of the protocol,
/// encapsulating critical value entropy and protocol metadata.
/// 
/// A [Node] extends [Plaintext], providing both the raw entropy [value]
/// and metadata such as [nodeDepth] and [arity] that describe its position
/// and configuration within the derivation hierarchy.
class Node extends Plaintext {
  final int? nodeDepth;
  
  /// Constructs a [Node] instance with an initial entropy [value],
  /// along with its [nodeDepth] and [arity].
  /// 
  /// The [value] represents the raw entropy of the node, while [nodeDepth]
  /// indicates its level in the derivation hierarchy.
  Node(super.value, {this.nodeDepth});

  /// Creates a new [Node] by deriving it from a [previousNode]
  /// 
  /// the [nodeDepth] is [previousNode] node depth incremented by one. The entropy [value] is
  /// constructed by concatenating the [value] of the [previousNode]
  /// with [shuffleArityIndex].
  Node.fromNode(Node previousNode, List<int> shuffleArityIndex):
        nodeDepth = previousNode.nodeDepth != null ? previousNode.nodeDepth! + 1 : previousNode.nodeDepth,
        super(Uint8List.fromList(previousNode.value + shuffleArityIndex));

  @override
  String toString() => 'Node(currentHash: ${String.fromCharCodes(value)}';
}

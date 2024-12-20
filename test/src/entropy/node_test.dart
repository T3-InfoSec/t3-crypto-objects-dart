import 'package:t3_crypto_objects/src/entropy/node.dart';
import 'package:test/test.dart';
import 'dart:typed_data';

void main() {
  group('Node', () {
    test('Node initializes correctly with value, depth, and arity', () {
      final value = Uint8List.fromList([1, 2, 3, 4]);
      final node = Node(value, nodeDepth: 1);

      expect(node.value, equals(value));
      expect(node.nodeDepth, equals(1));
    });

    test('Node initializes correctly without depth and arity', () {
      final value = Uint8List.fromList([5, 6, 7, 8]);
      final node = Node(value);

      expect(node.value, equals(value));
      expect(node.nodeDepth, isNull);
    });

    test('Node.fromNode correctly creates a new node from previous node', () {
      final previousNode = Node(Uint8List.fromList([1, 2]), nodeDepth: 1);
      final shuffleArityIndex = [3, 4];
      final newNode = Node.fromNode(previousNode, shuffleArityIndex);

      expect(newNode.nodeDepth, equals(2));
      expect(newNode.value, equals(Uint8List.fromList([1, 2, 3, 4])));
    });

    test('Node.toString returns correct format', () {
      var value = Uint8List.fromList([1, 2, 3, 4]);
      final node = Node(value);
      expect(node.toString(), equals('Node(currentHash: ${String.fromCharCodes(value)}'));
    });
  });
}

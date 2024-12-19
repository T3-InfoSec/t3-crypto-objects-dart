import 'package:t3_crypto_objects/src/entropy/node.dart';
import 'package:test/test.dart';
import 'dart:typed_data';

void main() {
  group('Node', () {
    test('Node initializes correctly with value, depth, and arity', () {
      final value = Uint8List.fromList([1, 2, 3, 4]);
      final node = Node(value, depth: 1, arity: 2);

      expect(node.value, equals(value));
      expect(node.depth, equals(1));
      expect(node.arity, equals(2));
    });

    test('Node initializes correctly without depth and arity', () {
      final value = Uint8List.fromList([5, 6, 7, 8]);
      final node = Node(value);

      expect(node.value, equals(value));
      expect(node.depth, isNull);
      expect(node.arity, isNull);
    });

    test('Node.fromNode correctly creates a new node from previous node', () {
      final previousNode = Node(Uint8List.fromList([1, 2]), depth: 1, arity: 2);
      final shuffleArityIndex = [3, 4];
      final newNode = Node.fromNode(previousNode, shuffleArityIndex);

      expect(newNode.depth, equals(2));
      expect(newNode.arity, equals(2));
      expect(newNode.value, equals(Uint8List.fromList([1, 2, 3, 4])));
    });

    test('Node.toString returns correct format', () {
      var value = Uint8List.fromList([1, 2, 3, 4]);
      final node = Node(value);
      expect(node.toString(), equals('Node(currentHash: ${String.fromCharCodes(value)}'));
    });
  });
}

import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_theme.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/unsafe_formosa_candidate.dart';

void main() {
  group('UnsafeFormosaCandidate', () {
    final theme = FormosaTheme.bip39;

    test('UnsafeFormosaCandidate validates correct entropy', () {
      final validEntropy = Uint8List(16); // 16 bytes = 128 bits
      final candidate = UnsafeFormosaCandidate(validEntropy, theme);

      expect(candidate.isValidFormosa, isTrue,
          reason: 'Valid entropy should produce a valid UnsafeFormosaCandidate.');
    });

    test('UnsafeFormosaCandidate marks invalid entropy as invalid', () {
      final invalidEntropy = Uint8List.fromList([1, 2, 3]); // Invalid length
      final candidate = UnsafeFormosaCandidate(invalidEntropy, theme);

      expect(candidate.isValidFormosa, isFalse,
          reason: 'Invalid entropy should mark UnsafeFormosaCandidate as invalid.');
    });

    test('UnsafeFormosaCandidate converts to valid Formosa', () {
      final validEntropy = Uint8List(16); // Valid 128-bit entropy
      final candidate = UnsafeFormosaCandidate(validEntropy, theme);

      final formosa = candidate.toFormosa();
      expect(formosa, isNotNull, reason: 'Valid candidate should convert to Formosa.');
      expect(formosa!.value, equals(validEntropy), reason: 'The Formosa should have the same entropy value.');
    });

    test('UnsafeFormosaCandidate does not convert invalid entropy', () {
      final invalidEntropy = Uint8List.fromList([1, 2, 3]); // Invalid length
      final candidate = UnsafeFormosaCandidate(invalidEntropy, theme);

      final formosa = candidate.toFormosa();
      expect(formosa, isNull,
          reason: 'Invalid candidate should not convert to Formosa.');
    });

    test('UnsafeFormosaCandidate fromMnemonic generates valid candidate', () {
      final mnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
      final candidate = UnsafeFormosaCandidate.fromMnemonic(mnemonic, formosaTheme: theme);

      expect(candidate.isValidFormosa, isTrue,
          reason: 'Valid mnemonic should produce a valid UnsafeFormosaCandidate.');
    });

    test('UnsafeFormosaCandidate fromMnemonic marks invalid mnemonic as invalid', () {
      final mnemonic = 'invalid mnemonic words that are not in the theme';
      final candidate = UnsafeFormosaCandidate.fromMnemonic(mnemonic, formosaTheme: theme);

      expect(candidate.isValidFormosa, isFalse,
          reason: 'Invalid mnemonic should mark UnsafeFormosaCandidate as invalid.');
    });
  });
}

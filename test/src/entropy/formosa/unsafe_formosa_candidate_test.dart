import 'dart:typed_data';
import 'package:t3_crypto_objects/src/entropy/checksum_bits.dart';
import 'package:test/test.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_theme.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/unsafe_formosa_candidate.dart';

void main() {
  group('Build UnsafeFormosaCandidate', () {
    final theme = FormosaTheme.bip39;

    test('Build valid UnsafeFormosaCandidate from entropy', () {
      final validEntropy = Uint8List(16);
      final candidate = UnsafeFormosaCandidate(validEntropy, theme);

      expect(candidate.isValidFormosa, isTrue,
          reason: 'Should produce a valid UnsafeFormosaCandidate.');
    });

    test('UnsafeFormosaCandidate converts to valid Formosa', () {
      final validEntropy = Uint8List(16);
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

  group('UnsafeFormosaCandidate Validations', () {
    final theme = FormosaTheme.bip39;

    // --- isValidEntropyLength ---
    test('isValidEntropyLength is true for valid entropy length', () {
      final validEntropy = Uint8List(16); // 128 bits
      final candidate = UnsafeFormosaCandidate(validEntropy, theme);

      expect(candidate.isValidEntropyLength, isTrue,
          reason: '128-bit entropy should pass isValidEntropyLength check.');
    });

    test('isValidEntropyLength is false for invalid entropy length', () {
      final invalidEntropy = Uint8List(15); // 120 bits
      final candidate = UnsafeFormosaCandidate(invalidEntropy, theme);

      expect(candidate.isValidEntropyLength, isFalse,
          reason: '120-bit entropy should fail isValidEntropyLength check.');
    });

    // --- isValidEntropyChecksum ---
    test('isValidEntropyChecksum is true for correct checksum', () {
      final validEntropy = Uint8List(16); // Predefined valid entropy
      final candidate = UnsafeFormosaCandidate(validEntropy, theme);

      expect(candidate.isValidEntropyChecksum, isTrue,
          reason: 'Valid checksum should pass isValidEntropyChecksum check.');
    });

    test('isValidEntropyChecksum is false for incorrect checksum', () {
      final invalidEntropy =
          Uint8List(16); // Simulate entropy with bad checksum
      final candidate = UnsafeFormosaCandidate(
        invalidEntropy,
        theme,
        checksumBits:
            ChecksumBits(List.filled(4, false)), // Forced bad checksum
      );

      expect(candidate.isValidEntropyChecksum, isFalse,
          reason: 'Invalid checksum should fail isValidEntropyChecksum check.');
    });

    // --- isValidWordLength ---
    test('isValidWordLength is true for correct number of words', () {
      final validMnemonic =
          'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
      final candidate = UnsafeFormosaCandidate.fromMnemonic(validMnemonic,
          formosaTheme: theme);

      expect(candidate.isValidWordLength, isTrue,
          reason: '12 words should pass isValidWordLength check.');
    });

    // TODO: fix fromMnemonic
    test('isValidWordLength is false for incorrect number of words', () {
      final invalidMnemonic = 'emerald magnificent occult rusty spicy varnished warped'; // 7 words
      final candidate = UnsafeFormosaCandidate.fromMnemonic(invalidMnemonic,
          formosaTheme: FormosaTheme.medievalFantasy);

      expect(candidate.isValidWordLength, isFalse,
          reason: '7 words should fail isValidWordLength check.');
    });

    // --- wordsExistInTheme ---
    test('wordsExistInTheme is true for words present in theme', () {
      final validMnemonic =
          'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
      final candidate = UnsafeFormosaCandidate.fromMnemonic(validMnemonic,
          formosaTheme: theme);

      expect(candidate.wordsExistInTheme, isTrue,
          reason: 'Words in the theme should pass wordsExistInTheme check.');
    });

    // TODO: fix fromMnemonic
    test('wordsExistInTheme is false for words not present in theme', () {
      final invalidMnemonic = 'abandon abandon abandon abandon abandon aba';
      final candidate = UnsafeFormosaCandidate.fromMnemonic(invalidMnemonic,
          formosaTheme: theme);

      expect(candidate.wordsExistInTheme, isFalse,
          reason:
              'Words not in the theme should fail wordsExistInTheme check.');
    });

    // --- isConcatenatedBitsMultipleOf33 ---
    test('isConcatenatedBitsMultipleOf33 is true for valid concatenated bits',
        () {
      final validEntropy = Uint8List(
          16); // 128 bits, checksum adds up to 132 bits (multiple of 33)
      final candidate = UnsafeFormosaCandidate(validEntropy, theme);

      expect(candidate.isConcatenatedBitsMultipleOf33, isTrue,
          reason:
              'Valid concatenated bits should pass isConcatenatedBitsMultipleOf33 check.');
    });

    test(
        'isConcatenatedBitsMultipleOf33 is false for invalid concatenated bits',
        () {
      final invalidEntropy = Uint8List(
          15); // 120 bits, checksum results in 123 bits (not multiple of 33)
      final candidate = UnsafeFormosaCandidate(invalidEntropy, theme);

      expect(candidate.isConcatenatedBitsMultipleOf33, isFalse,
          reason:
              'Invalid concatenated bits should fail isConcatenatedBitsMultipleOf33 check.');
    });
  });
}

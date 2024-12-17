import 'dart:typed_data';
import 'package:t3_crypto_objects/src/entropy/checksum_bits.dart';
import 'package:t3_crypto_objects/src/entropy/entropy_bytes.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/concatenated_bits.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_base.dart';
import 'package:test/test.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_theme.dart';

void main() {
  group('Formosa Class Tests', () {
    late FormosaTheme theme = FormosaTheme.bip39;

    test('should initialize with provided entropy', () {
      final entropy = Uint8List(4);
      final formosa = Formosa(entropy, theme);

      expect(formosa.value, equals(entropy),
          reason: 'Formosa should correctly store the provided entropy.');
    });

    test('should throw ArgumentError when entropy length is not a multiple of 4', () {
      final invalidEntropy = Uint8List.fromList([0, 1, 2]); // Not a multiple of 4
      expect(
        () => Formosa(invalidEntropy, theme),
        throwsA(isA<ArgumentError>()),
        reason: 'Formosa should throw when entropy length is invalid.',
      );
    });

    test('should generate valid mnemonic based on entropy', () {
      final entropy = Uint8List(16); // 128 bits of entropy
      final formosa = Formosa(entropy, theme);
      final mnemonic = formosa.getMnemonic();

      expect(mnemonic, isA<String>(),
          reason: 'Formosa should generate a valid mnemonic string.');
      expect(mnemonic.split(' ').length, equals(12),
          reason: '128 bits of entropy should produce 12 mnemonic words.');
    });

    test('should validate mnemonic reconstruction', () {
      final entropy = Uint8List(16);
      final formosa = Formosa(entropy, theme);
      final mnemonic = formosa.getMnemonic();

      final reconstructed = Formosa.fromMnemonic(mnemonic, formosaTheme: theme);
      expect(reconstructed.value, equals(formosa.value),
          reason: 'Formosa.fromMnemonic should reconstruct the original entropy.');
    });

    test('should throw ArgumentError for invalid mnemonic', () {
      const invalidMnemonic = 'invalid mnemonic test phrase';

      expect(
        () => Formosa.fromMnemonic(invalidMnemonic, formosaTheme: theme),
        throwsArgumentError,
        reason: 'Formosa should throw when given an invalid mnemonic.',
      );
    });

    test('should initialize with valid concatenated bits', () {
      var formosa = Formosa.fromRandomWords(formosaTheme: FormosaTheme.bip39);
      final concatenatedBits = formosa.bits + formosa.checksumBits.bits;
      final concatenated = ConcatenatedBits(concatenatedBits);

      expect(
        () => Formosa.fromConcatenatedBits(concatenated, formosaTheme: theme),
        returnsNormally,
        reason: 'Formosa should correctly initialize from valid concatenated bits.',
      );
    });

    test('should throw ArgumentError for invalid checksum on entropy', () {
      final entropyBytes = Uint8List.fromList([1, 1, 1, 1]);
      final invalidChecksumBits = ChecksumBits(List.of([true, false, true, true]));
      expect(
        () => Formosa(entropyBytes, theme, checksumBits: invalidChecksumBits),
        throwsA(isA<ArgumentError>()),
        reason: 'Formosa should throw if the checksum is invalid.',
      );
    });
  });
}

import 'dart:typed_data';

import 'package:t3_crypto_objects/src/entropy/formosa/formosa_base.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa_theme.dart';
import 'package:test/test.dart';

void main() {
  group('Formosa Class Tests', () {
    late FormosaTheme theme = FormosaTheme.bip39;
    Uint8List entropy = Uint8List(4);

    test('should initialize with provided entropy', () {
      final formosa = Formosa(entropy, theme);

      expect(formosa.value, equals(entropy));
    });

    test('should throw ArgumentError when entropy length is not a multiple of 4', () {
      final invalidEntropy = Uint8List.fromList([0, 1, 2]);
      expect(
        () => Formosa(invalidEntropy, theme),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should get mnemonic correctly', () {
      final formosa = Formosa(entropy, theme);

      final originalMnemonic = formosa.getMnemonic();

      final newEntropy = Uint8List.fromList([1, 1, 1, 1]);
      formosa.value = newEntropy;

      expect(formosa.getMnemonic(), isNot(originalMnemonic));
    });

    test('should generate valid mnemonic based on entropy', () {
      final formosa = Formosa(entropy, theme);

      expect(formosa.getMnemonic(), isA<String>());
      expect(formosa.getMnemonic().split(' ').length, greaterThan(1));
    });
  });
}

import 'package:t3_crypto_objects/src/entropy/formosa/theme_base.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/themes/bip39.dart';
import 'package:test/test.dart';

void main() {
  group('ThemeBase Tests', () {
    final theme = ThemeBase(themeData: bip39Data);

    test('Filling order is correctly retrieved', () {
      expect(theme.fillingOrder, ['WORDS']);
    });

    test('Natural order is correctly retrieved', () {
      expect(theme.naturalOrder, ['WORDS']);
    });

    test('Leads is empty as expected', () {
      expect(theme.leads, isEmpty);
    });

    test('LedBy is empty as expected', () {
      expect(theme.ledBy, '{}');
    });

    test('Bit length is correctly retrieved for WORDS', () {
      expect(theme['WORDS']['BIT_LENGTH'], 11);
    });

    test('Mapping returns an empty ThemeBase for missing keys', () {
      final mapping = theme.mapping;
      expect(mapping, isA<ThemeBase>());
      expect(mapping.keys, isEmpty);
    });

    test('Natural map calculates correct indexes', () {
      expect(theme.naturalMap, [0]);
    });

    test('Bits per phrase is correctly calculated', () {
      expect(theme.bitsPerPhrase(), 11);
    });

    test('Bits fill sequence is correctly calculated', () {
      expect(theme.bitsFillSequence(), [11]);
    });
  });
}

import 'package:t3_crypto_objects/src/entropy/formosa/formosa_theme.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/unsafe_formosa_candidate.dart';

void main() {
  final formosaTheme = FormosaTheme.global;

  final unsafeFormosaCandidate = UnsafeFormosaCandidate.fromRandomWords(wordCount:  6, formosaTheme: formosaTheme);

  print('Entropy: ${unsafeFormosaCandidate.value}');
  print('Mnemonic: ${unsafeFormosaCandidate.mnemonic}');
  print('Is Valid Entropy Length: ${unsafeFormosaCandidate.isValidEntropyLength}');
  print('Is Valid Entropy Checksum: ${unsafeFormosaCandidate.isValidEntropyChecksum}');
  print('Is Valid Word Length: ${unsafeFormosaCandidate.isValidWordLength}');
  print('Words Exist In Theme: ${unsafeFormosaCandidate.wordsExistInTheme}');
  print('Is Concatenated Bits Multiple of 33: ${unsafeFormosaCandidate.isConcatenatedBitsMultipleOf33}');
  print('Is Valid Formosa: ${unsafeFormosaCandidate.isValidFormosa()}');

  final mnemonic = unsafeFormosaCandidate.mnemonic;
  final unsafeFormosaCandidateFromMnemonic =
      UnsafeFormosaCandidate.fromMnemonic(mnemonic, formosaTheme: formosaTheme);

  print('\nCandidate From Mnemonic:');
  print('Entropy: ${unsafeFormosaCandidateFromMnemonic.value}');
  print('Mnemonic: ${unsafeFormosaCandidateFromMnemonic.mnemonic}');
  print('Is Valid Formosa: ${unsafeFormosaCandidateFromMnemonic.isValidFormosa()}');

  final formosa = unsafeFormosaCandidate.toFormosa();
  if (formosa != null) {
    print('\nConverted to Formosa:');
    print('Value: ${formosa.value}');
    print('Value: ${formosa.mnemonic}');
    print('Checksum Bits: ${formosa.checksumBits.bits}');
  } else {
    print('\nCandidate is not valid Formosa');
  }
}

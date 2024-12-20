# crypto_objects

A comprehensive package encapsulating various cryptographic objects and utilities for use in secure applications. The package merges features from [Formosa](https://github.com/Yuri-SVB/formosa) and other cryptographic tools such as AES encryption, Argon2-based key derivation, and entropy modeling.

## Features

### Formosa
Formosa is a password format that maximizes the ratio of password strength to user effort by generating meaningful thematic phrases based on entropy. It includes:
- Generating thematic formosa phrases based on entropy.
- Reversing entropy from formosa phrases.
- Selecting specific themes for formosa generation.

### AES Encryption
A utility for encrypting and decrypting data using AES-GCM, providing confidentiality and integrity protection for sensitive information.

### Argon2 Derivation Service
Provides methods to derive cryptographic hashes and encryption keys using the Argon2 algorithm:
- **High memory usage derivation**: Configured for strong computational resistance with iterative processing.
- **Moderate memory usage derivation**: Optimized for quicker derivation with reasonable security.
- **AES key derivation**: Generates secure 256-bit AES keys for encryption.

### Entropy Modeling
Encapsulates utilities for modeling and managing entropy:
- **Entropy Nodes**: Models nodes for protocols like GreatWall.
- **SAI Entropy Objects**: Includes objects such as `sa0`, `sa1`, `sa2`, and `sa3` for handling input entropy.

## Getting started

To add `crypto_objects` to your project, include it in your `pubspec.yaml`:

```yaml
dependencies:
  crypto_objects: ^1.0.0
```
Run the following command to install the package:

```bash
dart pub get
```

## Usage
### Formosa Example
Generate a formosa phrase from entropy and reverse the process:

```dart
void main() {
  Formosa formosa = Formosa(Uint8List[0], FormosaTheme.bip39);
}
```
For a more exhaustive example see the example `/example/entropy/formosa/formosa_example.dart`

### AES Encryption Example
Encrypt and decrypt data using AES-GCM:

```dart
import 'package:crypto_objects/aes_encryption.dart';

void main() async {
  Eka eka = Eka();
  final ciphertext = await eka.encrypt(Critical(Uint8List[0]));
  final plaintext = await eka.decrypt(ciphertext);
}

```
For a more exhaustive example see the example `example/encryption/aes_key_example.dart`

### Argon2 Key Derivation Example
Derive a secure encryption key:

```dart
import 'package:crypto_objects/argon2_service.dart';

void main() async {
  Argon2DerivationService argon2 = Argon2DerivationService();
  int iterations = 10;
  final key = await argon2.deriveWithHighMemory(10, Uint8List[0]);
}

```
For a more exhaustive example see the example `example/argon2/argon2_example.dart`

## Additional information
This package consolidates cryptographic utilities to streamline security-focused development. For more information or to contribute, please refer to the [GitHub repository](https://github.com/T3-InfoSec/t3-crypto-objects-dart).
Issues or feature requests are welcome, and the maintainers aim to provide timely responses.


import 'package:t3_crypto_objects/src/encryption/aes_key.dart';
import 'package:t3_crypto_objects/src/tlp_helper/tlp.dart';

/// Tlp is an ephemeral encryption key used to encrypt critical data.
///
class Tlp extends AesKey {
  /// Constructor that automatically generates a new secure BigInt (TLP answer) [key].
  Tlp() : super(_generateBigIntKey());

  /// Constructor to create an instance of `Tlp` with an existing [key].
  Tlp.fromKey(super.key);

  /// Static helper to generate the key.
  static BigInt _generateBigIntKey({
    int bits = 32,
    int t = 3,
  }) {
    TlpHelper tlpHelper = TlpHelper(bits: bits);
    BigInt prime1 = tlpHelper.generatedPrime;
    BigInt prime2 = tlpHelper.generatedPrime;

    BigInt base2 = BigInt.from(2);
    BigInt basegBigInt = tlpHelper.generatedBase;
    BigInt tBigInt = BigInt.from(t);

    BigInt primeProduct = tlpHelper.comupteProductOfPrime(prime1, prime2);
    BigInt carmichaelp = tlpHelper.calculateCarmichael(prime1, prime2);

    BigInt fastExp = tlpHelper.modExp(base2, tBigInt, carmichaelp);
    BigInt fastPower = tlpHelper.modExp(basegBigInt, fastExp, primeProduct);

    /// Clear the values of the prime numbers and carmichael function
    prime2;
    carmichaelp;
    fastExp;
    prime2 = BigInt.from(0);
    return fastPower;
  }
}

import 'package:t3_crypto_objects/src/encryption/aes_key.dart';
import 'package:t3_crypto_objects/src/tlp_helper/tlp.dart';

/// Tlp is an ephemeral encryption key used to encrypt critical data.
///
class Tlp extends AesKey {
  final int? bits;
  static late PrimeManager privatePrimesManager;

  /// Constructor that automatically generates a new secure BigInt (TLP answer) [key].
  Tlp({this.bits = 2048}) : super(_generateBigIntKey(bits: bits));

  /// Constructor to create an instance of `Tlp` with an existing [key].
  Tlp.fromKey(super.key, {this.bits});

  /// Static helper to generate the key.
  static BigInt _generateBigIntKey({
    int? bits = 2048,
    int t = 3,
  }) {
    TlpHelper tlpHelper = TlpHelper(bits: bits!);
    BigInt base2 = BigInt.from(2);
    BigInt baseg = tlpHelper.generatedBase;
    BigInt tBigInt = BigInt.from(t);

    BigInt prime1 = tlpHelper.generatedPrime;
    BigInt prime2 = tlpHelper.generatedPrime;
    BigInt primeProduct = tlpHelper.comupteProductOfPrime(prime1, prime2);

    privatePrimesManager = PrimeManager(
      bits,
      base2: base2,
      baseg: baseg,
      t: tBigInt,
      primeProduct: primeProduct,
      prime1: prime1,
      prime2: prime2,
    );
    privatePrimesManager.init();
    prime1 = BigInt.zero;
    prime2 = BigInt.zero;
    return privatePrimesManager.fastPower;
  }

  void dispose() {
    privatePrimesManager.dispose();
  }
}

class PrimeManager {
  final int bits;
  final BigInt base2;
  final BigInt baseg;
  final BigInt t;
  final BigInt primeProduct;
  final BigInt prime1;
  final BigInt prime2;
  PrimeManager(
    this.bits, {
    required this.base2,
    required this.baseg,
    required this.t,
    required this.primeProduct,
    required this.prime1,
    required this.prime2,
  });

  BigInt carmichael = BigInt.zero;
  BigInt _fastExp = BigInt.zero;
  BigInt fastPower = BigInt.zero;

  /// Initialize the prime numbers and carmichael function
  init() {
    final tlpHelper = TlpHelper(bits: bits);
    carmichael = tlpHelper.calculateCarmichael(prime1, prime2);
    _fastExp = tlpHelper.modExp(base2, t, carmichael);
    fastPower = tlpHelper.modExp(baseg, _fastExp, primeProduct);
  }

  /// Clear the values of the prime numbers and carmichael function
  void dispose() {
    carmichael = BigInt.zero;
    _fastExp = BigInt.zero;
    fastPower = BigInt.zero;
  }
}

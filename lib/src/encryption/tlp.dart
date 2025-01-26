import 'package:t3_crypto_objects/src/encryption/aes_key.dart';
import 'package:t3_crypto_objects/src/tlp_helper/tlp.dart';

/// Tlp is an ephemeral encryption key used to encrypt critical data.
///
class Tlp extends AesKey {
  final int? bits;
  static late TlpSecretKey tlpSecretKeyManager;

  /// Constructor that automatically generates a new secure BigInt (TLP answer) [key].
  Tlp({this.bits = 1048576}) : super(_generateBigIntKey(bits: bits));

  /// Constructor to create an instance of `Tlp` with an existing [key].
  Tlp.fromKey(super.key, {this.bits});

  /// Static helper to generate the key, TLP Key is a [BigInt] value computed using the [TlpHelper] class fast exponent.
  static BigInt _generateBigIntKey({
    int? bits = 1048576,
    int t = 3,
  }) {
    TlpHelper tlpHelper = TlpHelper(bits: bits!);

    BigInt baseg = tlpHelper.generatedBase;
    BigInt tBigInt = BigInt.from(t);

    tlpSecretKeyManager = TlpSecretKey(bits);

    final secretKeys = tlpSecretKeyManager.init(
      baseg: baseg,
      t: tBigInt,
    );

    BigInt primeProduct = secretKeys.$2;
    //visible for testing
    print('Prime Product: $primeProduct \n Baseg: $baseg \n T: $tBigInt');

    return secretKeys.$1;
  }

  BigInt computeSlowPower(BigInt baseg, BigInt t, BigInt product, {int? bits}) {
    final tlpHelper = TlpHelper(bits: bits ?? 1048576);
    BigInt slowPower = baseg;

    for (var i = BigInt.zero; i < t; i += BigInt.one) {
      slowPower = tlpHelper.modExp(baseg, BigInt.two, product);
    }

    return slowPower;
  }

  void dispose() {
    tlpSecretKeyManager.dispose();
  }
}

class TlpSecretKey {
  final int bits;

  TlpSecretKey(this.bits);

  BigInt _prime1 = BigInt.zero;
  BigInt _prime2 = BigInt.zero;
  BigInt _carmichael = BigInt.zero;
  BigInt _fastExp = BigInt.zero;
  BigInt _fastPower = BigInt.zero;
  final BigInt _base2 = BigInt.from(2);

  /// Initialize the prime numbers and carmichael function
  (BigInt, BigInt) init({required BigInt baseg, required BigInt t}) {
    final tlpHelper = TlpHelper(bits: bits);

    _prime1 = tlpHelper.generatedPrime;
    _prime2 = tlpHelper.generatedPrime;

    _carmichael = tlpHelper.calculateCarmichael(_prime1, _prime2);
    _fastExp = tlpHelper.modExp(_base2, t, _carmichael);

    BigInt primeProduct = tlpHelper.comupteProductOfPrime(_prime1, _prime2);
    _fastPower = tlpHelper.modExp(baseg, _fastExp, primeProduct);
    return (_fastPower, primeProduct);
  }

  /// Clear the values of the prime numbers and carmichael function
  void dispose() {
    _prime1 = BigInt.zero;
    _prime2 = BigInt.zero;
    _carmichael = BigInt.zero;
    _fastExp = BigInt.zero;
    _fastPower = BigInt.zero;
  }
}

import 'package:t3_crypto_objects/src/tlp_helper/prime_genearator.dart';

class TlpHelper {
  final PrimeGenerator primeGenerator;
  TlpHelper({required int bits}) : primeGenerator = PrimeGenerator(bits);

  BigInt get generatedBase => _generateBase();
  // randomly generate base
  BigInt _generateBase() {
    return primeGenerator.generateBigInt();
  }

  BigInt get generatedPrime => _generatePrime();

  /// Generates a prime number
  BigInt _generatePrime() {
    return primeGenerator.generatePrime();
  }

  /// Calculates the product of two prime numbers
  comupteProductOfPrime(BigInt prime1, BigInt prime2) {
    return prime1 * prime2;
  }

  /// Calculates the Carmichael function of the product of two prime numbers
  BigInt calculateCarmichael(BigInt prime1, BigInt prime2) {
    return primeGenerator.calculateCarmichael(prime1, prime2);
  }

  /// Calculates the totient of two prime numbers
  BigInt calculateTotient(BigInt prime1, BigInt prime2) {
    return primeGenerator.calculateTotient(prime1, prime2);
  }

  /// Calculates the modular exponentiation of a number
  BigInt modExp(BigInt base, BigInt exp, BigInt mod) {
    return primeGenerator.modExp(base, exp, mod);
  }

  BigInt extendedGCD(BigInt a, BigInt b) {
    if (b == BigInt.zero) {
      return a;
    }
    return extendedGCD(b, a % b);
  }

  BigInt modInverse(BigInt a, BigInt m) {
    BigInt m0 = m;
    BigInt x0 = BigInt.zero;
    BigInt x1 = BigInt.one;

    if (m == BigInt.one) return BigInt.zero;

    while (a > BigInt.one) {
      // q is quotient
      BigInt q = a ~/ m;
      BigInt t = m;

      m = a % m;
      a = t;
      t = x0;

      x0 = x1 - q * x0;
      x1 = t;
    }

    if (x1 < BigInt.zero) x1 += m0;

    return x1;
  }
}

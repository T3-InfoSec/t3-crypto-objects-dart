import 'dart:math';

import 'package:t3_crypto_objects/src/tlp_helper/bigint_prime_helper.dart';

class PrimeGenerator {
  final int bits;
  final Random random;

  PrimeGenerator(this.bits) : random = Random.secure();

  BigInt generatePrime() {
    BigInt prime = randomPrimeBigInt(bits, random: random);
    return prime;
  }

  BigInt generateBigInt() {
    return randomBigInt(bits, random: random);
  }

  BigInt calculateTotient(BigInt p1, BigInt p2) {
    BigInt p1Minus1 = p1 - BigInt.one;
    BigInt p2Minus1 = p2 - BigInt.one;
    return p1Minus1 * p2Minus1;
  }

  BigInt calculateCarmichael(BigInt p1, BigInt p2) {
    BigInt p1Minus1 = p1 - BigInt.one;
    BigInt p2Minus1 = p2 - BigInt.one;
    return _lcm(p1Minus1, p2Minus1);
  }

  BigInt modExp(BigInt base, BigInt exp, BigInt mod) {
    return base.modPow(exp, mod);
  }

  BigInt _lcm(BigInt a, BigInt b) {
    return (a * b) ~/ a.gcd(b);
  }
}

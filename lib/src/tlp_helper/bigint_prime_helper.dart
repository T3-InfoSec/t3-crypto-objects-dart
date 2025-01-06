import 'dart:math';

import 'package:t3_crypto_objects/src/tlp_helper/isprime.dart';


final _bigFF = BigInt.from(0xff);

BigInt randomPrimeBigInt(int bits, {Random? random}) {
  random ??= Random.secure();

  while (true) {
    var next = randomBigInt(bits, random: random);
    if (next.isEven) next = next | BigInt.one;

    while (next.bitLength == bits) {
      if (isPrime(next)) {
        return next;
      }
      next += BigInt.two;
    }
  }
}


BigInt randomBigInt(int bits, {BigInt? max, Random? random}) {
  random ??= Random.secure();

  if (max != null) {
    if (max.bitLength != bits) {
      throw Exception('limit must have bitLength of bits');
    }
  }

  final numBytes = (bits / 8).ceil();

  var ret = BigInt.zero;
  bool lessThanMax = max == null;

  for (int i = 0; i < numBytes; i++) {
    int next = random.nextInt(256);

    // For first byte, get rid of excess leading bits
    if (i == 0) {
      final unneededBits = (numBytes * 8) - bits;
      final neededBits = 8 - unneededBits;
      next &= (1 << neededBits) - 1;
      next |= 1 << neededBits - 1;
    }

    // Make sure generated number is less than [max]
    if (!lessThanMax) {
      final maxByte = ((max! >> ((numBytes - i - 1) * 8)) & _bigFF).toInt();
      if (next >= maxByte) {
        int mask = (next ^ maxByte) & next;
        int maskMask = 0x80;
        if (i == 0) {
          int safeBits = bits - (numBytes - 1) * 8;
          if (safeBits == 1) {
            maskMask = 0;
          } else {
            maskMask = 1 << (safeBits - 2);
          }
        }
        while (maskMask != 0) {
          final isBit = mask & maskMask;
          if (isBit != 0) {
            next &= ~maskMask;

            if (next < maxByte) {
              lessThanMax = true;
              break;
            }
          }

          if (maxByte & maskMask != 0) {
            next &= ~maskMask;

            if (next < maxByte) {
              lessThanMax = true;
              break;
            }
          }

          maskMask >>= 1;
        }
      } else {
        lessThanMax = true;
      }
    }

    ret <<= 8;
    ret |= BigInt.from(next);
  }

  return ret;
}

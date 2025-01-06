import 'dart:math';

/// Checks if a BigInt is prime using Miller-Rabin primality test
bool isPrime(BigInt n, {int k = 20}) {
  if (n <= BigInt.one) return false;
  if (n == BigInt.two || n == BigInt.from(3)) return true;
  if (n.isEven) return false;

  // Write n as d*2^r + 1 with d odd
  var r = 0;
  var d = n - BigInt.one;
  while (d.isEven) {
    d ~/= BigInt.two;
    r++;
  }

  final random = Random.secure();
  for (var i = 0; i < k; i++) {
    final a = BigInt.from(random.nextInt(1 << 32)) % (n - BigInt.two) + BigInt.two;
    var x = a.modPow(d, n);
    if (x == BigInt.one || x == n - BigInt.one) continue;

    var continueLoop = false;
    for (var j = 0; j < r - 1; j++) {
      x = x.modPow(BigInt.two, n);
      if (x == n - BigInt.one) {
        continueLoop = true;
        break;
      }
    }

    if (!continueLoop) return false;
  }

  return true;
}

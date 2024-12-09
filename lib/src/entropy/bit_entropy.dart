import 'dart:typed_data';

class BitEntropy {
  List<bool> bits;

  /// Constructs a [BitEntropy] from a list of booleans representing bits.
  /// Each boolean in [bits] is `true` for 1 and `false` for 0.
  BitEntropy(this.bits);

  /// Converts the bit sequence into a binary string representation.
  @override
  String toString() => bits.map((b) => b ? '1' : '0').join();

  /// Calculates the length of the bit sequence.
  int get length => bits.length;

  /// Converts [BitEntropy]] to a byte array.
  Uint8List toBytes() {
    if (bits.length % 8 != 0) {
      throw ArgumentError("The length of the bit sequence must be a multiple of 8 to convert to bytes.");
    }

    final bytes = Uint8List(bits.length ~/ 8);

    for (int byteIndex = 0; byteIndex < bytes.length; byteIndex++) {
      bytes[byteIndex] = _bitsToByte(bits.sublist(byteIndex * 8, (byteIndex + 1) * 8));
    }

    return bytes;
  }

  /// Converts an 8-bit list [bitSegment] to a byte `int`.
  int _bitsToByte(List<bool> bitSegment) {
    if (bitSegment.length != 8) {
      throw ArgumentError("A byte must consist of exactly 8 bits.");
    }

    int byte = 0;
    for (int i = 0; i < 8; i++) {
      if (bitSegment[i]) {
        byte |= (1 << (7 - i));
      }
    }
    return byte;
  }
}
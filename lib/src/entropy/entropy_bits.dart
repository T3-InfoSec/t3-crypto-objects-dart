import 'dart:typed_data';

/// Represents a sequence of bits used for modeling entropy.
///
/// This class provides methods to manipulate entropy as a list of [bits]
/// and convert it to/from byte arrays or binary string representations.
class EntropyBits {
  List<bool> bits;

  /// Constructs a [EntropyBits] from a list of booleans representing bits.
  /// Each boolean in [bits] is `true` for 1 and `false` for 0.
  EntropyBits(this.bits);

  /// Converts the bit sequence into a binary string representation.
  @override
  String toString() => bits.map((b) => b ? '1' : '0').join();

  /// Calculates the length of the bit sequence.
  int get length => bits.length;

  /// Converts [EntropyBits]] to a byte array.
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

   /// Converts a bits string to bytes.
  static Uint8List stringBitsToBytes(String bits) {
    int byteLength = bits.length ~/ 8;
    Uint8List result = Uint8List(byteLength);

    for (int i = 0; i < byteLength; i++) {
      int byteValue = int.parse(bits.substring(i * 8, (i + 1) * 8), radix: 2);
      result[i] = byteValue;
    }

    return result;
  }

  static Uint8List boolBitsToBytes(List<bool> bits) {
    final length = (bits.length + 7) ~/ 8;
    final byteArray = Uint8List(length);

    for (int i = 0; i < bits.length; i++) {
      if (bits[i]) {
        byteArray[i ~/ 8] |= (1 << (7 - i % 8));
      }
    }

    return byteArray;
  }

  /// Converts [bytes] to a list of bits.
  static List<bool> bytesToBits(Uint8List bytes) {
    return bytes.expand((byte) => byteToBits(byte)).toList();
  }

  /// Converts a single byte to a list of 8 bits..
  static List<bool> byteToBits(int byte) {
    return List.generate(8, (i) => (byte & (1 << (7 - i))) != 0);
  }
}
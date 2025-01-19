import 'dart:typed_data';

import 'package:t3_crypto_objects/src/entropy/formosa/formosa_theme.dart';
import 'package:t3_crypto_objects/src/entropy/sa0.dart';
import 'package:t3_crypto_objects/src/entropy/sa1.dart';
import 'package:t3_crypto_objects/src/entropy/sa1i.dart';
import 'package:t3_crypto_objects/src/entropy/sa2.dart';
import 'package:t3_crypto_objects/src/entropy/sa3.dart';
import 'package:t3_crypto_objects/src/entropy/formosa/formosa.dart';

void main() {
  // Initialize the initial entropy (Sa0)
  Formosa formosa = Formosa(Uint8List(32), FormosaTheme.bip39);
  Sa0 sa0 = Sa0(formosa);
  print('Initial Sa0: ${sa0.toString()}');

  // Derive Sa1 from Sa0
  Sa1 sa1 = Sa1();
  sa1.from(sa0);
  print('Derived Sa1: ${sa1.toString()}');

  // Subscribe to changes in intermediateStates of Sa1
  sa1.intermediateStatesStream.listen((List<Sa1i> intermediateStates) {
    print("Intermediate states length: ${intermediateStates.length}");
    print("Last state: ${intermediateStates.last}");
  });

  // Derive Sa2 from Sa1
  Sa2 sa2 = Sa2();
  sa2.from(5, sa1);
  print('Derived Sa2: ${sa2.toString()}}');

  // Derive Sa3 from Sa0 and Sa2
  Sa3 sa3 = Sa3();
  sa3.from(sa0, sa2);
  print('Derived Sa3: ${sa3.toString()}}');

  // Clean up resources
  sa1.dispose();
}

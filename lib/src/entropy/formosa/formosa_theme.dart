import 'themes/themes.dart';
import 'theme_base.dart';

enum FormosaTheme {
  bip39(
    name: 'bip39',
    data: ThemeBase(themeData: bip39Data),
  ),
  bip39French(
    name: 'bip39_french',
    data: ThemeBase(themeData: bip39FrenchData),
  ),
  copyLeft(
    name: 'copy_left',
    data: ThemeBase(themeData: copyLeftData),
  ),
  cutePets(
    name: 'cute_pets',
    data: ThemeBase(themeData: cutePetsData),
  ),
  farmAnimals(
    name: 'farm_animals',
    data: ThemeBase(themeData: farmAnimalsData),
  ),
  finances(
    name: 'finances',
    data: ThemeBase(themeData: financesData),
  ),
  medievalFantasy(
    name: 'medieval_fantasy',
    data: ThemeBase(themeData: medievalFantasyData),
  ),
  sciFi(
    name: 'sci_fi',
    data: ThemeBase(themeData: sciFiData),
  ),
  tourism(
    name: 'tourism',
    data: ThemeBase(themeData: tourismData),
  );

  final String _name;
  final ThemeBase _data;

  const FormosaTheme({required name, required data})
      : _name = name,
        _data = data;

  String get name => _name;

  ThemeBase get data => _data;
}

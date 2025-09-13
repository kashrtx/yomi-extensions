import '../../../../../../../model/source.dart';

Source get ninjascanSource => _ninjascanSource;
Source _ninjascanSource = Source(
  name: "Ninja Scan",
  baseUrl: "https://ninjacomics.xyz",
  lang: "pt-br",
  isNsfw: false,
  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/main/dart/manga/multisrc/madara/src/pt/ninjascan/icon.png",
  dateFormat: "dd 'de' MMMMM 'de' yyyy",
  dateFormatLocale: "pt-br",
);

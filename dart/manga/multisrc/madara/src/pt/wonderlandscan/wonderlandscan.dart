import '../../../../../../../model/source.dart';

Source get wonderlandscanSource => _wonderlandscanSource;

Source _wonderlandscanSource = Source(
  name: "Wonderland Scan",
  baseUrl: "https://wonderlandscan.com",
  lang: "pt-BR",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/madara/src/pt/wonderlandscan/icon.png",
  dateFormat: "dd/MM/yyyy",
  dateFormatLocale: "pt-br",
);

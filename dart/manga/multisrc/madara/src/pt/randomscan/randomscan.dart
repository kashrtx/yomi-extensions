import '../../../../../../../model/source.dart';

Source get randomscanSource => _randomscanSource;

Source _randomscanSource = Source(
  name: "Random Scan",
  baseUrl: "https://randomscanlators.net",
  lang: "pt-BR",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/madara/src/pt/randomscan/icon.png",
  dateFormat: "MMMMM dd, yyyy",
  dateFormatLocale: "pt-br",
);

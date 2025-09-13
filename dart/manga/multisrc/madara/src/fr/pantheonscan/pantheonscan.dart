import '../../../../../../../model/source.dart';

Source get pantheonscanSource => _pantheonscanSource;

Source _pantheonscanSource = Source(
  name: "Pantheon Scan",
  baseUrl: "https://pantheon-scan.com",
  lang: "fr",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/madara/src/fr/pantheonscan/icon.png",
  dateFormat: "d MMMM yyyy",
  dateFormatLocale: "fr",
);

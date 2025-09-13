import '../../../../../../../model/source.dart';

Source get phenixscansSource => _phenixscansSource;

Source _phenixscansSource = Source(
  name: "PhenixScans",
  baseUrl: "https://phenixscans.fr",
  lang: "fr",
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/fr/phenixscans/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "fr",
);

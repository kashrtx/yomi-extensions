import '../../../../../../../model/source.dart';

Source get sushiscanSource => _sushiscanSource;

Source _sushiscanSource = Source(
  name: "Sushi-Scan",
  baseUrl: "https://sushiscan.net",
  lang: "fr",
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/fr/sushiscan/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "fr",
);

import '../../../../../../../model/source.dart';

Source get azurescansSource => _azurescansSource;

Source _azurescansSource = Source(
  name: "Azure Scans",
  baseUrl: "https://azuremanga.com",
  lang: "en",
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/en/azurescans/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "en_us",
);

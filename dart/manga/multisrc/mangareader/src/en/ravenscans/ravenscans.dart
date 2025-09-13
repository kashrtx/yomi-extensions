import '../../../../../../../model/source.dart';

Source get ravenscansSource => _ravenscansSource;

Source _ravenscansSource = Source(
  name: "Raven Scans",
  baseUrl: "https://ravenscans.com",
  lang: "en",
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/en/ravenscans/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "en_us",
);

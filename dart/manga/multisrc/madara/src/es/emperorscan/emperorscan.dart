import '../../../../../../../model/source.dart';

Source get emperorscanSource => _emperorscanSource;

Source _emperorscanSource = Source(
  name: "Emperor Scan",
  baseUrl: "https://emperorscan.mundoalterno.org",
  lang: "es",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/madara/src/es/emperorscan/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "es",
);

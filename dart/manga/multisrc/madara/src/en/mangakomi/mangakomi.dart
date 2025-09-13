import '../../../../../../../model/source.dart';

Source get mangakomiSource => _mangakomiSource;

Source _mangakomiSource = Source(
  name: "MangaKomi",
  baseUrl: "https://mangakomi.io",
  lang: "en",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/madara/src/en/mangakomi/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "en_us",
);

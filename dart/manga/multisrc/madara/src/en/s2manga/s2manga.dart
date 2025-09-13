import '../../../../../../../model/source.dart';

Source get s2mangaSource => _s2mangaSource;

Source _s2mangaSource = Source(
  name: "S2Manga",
  baseUrl: "https://s2manga.com",
  lang: "en",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/madara/src/en/s2manga/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "en_us",
);

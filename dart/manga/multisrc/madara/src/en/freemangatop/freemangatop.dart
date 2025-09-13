import '../../../../../../../model/source.dart';

Source get freemangatopSource => _freemangatopSource;

Source _freemangatopSource = Source(
  name: "FreeMangaTop",
  baseUrl: "https://freemangatop.com",
  lang: "en",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/madara/src/en/freemangatop/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "en_us",
);

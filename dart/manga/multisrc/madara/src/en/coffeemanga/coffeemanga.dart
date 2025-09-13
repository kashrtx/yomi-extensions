import '../../../../../../../model/source.dart';

Source get coffeemangaSource => _coffeemangaSource;

Source _coffeemangaSource = Source(
  name: "Coffee Manga",
  baseUrl: "https://coffeemanga.io",
  lang: "en",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/madara/src/en/coffeemanga/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "en_us",
);

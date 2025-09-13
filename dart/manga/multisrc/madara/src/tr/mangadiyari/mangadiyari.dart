import '../../../../../../../model/source.dart';

Source get mangadiyariSource => _mangadiyariSource;

Source _mangadiyariSource = Source(
  name: "Manga Diyari",
  baseUrl: "https://manga-diyari.com",
  lang: "tr",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/madara/src/tr/mangadiyari/icon.png",
  dateFormat: "MMM dd, yyyy",
  dateFormatLocale: "tr",
);

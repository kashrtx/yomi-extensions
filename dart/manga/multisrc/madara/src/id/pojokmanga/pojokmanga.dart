import '../../../../../../../model/source.dart';

Source get pojokmangaSource => _pojokmangaSource;

Source _pojokmangaSource = Source(
  name: "Pojok Manga",
  baseUrl: "https://pojokmanga.net",
  lang: "id",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/madara/src/id/pojokmanga/icon.png",
  dateFormat: "MMM dd, yyyy",
  dateFormatLocale: "en_us",
);

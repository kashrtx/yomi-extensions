import '../../../../../../../model/source.dart';

Source get astralmangaSource => _astralmangaSource;

Source _astralmangaSource = Source(
  name: "AstralManga",
  baseUrl: "https://astral-manga.fr",
  lang: "fr",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/madara/src/fr/astralmanga/icon.png",
  dateFormat: "dd/mm/yyyy",
  dateFormatLocale: "fr",
);

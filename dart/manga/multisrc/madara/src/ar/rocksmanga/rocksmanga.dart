import '../../../../../../../model/source.dart';

Source get rocksmangaSource => _rocksmangaSource;
Source _rocksmangaSource = Source(
  name: "Rocks Manga",
  baseUrl: "https://rocksmanga.com",
  lang: "ar",
  isNsfw: false,
  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/main/dart/manga/multisrc/madara/src/ar/rocksmanga/icon.png",
  dateFormat: "MMMM d, yyyy",
  dateFormatLocale: "ar",
);

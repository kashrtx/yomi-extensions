import '../../../../../../../model/source.dart';

Source get garciamangaSource => _garciamangaSource;
Source _garciamangaSource = Source(
  name: "Garcia Manga",
  baseUrl: "https://garciamanga.com",
  lang: "tr",
  isNsfw: false,
  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/main/dart/manga/multisrc/madara/src/tr/garciamanga/icon.png",
  dateFormat: "MMMM d, yyyy",
  dateFormatLocale: "tr",
);

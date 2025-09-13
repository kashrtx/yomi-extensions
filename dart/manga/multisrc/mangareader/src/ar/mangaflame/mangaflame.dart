import '../../../../../../../model/source.dart';

Source get mangaflameSource => _mangaflameSource;
Source _mangaflameSource = Source(
  name: "Manga Flame",
  baseUrl: "https://mangaflame.org",
  lang: "ar",
  isNsfw: false,
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/ar/mangaflame/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "ar",
);

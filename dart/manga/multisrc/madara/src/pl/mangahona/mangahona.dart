import '../../../../../../../model/source.dart';

Source get mangahonaSource => _mangahonaSource;
Source _mangahonaSource = Source(
  name: "MangaHoNa",
  baseUrl: "https://mangahona.pl",
  lang: "pl",
  isNsfw: false,
  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/main/dart/manga/multisrc/madara/src/pl/mangahona/icon.png",
  dateFormat: "yyyy-MM-dd",
  dateFormatLocale: "en",
);

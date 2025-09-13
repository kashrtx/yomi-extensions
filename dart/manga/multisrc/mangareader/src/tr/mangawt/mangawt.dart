import '../../../../../../../model/source.dart';

Source get mangawtSource => _mangawtSource;

Source _mangawtSource = Source(
  name: "MangaWT",
  baseUrl: "https://mangawt.com",
  lang: "tr",
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/tr/mangawt/icon.png",
  dateFormat: "MMM d, yyyy",
  dateFormatLocale: "tr",
);

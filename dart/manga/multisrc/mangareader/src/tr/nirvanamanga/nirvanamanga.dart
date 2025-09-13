import '../../../../../../../model/source.dart';

Source get nirvanamangaSource => _nirvanamangaSource;
Source _nirvanamangaSource = Source(
  name: "Nirvana Manga",
  baseUrl: "https://nirvanamanga.com",
  lang: "tr",
  isNsfw: false,
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/tr/nirvanamanga/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "tr",
);

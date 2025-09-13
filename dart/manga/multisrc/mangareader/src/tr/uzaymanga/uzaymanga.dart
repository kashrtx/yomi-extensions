import '../../../../../../../model/source.dart';

Source get uzaymangaSource => _uzaymangaSource;

Source _uzaymangaSource = Source(
  name: "Uzay Manga",
  baseUrl: "https://uzaymanga.com",
  lang: "tr",
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/tr/uzaymanga/icon.png",
  dateFormat: "MMM d, yyyy",
  dateFormatLocale: "tr",
);

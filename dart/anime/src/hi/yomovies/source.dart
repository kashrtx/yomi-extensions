import '../../../../../model/source.dart';

Source get yomoviesSource => _yomoviesSource;
const _yomoviesVersion = "0.0.3";
const _yomoviesSourceCodeUrl =
    "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/anime/src/hi/yomovies/yomovies.dart";
Source _yomoviesSource = Source(
  name: "YoMovies",
  baseUrl: "https://yomovies.boo",
  lang: "hi",
  typeSource: "single",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/anime/src/hi/yomovies/icon.png",
  sourceCodeUrl: _yomoviesSourceCodeUrl,
  version: _yomoviesVersion,
  itemType: ItemType.anime,
);

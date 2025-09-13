import '../../../../../model/source.dart';

const _animeworldindiaVersion = "0.0.35";
const _animeworldindiaSourceCodeUrl =
    "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/anime/src/all/animeworldindia/animeworldindia.dart";

String _iconUrl =
    "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/anime/src/all/animeworldindia/icon.png";

List<String> _languages = [
  "all",
  "en",
  "bn",
  "hi",
  "ja",
  "ml",
  "mr",
  "ta",
  "te",
];

List<Source> get animeworldindiaSourcesList => _animeworldindiaSourcesList;
List<Source> _animeworldindiaSourcesList = _languages
    .map(
      (e) => Source(
        name: 'AnimeWorld India',
        baseUrl: "https://anime-world.in",
        lang: e,
        typeSource: "multiple",
        iconUrl: _iconUrl,
        version: _animeworldindiaVersion,
        itemType: ItemType.anime,
        sourceCodeUrl: _animeworldindiaSourceCodeUrl,
      ),
    )
    .toList();

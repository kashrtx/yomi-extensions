import '../../../../../model/source.dart';

Source get animesultraSource => _animesultraSource;
const _animesultraVersion = "0.0.8";
const _animesultraSourceCodeUrl =
    "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/anime/src/fr/animesultra/animesultra.dart";
Source _animesultraSource = Source(
  name: "AnimesUltra",
  baseUrl: "https://w2.animesultra.net",
  lang: "fr",
  typeSource: "single",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/anime/src/fr/animesultra/icon.png",
  sourceCodeUrl: _animesultraSourceCodeUrl,
  version: _animesultraVersion,
  itemType: ItemType.anime,
  isFullData: false,
);

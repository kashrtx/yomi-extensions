import '../../../../../model/source.dart';

Source get animeonlineninjaSource => _animeonlineninjaSource;
const _animeonlineninjaVersion = "0.0.35";
const _animeonlineninjaSourceCodeUrl =
    "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/anime/src/es/animeonlineninja/animeonlineninja.dart";
Source _animeonlineninjaSource = Source(
  name: "AnimeOnline.Ninja",
  baseUrl: "https://ww3.animeonline.ninja",
  lang: "es",
  typeSource: "single",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/anime/src/es/animeonlineninja/icon.png",
  sourceCodeUrl: _animeonlineninjaSourceCodeUrl,
  version: _animeonlineninjaVersion,
  itemType: ItemType.anime,
);

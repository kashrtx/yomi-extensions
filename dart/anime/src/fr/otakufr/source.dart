import '../../../../../model/source.dart';

Source get otakufr => _otakufr;
const otakufrVersion = "0.1.0";
const otakufrCodeUrl =
    "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/anime/src/fr/otakufr/otakufr.dart";
Source _otakufr = Source(
  name: "OtakuFr",
  baseUrl: "https://otakufr.cc",
  lang: "fr",
  typeSource: "single",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/anime/src/fr/otakufr/icon.png",
  sourceCodeUrl: otakufrCodeUrl,
  version: otakufrVersion,
  itemType: ItemType.anime,
  isFullData: false,
);

import '../../../../../../model/source.dart';

Source get sflixSource => _sflixSource;

Source _sflixSource = Source(
  name: "SFlix",
  baseUrl: "https://sflix.to",
  lang: "en",
  typeSource: "dopeflix",
  itemType: ItemType.anime,
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/anime/multisrc/dopeflix/src/sflix/icon.png",
);

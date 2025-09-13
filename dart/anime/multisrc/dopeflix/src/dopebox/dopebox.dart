import '../../../../../../model/source.dart';

Source get dopeboxSource => _dopeboxSource;

Source _dopeboxSource = Source(
  name: "DopeBox",
  baseUrl: "https://dopebox.to",
  lang: "en",
  typeSource: "dopeflix",
  itemType: ItemType.anime,
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/anime/multisrc/dopeflix/src/dopebox/icon.png",
);

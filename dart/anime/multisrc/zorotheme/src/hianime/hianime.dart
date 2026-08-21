import '../../../../../../model/source.dart';

Source get aniwatchSource => _aniwatchSource;

Source _aniwatchSource = Source(
  id: 814067600,
  name: "HiAnime",
  baseUrl: "https://hianime.to",
  itemType: ItemType.anime,
  lang: "en",
  typeSource: "zorotheme",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/anime/multisrc/zorotheme/src/hianime/icon.png",
  // hianime.to went offline on 2026-03-13 and the shutdown was treated as
  // permanent on 2026-05-31. There is no official successor domain: the
  // lookalikes that appeared afterwards are unaffiliated clones with
  // different page structures, so repointing baseUrl at one of them would
  // not make this source work. Left as-is and flagged for the user instead.
  notes:
      "This source is no longer available. HiAnime (formerly Zoro.to / "
      "Aniwatch.to) shut down permanently in 2026 and has no official "
      "replacement domain. Use a different source.",
);

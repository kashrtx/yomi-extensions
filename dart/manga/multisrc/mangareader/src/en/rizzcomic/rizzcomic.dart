import '../../../../../../../model/source.dart';

Source get rizzcomicSource => _rizzcomicSource;
Source _rizzcomicSource = Source(
  name: "Rizz Comic",
  baseUrl: "https://rizzfables.com",
  lang: "en",
  isNsfw: false,
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/en/rizzcomic/icon.png",
  dateFormat: "dd MMM yyyy",
  dateFormatLocale: "en",
);

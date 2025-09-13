import '../../../../../../../model/source.dart';

Source get mangareadorgSource => _mangareadorgSource;

Source _mangareadorgSource = Source(
  name: "MangaRead.org",
  baseUrl: "https://www.mangaread.org",
  lang: "en",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/madara/src/en/mangareadorg/icon.png",
  dateFormat: "dd.MM.yyy",
  dateFormatLocale: "en_us",
);

import '../../../../../../../model/source.dart';

Source get barmangaSource => _barmangaSource;

Source _barmangaSource = Source(
  name: "BarManga",
  baseUrl: "https://archiviumbar.com",
  lang: "es",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/madara/src/es/barmanga/icon.png",
  dateFormat: "MM/dd/yyyy",
  dateFormatLocale: "es",
);

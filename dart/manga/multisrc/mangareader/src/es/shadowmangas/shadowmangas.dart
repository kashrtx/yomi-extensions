import '../../../../../../../model/source.dart';

Source get shadowmangasSource => _shadowmangasSource;

Source _shadowmangasSource = Source(
  name: "Shadow Mangas",
  baseUrl: "https://shadowmangas.com",
  lang: "es",
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/es/shadowmangas/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "es",
);

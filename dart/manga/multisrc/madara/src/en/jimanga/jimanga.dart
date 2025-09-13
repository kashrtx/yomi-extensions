import '../../../../../../../model/source.dart';

Source get jimangaSource => _jimangaSource;

Source _jimangaSource = Source(
  name: "Jimanga",
  baseUrl: "https://jimanga.com",
  lang: "en",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/madara/src/en/jimanga/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "en_us",
);

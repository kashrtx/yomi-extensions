import '../../../../../../../model/source.dart';

Source get manhwaclanSource => _manhwaclanSource;

Source _manhwaclanSource = Source(
  name: "ManhwaClan",
  baseUrl: "https://manhwaclan.com",
  lang: "en",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/madara/src/en/manhwaclan/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "en_us",
);

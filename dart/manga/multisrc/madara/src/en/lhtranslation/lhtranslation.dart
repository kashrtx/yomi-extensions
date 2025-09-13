import '../../../../../../../model/source.dart';

Source get lhtranslationSource => _lhtranslationSource;

Source _lhtranslationSource = Source(
  name: "LHTranslation",
  baseUrl: "https://lhtranslation.net",
  lang: "en",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/madara/src/en/lhtranslation/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "en_us",
);

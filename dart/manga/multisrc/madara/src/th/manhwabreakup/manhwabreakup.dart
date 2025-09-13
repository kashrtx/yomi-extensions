import '../../../../../../../model/source.dart';

Source get manhwabreakupSource => _manhwabreakupSource;
Source _manhwabreakupSource = Source(
  name: "ManhwaBreakup",
  baseUrl: "https://www.manhwabreakup.com",
  lang: "th",
  isNsfw: false,
  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/main/dart/manga/multisrc/madara/src/th/manhwabreakup/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "th",
);

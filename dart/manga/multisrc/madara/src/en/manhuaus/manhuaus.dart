import '../../../../../../../model/source.dart';

Source get manhuausSource => _manhuausSource;

Source _manhuausSource = Source(
  name: "ManhuaUS",
  baseUrl: "https://manhuaus.com",
  lang: "en",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/madara/src/en/manhuaus/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "en_us",
);

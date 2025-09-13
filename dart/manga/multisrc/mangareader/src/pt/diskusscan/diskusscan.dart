import '../../../../../../../model/source.dart';

Source get diskusscanSource => _diskusscanSource;
Source _diskusscanSource = Source(
  name: "Diskus Scan",
  baseUrl: "https://diskusscan.com",
  lang: "pt-br",
  isNsfw: false,
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/pt/diskusscan/icon.png",
  dateFormat: "MMMMM dd, yyyy",
  dateFormatLocale: "pt-br",
);

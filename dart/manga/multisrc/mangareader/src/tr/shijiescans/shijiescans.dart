import '../../../../../../../model/source.dart';

Source get shijiescansSource => _shijiescansSource;
Source _shijiescansSource = Source(
  name: "Shijie Scans",
  baseUrl: "https://shijiescans.com",
  lang: "tr",
  isNsfw: false,
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/tr/shijiescans/icon.png",
  dateFormat: "MMM d, yyy",
  dateFormatLocale: "tr",
);

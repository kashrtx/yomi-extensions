import '../../../../../../../model/source.dart';

Source get thunderscansSource => _thunderscansSource;
Source _thunderscansSource = Source(
  name: "Thunder Scans",
  baseUrl: "https://ar-thunderepic.com",
  lang: "all",
  isNsfw: false,
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/all/thunderscans/icon.png",
  dateFormat: "MMM d, yyy",
  dateFormatLocale: "ar",
);

import '../../../../../../../model/source.dart';

Source get kiryuuSource => _kiryuuSource;
Source _kiryuuSource = Source(
  name: "Kiryuu",
  baseUrl: "https://kiryuu.id",
  lang: "id",
  isNsfw: false,
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/id/kiryuu/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "id",
);

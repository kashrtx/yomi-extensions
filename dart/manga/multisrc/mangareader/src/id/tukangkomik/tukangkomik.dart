import '../../../../../../../model/source.dart';

Source get tukangkomikSource => _tukangkomikSource;

Source _tukangkomikSource = Source(
  name: "TukangKomik",
  baseUrl: "https://tukangkomik.id",
  lang: "id",
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/id/tukangkomik/icon.png",
  dateFormat: "MMM d, yyyy",
  dateFormatLocale: "tr",
);

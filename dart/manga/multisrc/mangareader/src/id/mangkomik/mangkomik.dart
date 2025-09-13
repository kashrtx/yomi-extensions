import '../../../../../../../model/source.dart';

Source get mangkomikSource => _mangkomikSource;
Source _mangkomikSource = Source(
  name: "Siren Komik",
  baseUrl: "https://sirenkomik.my.id",
  lang: "id",
  isNsfw: false,
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/id/mangkomik/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "id",
);

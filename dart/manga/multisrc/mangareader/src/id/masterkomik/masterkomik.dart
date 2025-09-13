import '../../../../../../../model/source.dart';

Source get masterkomikSource => _masterkomikSource;
Source _masterkomikSource = Source(
  name: "Tenshi.id",
  baseUrl: "https://tenshi.id",
  lang: "id",
  isNsfw: false,
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/id/masterkomik/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "id-id",
);

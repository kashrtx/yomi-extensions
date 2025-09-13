import '../../../../../../../model/source.dart';

Source get katakomikSource => _katakomikSource;

Source _katakomikSource = Source(
  name: "KataKomik",
  baseUrl: "https://katakomik.online",
  lang: "id",
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/id/katakomik/icon.png",
  dateFormat: "MMMM dd, yyyy",
  dateFormatLocale: "en_us",
);

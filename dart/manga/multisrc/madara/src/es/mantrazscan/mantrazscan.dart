import '../../../../../../../model/source.dart';

Source get mantrazscanSource => _mantrazscanSource;

Source _mantrazscanSource = Source(
  name: "Mantraz Scan",
  baseUrl: "https://mantrazscan.com",
  lang: "es",

  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/$branchName/dart/manga/multisrc/madara/src/es/mantrazscan/icon.png",
  dateFormat: "dd/MM/yyyy",
  dateFormatLocale: "es",
);

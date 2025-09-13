import '../../../../../../../model/source.dart';

Source get pmscansSource => _pmscansSource;
Source _pmscansSource = Source(
  name: "PMScans",
  baseUrl: "https://rackusreads.com",
  lang: "en",
  isNsfw: false,
  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/main/dart/manga/multisrc/madara/src/en/pmscans/icon.png",
  dateFormat: "dd/MM/yyyy",
  dateFormatLocale: "en",
);

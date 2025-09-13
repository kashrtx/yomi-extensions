import '../../../../../../../model/source.dart';

Source get readmanhuaSource => _readmanhuaSource;
Source _readmanhuaSource = Source(
  name: "ReadManhua",
  baseUrl: "https://readmanhua.net",
  lang: "en",
  isNsfw: false,
  typeSource: "madara",
  iconUrl:
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/main/dart/manga/multisrc/madara/src/en/readmanhua/icon.png",
  dateFormat: "dd MMM yyyy",
  dateFormatLocale: "en_us",
);

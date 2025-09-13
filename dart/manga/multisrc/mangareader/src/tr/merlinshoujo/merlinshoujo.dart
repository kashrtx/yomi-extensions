import '../../../../../../../model/source.dart';

Source get merlinshoujoSource => _merlinshoujoSource;
Source _merlinshoujoSource = Source(
  name: "Merlin Shoujo",
  baseUrl: "https://merlinshoujo.com",
  lang: "tr",
  isNsfw: false,
  typeSource: "mangareader",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/manga/multisrc/mangareader/src/tr/merlinshoujo/icon.png",
  dateFormat: "MMMM d, yyy",
  dateFormatLocale: "tr",
);

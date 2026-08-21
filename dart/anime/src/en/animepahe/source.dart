import '../../../../../model/source.dart';

Source get animepaheSource => _animepaheSource;

// 0.1.0 - Cloudflare + current-markup overhaul (Aug 2026):
//   * bind the HTTP client to the source so the app's cf_clearance cookie is
//     actually attached to requests (was a bare `Client()`)
//   * hasCloudflare: true so the app runs its WebView challenge solver
//   * drop the stale hardcoded DDoS-Guard cookie header that was clobbering
//     cf_clearance on every request
//   * default domain -> www.animepahe.pw, animepahe.com as backup, with
//     automatic failover across the officially listed domains
//   * rewrite detail-page parsing: the site moved every info label inside
//     <strong> and renamed "Studio:" to "Studios:", so the old xpaths for
//     status/studio/synonyms matched nothing, and the genre xpath read
//     <li>/text() instead of <li>/<a>/text()
//   * audio: read data-audio properly and support jpn/eng/chi/kor, not just
//     an (also miscased) sub/dub guess
//   * readable errors instead of a bare FormatException on challenge pages
const _animepaheVersion = "0.1.0";
const _animepaheSourceCodeUrl =
    "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/anime/src/en/animepahe/animepahe.dart";
Source _animepaheSource = Source(
  name: "AnimePahe",
  // Domain history: www.animepahe.ru -> animepahe.si -> animepahe.com -> .pw
  // The site's own header banner lists exactly three legitimate domains:
  // animepahe.pw, animepahe.com, animepahe.org. Assets come from i.animepahe.pw.
  baseUrl: "https://www.animepahe.pw", // current, as of Aug 2026
  lang: "en",
  typeSource: "single",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/anime/src/en/animepahe/icon.png",
  sourceCodeUrl: _animepaheSourceCodeUrl,
  version: _animepaheVersion,
  itemType: ItemType.anime,
  // The site sits behind a Cloudflare managed challenge. This flag is what
  // tells the app to solve it in a WebView and reuse the cf_clearance cookie;
  // without it the extension only ever sees challenge HTML.
  hasCloudflare: true,
  notes:
      "Cloudflare-protected. If content fails to load, open the source in the "
      "app's WebView once to clear the challenge. Default domain is "
      "www.animepahe.pw; switch to animepahe.com in settings if it is down. "
      "Some titles carry Chinese or Korean audio as well as Japanese and "
      "English - set 'Preferred audio' in the source settings.",
);

import '../../../../../model/source.dart';

Source get animepaheSource => _animepaheSource;

// 0.1.3 - fixes "UnimplementedError: Type de stringliteral non gere:
// StringInterpolationImpl". The interpreter that runs these files does not
// support adjacent string literals (implicit concatenation across lines) when
// one part contains $ interpolation. 0.1.2 had three of those in throw
// statements. Zero of the other 300+ extensions in this repo use that shape -
// which is the tell I should have checked before writing it.
//
// Also swapped three other constructs that had no precedent anywhere in this
// repo, on the same reasoning:
//   static const int      -> plain int literals (only static const String is used)
//   encodeQueryComponent  -> Uri.encodeComponent (10 uses vs 0)
//   "$v".trim()           -> v.toString().trim() (.toString() has 55 uses)
//   throw (variable)      -> throw ("plain literal"), the only proven form
//
// 0.1.2 - rebuilt from the 0.0.84 baseline. The 0.1.0/0.1.1 mirror-failover
// chain and retry loop are gone: the app's Cloudflare bypass blocks the
// calling thread in a WebView while it solves, and this file is called once
// per episode page, so multiplying requests stacked into a frozen UI that
// Android killed as an ANR. Request count is now BELOW the original (4 vs 7).
//
// Cloudflare handling follows the cloudflare_bypass package (which is itself a
// port of Kotatsu's implementation). The package can't be imported here -
// extensions are interpreted source with no pub dependencies - but its logic
// is portable, and it flagged a real mistake: X-Requested-With is on its
// blocked-header list for CF bypass, and an earlier revision of this file
// added it.
//
// Changes vs 0.0.84:
//   * Client(source), not Client() - a bare client has no source cookie jar,
//     so cf_clearance was never sent
//   * dropped the hardcoded '__ddg1_=;__ddg2_=;' cookie header, which set
//     empty DDoS-Guard cookies AND replaced the whole Cookie header
//   * browser header set per CommonHeadersInterceptor; no X-Requested-With,
//     no Sec-CH-UA client hints
//   * CloudFlareHelper-style detection: only 403/503 counts, and a blocked IP
//     is reported differently from a solvable challenge
//   * default domain www.animepahe.pw (backup animepahe.com); pref key bumped
//     so the new default applies to existing installs
//   * detail page: labels moved into <strong>, "Studio:" -> "Studios:",
//     genres are in <li><a> - all three matched nothing before
//   * audio: jpn/eng/chi/kor from data-audio
//   * kwik: `if (tries > 19)` threw even on a successful final-attempt 302
//   * search: URL-encoded query, l=8 cap removed
const _animepaheVersion = "0.1.3";
const _animepaheSourceCodeUrl =
    "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/anime/src/en/animepahe/animepahe.dart";
Source _animepaheSource = Source(
  name: "AnimePahe",
  // Site banner lists exactly three legit domains: .pw, .com, .org.
  // Assets are served from i.animepahe.pw.
  baseUrl: "https://www.animepahe.pw",
  lang: "en",
  typeSource: "single",
  iconUrl:
      "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/anime/src/en/animepahe/icon.png",
  sourceCodeUrl: _animepaheSourceCodeUrl,
  version: _animepaheVersion,
  itemType: ItemType.anime,
  // FALSE on purpose - back to the original value. Setting this true is what
  // produced the repeating challenge prompt, and the app's blocking WebView
  // solve is what turned that into a freeze. With it false the extension still
  // uses any cf_clearance already in the cookie jar, so clearing the challenge
  // once by hand in the WebView is enough, with no prompt and no blocking.
  hasCloudflare: false,
  notes:
      "If content does not load, open this source in the app's WebView (globe "
      "icon) once and wait for the real site to appear - that stores the "
      "Cloudflare cookie for the whole app. Default domain is "
      "www.animepahe.pw; switch to animepahe.com in settings if it is down. "
      "Some titles have Chinese or Korean audio as well as Japanese and "
      "English; set 'Preferred audio'.",
);

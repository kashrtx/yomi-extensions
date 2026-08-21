import 'package:mangayomi/bridge_lib.dart';
import 'dart:convert';
import 'dart:math';

class AnimePahe extends MProvider {
  AnimePahe(this.source);

  final MSource source;

  // The client MUST be bound to `source`.
  //
  // The old code used a bare `Client()`, which gets no source-scoped cookie
  // jar. That means the `cf_clearance` cookie the app obtains through its
  // WebView Cloudflare bypass was never attached to our requests, so every
  // single call (home, search, detail, watch) came back as a challenge page
  // instead of JSON. This one-word change is the core of the Cloudflare fix.
  final Client client = Client(source);

  // Live domain as of Aug 2026. AnimePahe has bounced
  // .ru -> .si -> .com -> .pw over the past year.
  static const String fallbackDomain = "https://www.animepahe.pw";

  // Preference keys are version-suffixed on purpose. The app persists the
  // previously selected value, so without a new key an existing install
  // would keep using the stale domain it saved months ago and the new
  // default would never take effect.
  static const String domainKey = "preferred_domain_v3";
  static const String overrideKey = "override_baseurl_v3";
  static const String mirrorKey = "auto_mirror_fallback_v3";
  static const String hlsKey = "preferred_link_type_v3";
  static const String qualityKey = "preferred_quality_v3";
  static const String audioKey = "preferred_audio_v3";
  static const String uaKey = "custom_user_agent_v3";

  // Ordered mirror list used for automatic failover.
  //
  // The site's own header banner names exactly three legitimate domains:
  // animepahe.pw, animepahe.com and animepahe.org. .si and .ru are dropped -
  // they are retired, and leaving them in the chain just burns a request each
  // on every failure before reaching a domain that can actually answer.
  // Static assets confirm the active host: posters and snapshots are served
  // from i.animepahe.pw.
  List<String> get knownDomains => [
    "https://www.animepahe.pw",
    "https://animepahe.com",
    "https://animepahe.pw",
    "https://animepahe.org",
  ];

  @override
  String get baseUrl {
    final override = _pref(overrideKey);
    if (override.isNotEmpty) {
      return _trimSlash(override);
    }
    final selected = _pref(domainKey);
    if (selected.isNotEmpty) {
      return _trimSlash(selected);
    }
    return fallbackDomain;
  }

  // Deliberately does NOT set a User-Agent or a Cookie header.
  //
  // Cloudflare binds a `cf_clearance` cookie to the exact User-Agent that
  // solved the challenge. The app's WebView solves it with the app's UA, so
  // if the extension forces a different UA here the cookie is rejected and
  // you get an endless challenge loop. Letting the app fill in the UA keeps
  // the two in sync. Same reasoning for Cookie: the old hardcoded
  // `cookie: __ddg1_=;__ddg2_=;` (a leftover from when the site used
  // DDoS-Guard rather than Cloudflare) overwrote the whole Cookie header and
  // wiped out cf_clearance on every request.
  @override
  Map<String, String> get headers => _pageHeaders();

  String _pref(String key) {
    try {
      final value = getPreferenceValue(source.id, key);
      if (value == null) {
        return "";
      }
      return value.toString().trim();
    } catch (_) {
      return "";
    }
  }

  bool _prefBool(String key, bool fallback) {
    try {
      final value = getPreferenceValue(source.id, key);
      if (value == null) {
        return fallback;
      }
      if (value == true || value == "true") {
        return true;
      }
      if (value == false || value == "false") {
        return false;
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  String _trimSlash(String url) {
    var out = url.trim();
    while (out.endsWith("/")) {
      out = out.substring(0, out.length - 1);
    }
    return out;
  }

  Map<String, String> _baseHeaders(String referer) {
    Map<String, String> h = {
      "Accept-Language": "en-US,en;q=0.9",
      "Cache-Control": "no-cache",
      "Pragma": "no-cache",
    };
    if (referer.isNotEmpty) {
      h["Referer"] = "$referer/";
      h["Origin"] = referer;
    }
    final ua = _pref(uaKey);
    if (ua.isNotEmpty) {
      h["User-Agent"] = ua;
    }
    return h;
  }

  // Headers for normal document loads (/anime/..., /play/...).
  Map<String, String> _pageHeaders() {
    Map<String, String> h = _baseHeaders(baseUrl);
    h["Accept"] =
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8";
    h["Sec-Fetch-Dest"] = "document";
    h["Sec-Fetch-Mode"] = "navigate";
    h["Sec-Fetch-Site"] = "same-origin";
    h["Upgrade-Insecure-Requests"] = "1";
    return h;
  }

  // Headers for the /api AJAX endpoint. Without X-Requested-With the endpoint
  // is far more likely to be served a challenge page rather than JSON.
  Map<String, String> _apiHeaders(String referer) {
    Map<String, String> h = _baseHeaders(referer);
    h["Accept"] = "application/json, text/javascript, */*; q=0.01";
    h["X-Requested-With"] = "XMLHttpRequest";
    h["Sec-Fetch-Dest"] = "empty";
    h["Sec-Fetch-Mode"] = "cors";
    h["Sec-Fetch-Site"] = "same-origin";
    return h;
  }

  // Domains to try, active one first.
  List<String> _domainChain() {
    List<String> chain = [baseUrl];
    if (_prefBool(mirrorKey, true)) {
      for (var domain in knownDomains) {
        final normalised = _trimSlash(domain);
        if (!chain.contains(normalised)) {
          chain.add(normalised);
        }
      }
    }
    return chain;
  }

  bool _looksLikeChallenge(int code, String body) {
    if (code == 403 || code == 503 || code == 429) {
      return true;
    }
    final b = body.toLowerCase();
    return b.contains("just a moment") ||
        b.contains("cdn-cgi/challenge-platform") ||
        b.contains("cf-browser-verification") ||
        b.contains("cf_chl_opt") ||
        b.contains("attention required") ||
        b.contains("enable javascript and cookies to continue") ||
        b.contains("checking your browser") ||
        b.contains("ddos-guard");
  }

  bool _looksLikeJson(String body) {
    final b = body.trim();
    if (b.isEmpty) {
      return false;
    }
    return b.startsWith("{") || b.startsWith("[");
  }

  String _challengeMessage(String domain) {
    return "AnimePahe is behind a Cloudflare challenge on $domain.\n\n"
        "Open this source in the app's WebView (the globe icon on the browse "
        "screen), let the check finish once, then come back and retry. If it "
        "keeps looping, switch 'Preferred domain' in the source settings to "
        "animepahe.com.";
  }

  // Fetches a path, walking the mirror list until one returns real JSON.
  // Distinguishes "blocked by Cloudflare" from "wrong domain" so the error
  // shown in the app is actionable instead of a bare FormatException.
  Future<dynamic> _getJson(String path) async {
    final chain = _domainChain();
    String lastError = "";
    bool sawChallenge = false;
    String challengeDomain = "";

    for (var domain in chain) {
      try {
        final res = await client.get(
          Uri.parse("$domain$path"),
          headers: _apiHeaders(domain),
        );
        final body = res.body;
        if (_looksLikeChallenge(res.statusCode, body)) {
          sawChallenge = true;
          if (challengeDomain.isEmpty) {
            challengeDomain = domain;
          }
          continue;
        }
        if (!_looksLikeJson(body)) {
          lastError = "$domain returned a non-JSON response.";
          continue;
        }
        return json.decode(body);
      } catch (e) {
        lastError = "$domain failed: $e";
      }
    }

    if (sawChallenge) {
      throw (_challengeMessage(challengeDomain));
    }
    throw ("Could not reach AnimePahe on any known domain.\n\n"
        "Tried: ${chain.join(", ")}\n$lastError");
  }

  // Same failover logic, but for HTML pages.
  Future<String> _getHtml(String path) async {
    final chain = _domainChain();
    String lastError = "";
    bool sawChallenge = false;
    String challengeDomain = "";

    for (var domain in chain) {
      try {
        final res = await client.get(
          Uri.parse("$domain$path"),
          headers: _pageHeaders(),
        );
        final body = res.body;
        if (_looksLikeChallenge(res.statusCode, body)) {
          sawChallenge = true;
          if (challengeDomain.isEmpty) {
            challengeDomain = domain;
          }
          continue;
        }
        if (body.trim().isEmpty) {
          lastError = "$domain returned an empty page.";
          continue;
        }
        return body;
      } catch (e) {
        lastError = "$domain failed: $e";
      }
    }

    if (sawChallenge) {
      throw (_challengeMessage(challengeDomain));
    }
    throw ("Could not load $path from AnimePahe.\n\n"
        "Tried: ${chain.join(", ")}\n$lastError");
  }

  int _asInt(dynamic value, int fallback) {
    if (value == null) {
      return fallback;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString()) ?? fallback;
  }

  @override
  Future<MPages> getPopular(int page) async {
    return await getLatestUpdates(page);
  }

  @override
  Future<MPages> getLatestUpdates(int page) async {
    final jsonResult = await _getJson("/api?m=airing&page=$page");
    final currentPage = _asInt(jsonResult["current_page"], page);
    final lastPage = _asInt(jsonResult["last_page"], currentPage);
    final hasNextPage = currentPage < lastPage;

    List<MManga> animeList = [];
    final data = jsonResult["data"];
    if (data != null) {
      for (var item in data) {
        MManga anime = MManga();
        anime.name = item["anime_title"] ?? item["title"] ?? "";
        anime.imageUrl = item["snapshot"] ?? item["poster"] ?? "";
        // Link format is intentionally unchanged so existing library
        // entries keep resolving after the update.
        anime.link =
            "/anime/?anime_id=${item["anime_id"] ?? item["id"]}&name=${anime.name}";
        anime.artist = item["fansub"] ?? "";
        animeList.add(anime);
      }
    }
    return MPages(animeList, hasNextPage);
  }

  @override
  Future<MPages> search(String query, int page, FilterList filterList) async {
    // The old code dropped the query straight into the URL, so anything with
    // a space or an ampersand produced a malformed request, and l=8 capped
    // results at eight even though the endpoint returns more.
    final encoded = Uri.encodeQueryComponent(query.trim());
    if (encoded.isEmpty) {
      return MPages([], false);
    }
    final jsonResult = await _getJson("/api?m=search&q=$encoded");

    List<MManga> animeList = [];
    final data = jsonResult["data"];
    if (data != null) {
      for (var item in data) {
        MManga anime = MManga();
        anime.name = item["title"] ?? "";
        anime.imageUrl = item["poster"] ?? "";
        anime.link = "/anime/?anime_id=${item["id"]}&name=${anime.name}";
        animeList.add(anime);
      }
    }
    // Search is a single fixed result set on this endpoint.
    return MPages(animeList, false);
  }

  // Reads a labelled field out of the info column.
  //
  // The old xpaths (`//div/p[contains(text(),"Status:")]/text()`) no longer
  // match anything: the site wraps every label in <strong>, so "Status:" is
  // not a direct text node of the <p>. It also renamed "Studio:" to
  // "Studios:". Matching on the paragraph's full text is both correct against
  // the current markup and resilient to the label moving between tags again.
  String _infoField(dynamic document, String label) {
    for (var p in document.select("div.anime-info p")) {
      final text = p.text.replaceAll(RegExp(r"\s+"), " ").trim();
      if (text.toLowerCase().startsWith(label.toLowerCase())) {
        return text.substring(label.length).trim();
      }
    }
    return "";
  }

  List<String> _splitList(String value) {
    List<String> out = [];
    for (var part in value.split(",")) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty) {
        out.add(trimmed);
      }
    }
    return out;
  }

  @override
  Future<MManga> getDetail(String url) async {
    final statusList = [
      {"Currently Airing": 0, "Finished Airing": 1},
    ];
    MManga anime = MManga();

    final id = substringBefore(substringAfterLast(url, "?anime_id="), "&name=");
    final name = substringAfterLast(url, "&name=");
    final session = await getSession(name, id);
    if (session.isEmpty) {
      throw ("Could not resolve the AnimePahe session id for this title. "
          "It may have been removed, or the site changed its URL scheme.");
    }

    final res = await _getHtml("/anime/$session?anime_id=$id");
    final document = parseHtml(res);

    anime.status = parseStatus(_infoField(document, "Status:"), statusList);

    // Guarded because a challenge page or a layout change would otherwise
    // throw a null error here rather than a readable message.
    final titleNode = document.selectFirst("div.title-wrapper > h1 > span");
    if (titleNode != null) {
      anime.name = titleNode.text.trim();
    } else {
      anime.name = name;
    }

    // "Studios:" - plural on the current site.
    anime.author = _infoField(document, "Studios:");
    if (anime.author.isEmpty) {
      anime.author = _infoField(document, "Studio:");
    }

    final posterNode = document.selectFirst("div.anime-poster a");
    if (posterNode != null) {
      anime.imageUrl = posterNode.attr("href");
    }

    // Genres live inside <li><a>...</a></li>, so the old `li/text()` xpath
    // only ever returned whitespace. Themes and the demographic are
    // genre-shaped too, so they get folded in.
    List<String> genres = [];
    for (var a in document.select("div.anime-genre ul li a")) {
      final g = a.text.trim();
      if (g.isNotEmpty && !genres.contains(g)) {
        genres.add(g);
      }
    }
    for (var extra in _splitList(_infoField(document, "Themes:"))) {
      if (!genres.contains(extra)) {
        genres.add(extra);
      }
    }
    for (var extra in _splitList(_infoField(document, "Demographic:"))) {
      if (!genres.contains(extra)) {
        genres.add(extra);
      }
    }
    anime.genre = genres;

    final summaryNode = document.selectFirst("div.anime-synopsis");
    anime.description = summaryNode != null ? summaryNode.text.trim() : "";

    List<String> extras = [];
    final japaneseNode = document.selectFirst("h2.japanese");
    if (japaneseNode != null && japaneseNode.text.trim().isNotEmpty) {
      extras.add("Japanese: ${japaneseNode.text.trim()}");
    }
    for (var label in ["Synonyms:", "Type:", "Episodes:", "Aired:", "Season:"]) {
      final value = _infoField(document, label);
      if (value.isNotEmpty) {
        extras.add("$label $value");
      }
    }
    if (extras.isNotEmpty) {
      if (anime.description.isNotEmpty) {
        anime.description += "\n\n";
      }
      anime.description += extras.join("\n");
    }

    anime.chapters = await _fetchEpisodes(session);
    return anime;
  }

  // Rewritten from the old recursive version, which declared a
  // List<MManga> and then pushed MChapter objects into it, and could recurse
  // without bound if the API reported a bogus last_page.
  Future<List<MChapter>> _fetchEpisodes(String session) async {
    List<MChapter> episodes = [];
    int page = 1;
    int lastPage = 1;

    while (page <= lastPage && page <= 200) {
      final jsonResult = await _getJson(
        "/api?m=release&id=$session&sort=episode_desc&page=$page",
      );
      lastPage = _asInt(jsonResult["last_page"], page);
      final data = jsonResult["data"];
      if (data == null) {
        break;
      }
      for (var item in data) {
        MChapter episode = MChapter();
        episode.name = "Episode ${item["episode"]}";
        episode.url = "/play/$session/${item["session"]}";
        final createdAt = item["created_at"];
        if (createdAt != null) {
          try {
            episode.dateUpload = parseDates(
              ["$createdAt"],
              "yyyy-MM-dd HH:mm:ss",
              "en",
            )[0];
          } catch (_) {
            // A bad timestamp shouldn't cost us the whole episode list.
          }
        }
        episodes.add(episode);
      }
      page++;
    }
    return episodes;
  }

  // Resolve the anime's session id.
  //
  // Order is reversed from the old code: the search API is tried first because
  // it's a plain JSON call that flows through the same Cloudflare-aware path
  // as everything else. The /a/<id> redirect trick needs a no-redirect client
  // and raw header parsing, which is far more fragile, so it's now the
  // fallback rather than the primary route.
  Future<String> getSession(String title, String animeId) async {
    try {
      final encoded = Uri.encodeQueryComponent(title);
      final jsonResult = await _getJson("/api?m=search&q=$encoded");
      final data = jsonResult["data"];
      if (data != null) {
        for (var item in data) {
          if ("${item["id"]}" == animeId) {
            final session = item["session"];
            if (session != null && "$session".isNotEmpty) {
              return "$session";
            }
          }
        }
        // Exact id didn't match (the search index sometimes lags), so fall
        // back to an exact title match before giving up on this route.
        for (var item in data) {
          if ("${item["title"]}".toLowerCase() == title.toLowerCase()) {
            final session = item["session"];
            if (session != null && "$session".isNotEmpty) {
              return "$session";
            }
          }
        }
      }
    } catch (_) {
      // Fall through to the redirect method.
    }

    try {
      final noRedirect = Client(
        source,
        json.encode({"followRedirects": false, "useDartHttpClient": true}),
      );
      for (var domain in _domainChain()) {
        final res = await noRedirect.get(
          Uri.parse("$domain/a/$animeId"),
          headers: _pageHeaders(),
        );
        final location = getMapValue(json.encode(res.headers), "location");
        if (location == null || "$location".isEmpty) {
          continue;
        }
        final loc = _trimSlash("$location");
        // /anime means "not found" - the site bounced us to the index.
        if (loc.endsWith("/anime")) {
          continue;
        }
        final session = substringAfterLast(loc, "/");
        if (session.isNotEmpty && session != "anime") {
          return session;
        }
      }
    } catch (_) {
      // Both routes exhausted.
    }

    return "";
  }

  // data-audio carries an ISO-639-2 code. The site ships more than sub/dub:
  // jpn, eng, chi and kor all appear in the wild, and Japanese is the only
  // one with NO badge in the button text.
  //
  // That absence is why the old "Preferred Audio" setting never worked. Its
  // entryValues were ["jpn", "Eng"], but the badge text is lowercase "eng"
  // (wrong case) and "jpn" appears nowhere at all, so neither value could
  // ever match. Reading data-audio and building the label ourselves fixes
  // both halves.
  String _audioName(String code) {
    final c = code.toLowerCase().trim();
    if (c.isEmpty || c == "jpn" || c == "jpa") return "Japanese";
    if (c == "eng") return "English";
    if (c == "chi" || c == "zho") return "Chinese";
    if (c == "kor") return "Korean";
    if (c == "spa") return "Spanish";
    if (c == "por") return "Portuguese";
    if (c == "fre" || c == "fra") return "French";
    if (c == "ger" || c == "deu") return "German";
    if (c == "ita") return "Italian";
    if (c == "ara") return "Arabic";
    if (c == "tha") return "Thai";
    if (c == "vie") return "Vietnamese";
    if (c == "ind") return "Indonesian";
    if (c == "rus") return "Russian";
    return code.toUpperCase();
  }

  // Recovers the audio code from a download-link label such as
  // "Sylvar - 1080p (222MB) BD chi". The audio badge is always last, so only
  // the final token is inspected - scanning the whole string would false-match
  // language codes hidden inside fansub names. No trailing code means Japanese.
  String _audioCodeFromText(String text) {
    final parts = text.replaceAll(RegExp(r"\s+"), " ").trim().toLowerCase().split(" ");
    if (parts.isEmpty) {
      return "jpn";
    }
    final last = parts[parts.length - 1];
    if (last.length == 3 && RegExp(r"^[a-z]{3}$").hasMatch(last) && last != "av1") {
      return last;
    }
    return "jpn";
  }

  // pickDownload and resolutionMenu are rendered in the same order, so the
  // positional pairing the old code relied on is usually right - but it is an
  // assumption, not a guarantee. Match on (resolution, audio) first and fall
  // back to the index only if nothing matches.
  int _matchDownloadIndex(
    dynamic downloadLinks,
    String resolution,
    String audio,
    int fallbackIndex,
  ) {
    if (resolution.isNotEmpty) {
      for (var i = 0; i < downloadLinks.length; i++) {
        final text = downloadLinks[i].text;
        if (text.contains("${resolution}p") &&
            _audioCodeFromText(text) == audio.toLowerCase()) {
          return i;
        }
      }
    }
    if (fallbackIndex < downloadLinks.length) {
      return fallbackIndex;
    }
    return -1;
  }

  @override
  Future<List<MVideo>> getVideoList(String url) async {
    final res = await _getHtml(url);
    final document = parseHtml(res);
    final downloadLinks = document.select("div#pickDownload > a");
    final buttons = document.select("div#resolutionMenu > button");

    if (buttons.isEmpty) {
      throw ("No streams listed for this episode. If the episode plays in a "
          "browser, the page was most likely served as a Cloudflare challenge "
          "- open the source in the app's WebView once and retry.");
    }

    final useHls = _prefBool(hlsKey, true);
    List<MVideo> videos = [];

    for (var i = 0; i < buttons.length; i++) {
      try {
        final btn = buttons[i];
        final audio = (btn.attr("data-audio") ?? "").toLowerCase();
        final kwikLink = btn.attr("data-src") ?? "";
        if (kwikLink.isEmpty) {
          continue;
        }

        // Built from the data-* attributes rather than btn.text, so the
        // resolution is always a clean "1080p" the quality sort can read and
        // the language is always named even when the badge is absent.
        final fansub = (btn.attr("data-fansub") ?? "").trim();
        final resolution = (btn.attr("data-resolution") ?? "").trim();
        final rawText = btn.text.replaceAll(RegExp(r"\s+"), " ").trim();
        final isBluray = rawText.toUpperCase().contains("BD");

        String quality;
        if (resolution.isNotEmpty) {
          quality = fansub.isNotEmpty ? "$fansub - ${resolution}p" : "${resolution}p";
          if (isBluray) {
            quality += " BD";
          }
          quality += " - ${_audioName(audio)}";
        } else {
          // Attributes missing: fall back to the rendered label.
          quality = "$rawText - ${_audioName(audio)}";
        }

        final kwikUri = Uri.tryParse(kwikLink);
        final kwikReferer =
            kwikUri != null ? "${kwikUri.scheme}://${kwikUri.host}/" : "";

        if (useHls) {
          final dlIndex = _matchDownloadIndex(downloadLinks, resolution, audio, i);
          if (dlIndex < 0) {
            continue;
          }
          final paheWinLink = downloadLinks[dlIndex].attr("href") ?? "";
          if (paheWinLink.isEmpty) {
            continue;
          }
          videos.addAll(
            await _extractHlsVideo(paheWinLink, quality, kwikReferer),
          );
        } else {
          videos.addAll(
            await _extractDirectVideo(kwikLink, quality, kwikReferer),
          );
        }
      } catch (_) {
        // One bad quality option shouldn't blank out the others.
        continue;
      }
    }

    if (videos.isEmpty) {
      throw ("Found ${buttons.length} quality option(s) but could not extract "
          "a playable stream. Try toggling 'Use HLS links' in the source "
          "settings.");
    }
    return sortVideos(videos);
  }

  // Returns 0 or 1 video. A list rather than a nullable MVideo because no
  // extension in this repo returns null from a typed function, and a
  // `Future<MVideo>` that yields null is invalid under null safety.
  Future<List<MVideo>> _extractHlsVideo(
    String paheWinLink,
    String quality,
    String kwikReferer,
  ) async {
    final noRedirectClient = Client(
      source,
      json.encode({"followRedirects": false, "useDartHttpClient": true}),
    );

    // pahe.win 302s to the real kwik page. The old code sent no headers at
    // all on this hop, which the CDN increasingly rejects.
    final firstHop = await noRedirectClient.get(
      Uri.parse("$paheWinLink/i"),
      headers: {"Referer": "$baseUrl/", "Accept": "*/*"},
    );
    final rawLocation = getMapValue(json.encode(firstHop.headers), "location");
    if (rawLocation == null || "$rawLocation".isEmpty) {
      return [];
    }
    final kwikUrl = "$rawLocation";

    final kwikHost = Uri.tryParse(kwikUrl);
    final kwikOrigin =
        kwikHost != null ? "${kwikHost.scheme}://${kwikHost.host}" : "";

    final reskwik = await client.get(
      Uri.parse(kwikUrl),
      headers: {
        "Referer": "$kwikOrigin/",
        "Accept":
            "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      },
    );

    final matches = RegExp(
      r'\("(\S+)",\d+,"(\S+)",(\d+),(\d+)',
    ).firstMatch(reskwik.body);
    if (matches == null) {
      return [];
    }

    final token = decrypt(
      matches.group(1)!,
      matches.group(2)!,
      matches.group(3)!,
      int.parse(matches.group(4)!),
    );
    final actionMatch = RegExp(r'action="([^"]+)"').firstMatch(token);
    final tokenMatch = RegExp(r'value="([^"]+)"').firstMatch(token);
    if (actionMatch == null || tokenMatch == null) {
      return [];
    }
    final postUrl = actionMatch.group(1)!;
    final tok = tokenMatch.group(1)!;

    String cookie = "";
    final setCookie = getMapValue(json.encode(reskwik.headers), "set-cookie");
    if (setCookie != null) {
      cookie = "$setCookie".replaceAll("path=/;", "").trim();
    }

    var code = 0;
    var tries = 0;
    String location = "";

    // Reduced from 20 to 8. Twenty back-to-back POSTs is exactly the burst
    // pattern that gets an IP rate-limited, which made the loop
    // self-defeating on the attempts that mattered.
    while (code != 302 && tries < 8) {
      Map<String, String> postHeaders = {
        "Referer": kwikUrl,
        "Origin": kwikOrigin,
        "Accept":
            "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      };
      if (cookie.isNotEmpty) {
        postHeaders["Cookie"] = cookie;
      }

      final resNo = await Client(
        source,
        json.encode({"followRedirects": false, "useDartHttpClient": true}),
      ).post(Uri.parse(postUrl), headers: postHeaders, body: {"_token": tok});

      code = resNo.statusCode;
      tries++;
      final loc = getMapValue(json.encode(resNo.headers), "location");
      if (loc != null) {
        location = "$loc";
      }
    }

    // The old check was `if (tries > 19) throw`, which fired even when the
    // 302 arrived on the final attempt. Check the actual outcome instead.
    if (code != 302 || location.isEmpty) {
      return [];
    }

    MVideo video = MVideo();
    video
      ..url = location
      ..originalUrl = location
      ..quality = quality
      ..headers = {
        "Referer": kwikReferer.isNotEmpty ? kwikReferer : "$kwikOrigin/",
      };
    return [video];
  }

  // Returns 0 or 1 video, same reasoning as _extractHlsVideo.
  Future<List<MVideo>> _extractDirectVideo(
    String kwikLink,
    String quality,
    String kwikReferer,
  ) async {
    final ress = await client.get(
      Uri.parse(kwikLink),
      headers: {
        "Referer": "$baseUrl/",
        "Accept":
            "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      },
    );

    final scripts = xpath(
      ress.body,
      '//script[contains(text(),"eval(function")]/text()',
    );
    // Used to be `.first` with no guard - an empty list threw and took the
    // whole episode down with it.
    if (scripts.isEmpty) {
      return [];
    }

    final script = substringAfterLast(scripts.first, "eval(function(");
    final unpackedScript = unpackJsAndCombine("eval(function($script");

    final sourceMatch = RegExp(
      r"const\s+source\s*=\s*(?:'([^']+)'|\\'([^\\]+)\\')",
    ).firstMatch(unpackedScript);
    var videoUrl = sourceMatch?.group(1) ?? sourceMatch?.group(2) ?? "";

    if (videoUrl.isEmpty) {
      videoUrl = substringBefore(
        substringAfter(unpackedScript, "const source=\\'"),
        "\\';",
      );
    }
    // Last-resort fallback: pull the playlist URL straight out of the script.
    if (videoUrl.isEmpty) {
      final urlMatch = RegExp(
        r'https?://[^\s"\\]+\.m3u8[^\s"\\]*',
      ).firstMatch(unpackedScript);
      videoUrl = urlMatch?.group(0) ?? "";
    }
    if (videoUrl.isEmpty) {
      return [];
    }

    MVideo video = MVideo();
    video
      ..url = videoUrl
      ..originalUrl = videoUrl
      ..quality = quality
      ..headers = {"Referer": kwikReferer};
    return [video];
  }

  String getString(String ctn, int sep) {
    int b = 10;
    String cm =
        "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/";
    final n = cm.substring(0, b);
    double mx = 0;
    for (var index = 0; index < ctn.length; index++) {
      mx +=
          (int.tryParse(ctn[ctn.length - index - 1], radix: 10) ?? 0.0)
              .toInt() *
          (pow(sep, index));
    }
    var m = '';
    while (mx > 0) {
      m = n[(mx % b).toInt()] + m;
      mx = (mx - (mx % b)) / b;
    }
    return m.isNotEmpty ? m : '0';
  }

  String decrypt(String fS, String key, String v1, int v2) {
    var html = "";
    var i = 0;
    final ld = int.parse(v1);
    while (i < fS.length) {
      var s = "";
      while (fS[i] != key[v2]) {
        s += fS[i];
        i++;
      }
      for (var index = 0; index < key.length; index++) {
        s = s.replaceAll(key[index], index.toString());
      }
      html += String.fromCharCode(int.parse(getString(s, v2)) - ld);
      i++;
    }

    return html;
  }

  List<MVideo> sortVideos(List<MVideo> videos) {
    String quality = _pref(qualityKey);
    if (quality.isEmpty) {
      quality = "1080";
    }
    String preferredAudio = _pref(audioKey);
    if (preferredAudio.isEmpty) {
      preferredAudio = "jpn";
    }
    // Labels carry the language name, so compare against the name.
    final audioNeedle = _audioName(preferredAudio).toLowerCase();

    videos.sort((MVideo a, MVideo b) {
      // Audio language first.
      int audioMatchA = a.quality.toLowerCase().contains(audioNeedle) ? 1 : 0;
      int audioMatchB = b.quality.toLowerCase().contains(audioNeedle) ? 1 : 0;
      if (audioMatchA != audioMatchB) {
        return audioMatchB - audioMatchA;
      }

      // Then the preferred resolution.
      int qualityMatchA = a.quality.contains(quality) ? 1 : 0;
      int qualityMatchB = b.quality.contains(quality) ? 1 : 0;
      if (qualityMatchA != qualityMatchB) {
        return qualityMatchB - qualityMatchA;
      }

      // Then descending resolution.
      final regex = RegExp(r'(\d+)p');
      final matchA = regex.firstMatch(a.quality);
      final matchB = regex.firstMatch(b.quality);
      final int qualityNumA = int.tryParse(matchA?.group(1) ?? '0') ?? 0;
      final int qualityNumB = int.tryParse(matchB?.group(1) ?? '0') ?? 0;
      return qualityNumB - qualityNumA;
    });

    return videos;
  }

  @override
  List<dynamic> getSourcePreferences() {
    return [
      ListPreference(
        key: domainKey,
        title: "Preferred domain",
        summary:
            "www.animepahe.pw is the live domain. animepahe.com is the backup.",
        valueIndex: 0,
        entries: [
          "www.animepahe.pw (default)",
          "animepahe.com (backup)",
          "animepahe.pw",
          "animepahe.org",
        ],
        entryValues: [
          "https://www.animepahe.pw",
          "https://animepahe.com",
          "https://animepahe.pw",
          "https://animepahe.org",
        ],
      ),
      SwitchPreferenceCompat(
        key: mirrorKey,
        title: "Automatic mirror fallback",
        summary:
            "If the preferred domain fails, silently retry the request on the "
            "other known AnimePahe domains.",
        value: true,
      ),
      EditTextPreference(
        key: overrideKey,
        title: "Override base URL",
        summary:
            "Leave empty to use the preferred domain above. For temporary use "
            "when the site moves again - updating the extension clears this.",
        value: "",
        dialogTitle: "Override base URL",
        dialogMessage: "e.g. https://www.animepahe.pw",
        text: "",
      ),
      SwitchPreferenceCompat(
        key: hlsKey,
        title: "Use HLS links",
        summary:
            "Routes through pahe.win instead of scraping the kwik player. "
            "Keep this on if you are having Cloudflare issues.",
        value: true,
      ),
      ListPreference(
        key: qualityKey,
        title: "Preferred quality",
        summary: "",
        valueIndex: 0,
        entries: ["1080p", "720p", "360p"],
        entryValues: ["1080", "720", "360"],
      ),
      ListPreference(
        key: audioKey,
        title: "Preferred audio",
        summary:
            "Releases are tagged jpn / eng / chi / kor. Unmatched languages "
            "still appear in the player, just lower down the list.",
        valueIndex: 0,
        entries: ["Japanese", "English", "Chinese", "Korean"],
        entryValues: ["jpn", "eng", "chi", "kor"],
      ),
      EditTextPreference(
        key: uaKey,
        title: "Custom User-Agent",
        summary:
            "Leave empty (recommended). Cloudflare ties its clearance cookie "
            "to the User-Agent the app's WebView used, so overriding it here "
            "usually causes a challenge loop.",
        value: "",
        dialogTitle: "Custom User-Agent",
        dialogMessage: "Leave empty unless you are debugging.",
        text: "",
      ),
    ];
  }
}

AnimePahe main(MSource source) {
  return AnimePahe(source);
}

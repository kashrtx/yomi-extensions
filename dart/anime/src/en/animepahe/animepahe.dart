import 'package:mangayomi/bridge_lib.dart';
import 'dart:convert';
import 'dart:math';

class AnimePahe extends MProvider {
  AnimePahe(this.source);

  final MSource source;

  // Must pass `source`: a bare Client() gets no source-scoped cookie jar,
  // so any cf_clearance the app holds is never attached to our requests.
  final Client client = Client(source);

  @override
  String get baseUrl {
    final v = getPreferenceValue(source.id, "preferred_domain_v2");
    if (v == null || v.toString().trim().isEmpty) {
      return "https://www.animepahe.pw";
    }
    return v.toString();
  }

  // Header policy taken from cloudflare_bypass's CommonHeadersInterceptor +
  // BlockedHeaders.forCloudFlareBypass (itself ported from Kotatsu).
  //
  // Was: {'cookie': '__ddg1_=;__ddg2_=;'} - which (a) set EMPTY DDoS-Guard
  // cookies for a site that no longer uses DDoS-Guard, and (b) replaced the
  // entire Cookie header, wiping cf_clearance on every single request.
  //
  // Note what is deliberately NOT here: X-Requested-With. That package lists
  // it under blocked-for-CloudFlare-bypass, because on Android the HTTP stack
  // sets it to the app's package name, which is a dead giveaway that the
  // caller is an app and not a browser. Adding it (as an earlier revision of
  // this file did, to look "more like AJAX") invites the challenge it was
  // meant to avoid. Sec-CH-UA client hints are blocked for the same reason.
  @override
  Map<String, String> get headers => {
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
    // brotli omitted on purpose - not decoded reliably here.
    'Accept-Encoding': 'gzip, deflate',
    'Referer': '$baseUrl/',
    'Upgrade-Insecure-Requests': '1',
  };

  // Ported from CloudFlareHelper.checkResponseForProtection.
  //
  // The important detail is the early return: anything that is not 403/503 is
  // NOT protection, no matter what the body contains. An earlier revision of
  // this file scanned the body regardless of status and treated any 403/503/429
  // as a challenge, so ordinary errors and rate limits were misreported as
  // "solve the Cloudflare challenge".
  int _checkProtection(int statusCode, String body) {
    // 0 = none, 1 = challenge, 2 = blocked. Plain ints rather than named
    // static consts: `static const int` has no precedent in this repo and the
    // interpreter here only demonstrably supports `static const String`.
    if (statusCode != 403 && statusCode != 503) {
      return 0;
    }
    if (body.isEmpty) {
      return 0;
    }
    final b = body.toLowerCase();

    if (b.contains('ddos-guard') ||
        b.contains('/.well-known/ddos-guard/') ||
        b.contains('check.ddos-guard.net')) {
      return 1;
    }
    // Blocked is distinct from challenged: no amount of solving fixes a
    // banned IP, so it deserves a different message.
    if (b.contains('data-translate="blocked_why_headline"')) {
      return 2;
    }
    if (b.contains('challenge-error-title') ||
        b.contains('challenge-error-text') ||
        b.contains('challenge-form') ||
        b.contains('cf-turnstile') ||
        b.contains('challenges.cloudflare.com') ||
        b.contains('cdn-cgi/challenge-platform')) {
      return 1;
    }
    if (b.contains('just a moment') && b.contains('enable javascript')) {
      return 1;
    }
    return 0;
  }

  // Single request. No retry loop and no mirror walking: the app's Cloudflare
  // bypass blocks the calling thread in a WebView while it solves, so every
  // extra request risks another multi-second block. Loading a long series
  // already calls this once per episode page; multiplying that is what froze
  // the app before. Let the app's own interceptor do its one solve-and-retry.
  Future<String> _get(String path) async {
    final res = await client.get(Uri.parse("$baseUrl$path"), headers: headers);
    final body = res.body;
    final state = _checkProtection(res.statusCode, body);

    if (state == 2) {
      throw ("Cloudflare has blocked this IP. Solving a challenge will not help - switch network (mobile data or VPN), or pick another domain in the source settings.");
    }
    if (state == 1) {
      throw ("Cloudflare challenge. Open this source in the app's WebView (globe icon), wait for the real site to appear, then close it and retry.");
    }
    if (res.statusCode == 429) {
      throw ("AnimePahe is rate-limiting this device. Wait a minute, then retry.");
    }
    return body;
  }

  Future<dynamic> _getJson(String path) async {
    final body = await _get(path);
    final t = body.trim();
    if (!t.startsWith("{") && !t.startsWith("[")) {
      throw ("Got a non-JSON response. If this persists the domain has moved - check 'Preferred domain' in the source settings.");
    }
    return json.decode(body);
  }

  // jpn / eng / chi / kor all occur on this site.
  String _audioName(String code) {
    final c = code.toLowerCase().trim();
    if (c.isEmpty || c == "jpn") return "Japanese";
    if (c == "eng") return "English";
    if (c == "chi" || c == "zho") return "Chinese";
    if (c == "kor") return "Korean";
    if (c == "spa") return "Spanish";
    if (c == "por") return "Portuguese";
    if (c == "fre" || c == "fra") return "French";
    if (c == "ger" || c == "deu") return "German";
    if (c == "ita") return "Italian";
    if (c == "ara") return "Arabic";
    return code.toUpperCase();
  }

  // Every info label is wrapped in <strong> now, so match the paragraph text.
  String _infoField(MDocument document, String label) {
    for (var p in document.select("div.anime-info p")) {
      final text = p.text.replaceAll(RegExp(r"\s+"), " ").trim();
      if (text.toLowerCase().startsWith(label.toLowerCase())) {
        return text.substring(label.length).trim();
      }
    }
    return "";
  }

  @override
  Future<MPages> getPopular(int page) async {
    return await getLatestUpdates(page);
  }

  @override
  Future<MPages> getLatestUpdates(int page) async {
    final jsonResult = await _getJson("/api?m=airing&page=$page");
    final hasNextPage = jsonResult["current_page"] < jsonResult["last_page"];
    List<MManga> animeList = [];
    for (var item in jsonResult["data"]) {
      MManga anime = MManga();
      anime.name = item["anime_title"];
      anime.imageUrl = item["snapshot"];
      anime.link = "/anime/?anime_id=${item["id"]}&name=${item["anime_title"]}";
      anime.artist = item["fansub"];
      animeList.add(anime);
    }
    return MPages(animeList, hasNextPage);
  }

  @override
  Future<MPages> search(String query, int page, FilterList filterList) async {
    final jsonResult = await _getJson(
      "/api?m=search&q=${Uri.encodeComponent(query.trim())}",
    );
    List<MManga> animeList = [];
    for (var item in jsonResult["data"]) {
      MManga anime = MManga();
      anime.name = item["title"];
      anime.imageUrl = item["poster"];
      anime.link = "/anime/?anime_id=${item["id"]}&name=${item["title"]}";
      animeList.add(anime);
    }
    return MPages(animeList, false);
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
    final res = await _get("/anime/$session?anime_id=$id");
    final document = parseHtml(res);
    anime.status = parseStatus(_infoField(document, "Status:"), statusList);

    anime.name = document.selectFirst("div.title-wrapper > h1 > span").text;
    // Site renamed this to "Studios:" (plural).
    anime.author = _infoField(document, "Studios:");
    anime.imageUrl = document.selectFirst("div.anime-poster a").attr("href");
    // Genre text lives in <li><a>, so the old li/text() xpath returned only
    // whitespace.
    List<String> genres = [];
    for (var a in document.select("div.anime-genre ul li a")) {
      final g = a.text.trim();
      if (g.isNotEmpty && !genres.contains(g)) {
        genres.add(g);
      }
    }
    anime.genre = genres;
    final synonyms = _infoField(document, "Synonyms:");
    final summaryNode = document.selectFirst("div.anime-synopsis");
    anime.description = summaryNode != null ? summaryNode.text.trim() : "";
    if (synonyms.isNotEmpty) {
      anime.description += "\n\n$synonyms";
    }
    final epUrl = "/api?m=release&id=$session&sort=episode_desc&page=1";
    final resEp = await _get(epUrl);
    final episodes = await recursivePages(epUrl, resEp, session);

    anime.chapters = episodes;
    return anime;
  }

  Future<List<MChapter>> recursivePages(
    String url,
    String res,
    String session,
  ) async {
    final jsonResult = json.decode(res);
    final page = jsonResult["current_page"];
    final hasNextPage = page < jsonResult["last_page"];
    List<MChapter> animeList = [];
    for (var item in jsonResult["data"]) {
      MChapter episode = MChapter();
      episode.name = "Episode ${item["episode"]}";
      episode.url = "/play/$session/${item["session"]}";
      episode.dateUpload = parseDates(
        [item["created_at"]],
        "yyyy-MM-dd HH:mm:ss",
        "en",
      )[0];
      animeList.add(episode);
    }
    if (hasNextPage) {
      final newUrl = "${substringBeforeLast(url, "&page=")}&page=${page + 1}";
      final newRes = await _get(newUrl);
      animeList.addAll(await recursivePages(newUrl, newRes, session));
    }
    return animeList;
  }

  Future<String> getSession(String title, String animeId) async {
    final noRedirect = Client(
      source,
      json.encode({"followRedirects": false, "useDartHttpClient": true}),
    );

    final res = await noRedirect.get(
      Uri.parse("$baseUrl/a/$animeId"),
      headers: headers,
    );

    final location =
        "https://${substringAfterLast(getMapValue(json.encode(res.headers), "location"), "https://")}";

    if (location == '$baseUrl/anime') {
      final res = await _get(
        "/api?m=search&q=${Uri.encodeComponent(title)}",
      );
      return substringBefore(
        substringAfter(
          substringAfter(res, "\"id\":$animeId"),
          "\"session\":\"",
        ),
        "\"",
      );
    }
    return substringAfterLast(location, '/');
  }

  @override
  Future<List<MVideo>> getVideoList(String url) async {
    //by default we use rhttp package but it does not support `followRedirects`
    //so setting `useDartHttpClient` to true allows us to use a Dart http package that supports `followRedirects`
    final client = Client(source, json.encode({"useDartHttpClient": true}));
    final res = (await client.get(Uri.parse("$baseUrl$url"), headers: headers));
    final document = parseHtml(res.body);
    final downloadLinks = document.select("div#pickDownload > a");
    final buttons = document.select("div#resolutionMenu > button");
    List<MVideo> videos = [];

    for (var i = 0; i < buttons.length; i++) {
      final btn = buttons[i];
      final audio = (btn.attr("data-audio") ?? "").toLowerCase();
      final kwikLink = btn.attr("data-src");
      // Japanese carries NO badge in the button text and the other badges are
      // lowercase, so the old ["jpn", "Eng"] pref could never match either
      // value. Name it from data-audio instead.
      final quality = "${btn.text.trim()} - ${_audioName(audio)}";
      if (i >= downloadLinks.length) {
        continue;
      }
      final paheWinLink = downloadLinks[i].attr("href");
      final kwikUri = Uri.tryParse(kwikLink);
      final kwikReferer =
          kwikUri != null ? "${kwikUri.scheme}://${kwikUri.host}/" : "";

      if (getPreferenceValue(source.id, "preffered_link_type")) {
        final noRedirectClient = Client(
          source,
          json.encode({"followRedirects": false, "useDartHttpClient": true}),
        );
        final kwikHeaders = (await noRedirectClient.get(
          Uri.parse("${paheWinLink}/i"),
        )).headers;
        final kwikUrl =
            "https://${substringAfterLast(getMapValue(json.encode(kwikHeaders), "location"), "https://")}";
        final reskwik = (await client.get(
          Uri.parse(kwikUrl),
          headers: {
            "Referer":
                "${Uri.parse(kwikUrl).scheme}://${Uri.parse(kwikUrl).host}/",
          },
        ));
        final matches = RegExp(
          r'\("(\S+)",\d+,"(\S+)",(\d+),(\d+)',
        ).firstMatch(reskwik.body);
        final token = decrypt(
          matches!.group(1)!,
          matches.group(2)!,
          matches.group(3)!,
          int.parse(matches.group(4)!),
        );
        final url = RegExp(r'action="([^"]+)"').firstMatch(token)!.group(1)!;
        final tok = RegExp(r'value="([^"]+)"').firstMatch(token)!.group(1)!;
        var code = 419;
        var tries = 0;
        String location = "";

        while (code != 302 && tries < 20) {
          String cookie = getMapValue(
            json.encode(res.request.headers),
            "cookie",
          );
          cookie +=
              "; ${getMapValue(json.encode(reskwik.headers), "set-cookie").replaceAll("path=/;", "")}";
          final resNo =
              await Client(
                source,
                json.encode({
                  "followRedirects": false,
                  "useDartHttpClient": true,
                }),
              ).post(
                Uri.parse(url),
                headers: {
                  "referer": reskwik.request.url.toString(),
                  "cookie": cookie,
                  "user-agent": getMapValue(
                    json.encode(res.request.headers),
                    "user-agent",
                  ),
                },
                body: {"_token": tok},
              );
          code = resNo.statusCode;
          tries++;
          location = getMapValue(json.encode(resNo.headers), "location");
        }
        // Was `if (tries > 19)`, which threw even when the 302 arrived on the
        // final attempt. Check the outcome, not the counter.
        if (code != 302) {
          throw ("Failed to extract the stream uri from kwik.");
        }
        MVideo video = MVideo();
        video
          ..url = location
          ..originalUrl = location
          ..quality = quality
          ..headers = {"Referer": kwikReferer};
        videos.add(video);
      } else {
        final ress = (await client.get(
          Uri.parse(kwikLink),
          headers: {"Referer": "$baseUrl/"},
        ));
        final script = substringAfterLast(
          xpath(
            ress.body,
            '//script[contains(text(),"eval(function")]/text()',
          ).first,
          "eval(function(",
        );
        final unpackedScript = unpackJsAndCombine("eval(function($script");
        final sourceMatch = RegExp(
          r"const\s+source\s*=\s*(?:'([^']+)'|\\'([^\\]+)\\')",
        ).firstMatch(unpackedScript);
        final videoUrl =
            sourceMatch?.group(1) ??
            sourceMatch?.group(2) ??
            substringBefore(
              substringAfter(unpackedScript, "const source=\\'"),
              "\\';",
            );
        if (videoUrl.isEmpty) {
          continue;
        }
        MVideo video = MVideo();
        video
          ..url = videoUrl
          ..originalUrl = videoUrl
          ..quality = quality
          ..headers = {"Referer": kwikReferer};
        videos.add(video);
      }
    }
    return sortVideos(videos);
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
    String quality = getPreferenceValue(source.id, "preferred_quality");
    String preferredAudio = getPreferenceValue(
      source.id,
      "preferred_audio",
    ); // get user's audio preference

    videos.sort((MVideo a, MVideo b) {
      // Prioritize audio first.
      // Preferred Audio: Videos with matching preferred audio are ranked highest.
      final needle = _audioName(preferredAudio).toLowerCase();
      int audioMatchA = a.quality.toLowerCase().contains(needle) ? 1 : 0;
      int audioMatchB = b.quality.toLowerCase().contains(needle) ? 1 : 0;
      if (audioMatchA != audioMatchB) {
        return audioMatchB - audioMatchA;
      }

      // quality prioritized next
      // Preferred Video Quality: If audio matches, videos with preferred video quality are ranked higher.
      int qualityMatchA = 0;
      if (a.quality.contains(quality)) {
        qualityMatchA = 1;
      }
      int qualityMatchB = 0;
      if (b.quality.contains(quality)) {
        qualityMatchB = 1;
      }
      if (qualityMatchA != qualityMatchB) {
        return qualityMatchB - qualityMatchA;
      }

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
      // Key is versioned because the app persists the previously selected
      // value; without a new key an existing install keeps its old domain and
      // the new default never takes effect.
      ListPreference(
        key: "preferred_domain_v2",
        title: "Preferred domain",
        summary: "www.animepahe.pw is current. animepahe.com is the backup.",
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
        key: "preffered_link_type",
        title: "Use HLS links",
        summary: "Enable this if you are having Cloudflare issues.",
        value: true,
      ),
      ListPreference(
        key: "preferred_quality",
        title: "Preferred Quality",
        summary: "",
        valueIndex: 0,
        entries: ["1080p", "720p", "360p"],
        entryValues: ["1080", "720", "360"],
      ),

      ListPreference(
        key: "preferred_audio", // Add new preference for audio
        title: "Preferred Audio",
        summary: "Select your preferred audio language (Japanese or English).",
        valueIndex: 0, // Default to Japanese (or whichever you prefer)
        entries: ["Japanese", "English", "Chinese", "Korean"],
        entryValues: ["jpn", "eng", "chi", "kor"],
      ),
    ];
  }
}

AnimePahe main(MSource source) {
  return AnimePahe(source);
}

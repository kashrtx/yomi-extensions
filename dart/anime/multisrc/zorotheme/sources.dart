import '../../../../model/source.dart';
import 'src/hianime/hianime.dart';
import 'src/kaido/kaido.dart';

// 0.1.76 - flag HiAnime as permanently shut down (see src/hianime).
// NB: patch numbers here are plain integers (75 -> 76), so do not "bump" to
// 0.1.8 - under semver that sorts BELOW 0.1.75 and the app would ignore it.
const _zorothemeVersion = "0.1.76";
const _zorothemeSourceCodeUrl =
    "https://raw.githubusercontent.com/kashrtx/yomi-extensions/$branchName/dart/anime/multisrc/zorotheme/zorotheme.dart";

List<Source> get zorothemeSourcesList => _zorothemeSourcesList;
List<Source> _zorothemeSourcesList =
    [
          //AniWatch.to (EN)
          aniwatchSource,
          //Kaido.to (EN)
          kaidoSource,
        ]
        .map(
          (e) => e
            ..sourceCodeUrl = _zorothemeSourceCodeUrl
            ..version = _zorothemeVersion,
        )
        .toList();

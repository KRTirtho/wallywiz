import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'UNPLASH_KEY')
  static final String unsplashKey = _Env.unsplashKey;
  @EnviedField(varName: 'NASA_KEY')
  static final String nasaKey = _Env.nasaKey;
  @EnviedField(varName: 'PEXEL_KEY')
  static final String pexelKey = _Env.pexelKey;
  @EnviedField(varName: 'PIXABAY_KEY')
  static final String pixabayKey = _Env.pixabayKey;
  @EnviedField(varName: 'WALLHAVEN_KEY')
  static final String wallHavenKey = _Env.wallHavenKey;
}

import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'WEB_API_KEY', obfuscate: true)
  static final String webApiKey = _Env.webApiKey;

  @EnviedField(varName: 'WEB_APP_ID', obfuscate: true)
  static final String webAppId = _Env.webAppId;

  @EnviedField(varName: 'WEB_AUTH_DOMAIN', obfuscate: true)
  static final String webAuthDomain = _Env.webAuthDomain;

  @EnviedField(varName: 'ANDROID_API_KEY', obfuscate: true)
  static final String androidApiKey = _Env.androidApiKey;

  @EnviedField(varName: 'ANDROID_APP_ID', obfuscate: true)
  static final String androidAppId = _Env.androidAppId;

  @EnviedField(varName: 'IOS_API_KEY', obfuscate: true)
  static final String iosApiKey = _Env.iosApiKey;

  @EnviedField(varName: 'IOS_APP_ID', obfuscate: true)
  static final String iosAppId = _Env.iosAppId;

  @EnviedField(varName: 'IOS_BUNDLE_ID', obfuscate: true)
  static final String iosBundleId = _Env.iosBundleId;

  @EnviedField(varName: 'FIREBASE_MESSAGING_SENDER_ID', obfuscate: true)
  static final String messagingSenderId = _Env.messagingSenderId;

  @EnviedField(varName: 'FIREBASE_PROJECT_ID', obfuscate: true)
  static final String projectId = _Env.projectId;

  @EnviedField(varName: 'FIREBASE_STORAGE_BUCKET', obfuscate: true)
  static final String storageBucket = _Env.storageBucket;
}

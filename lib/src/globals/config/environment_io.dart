// Native platform implementation (iOS, Android, Desktop)
import 'dart:io' show Platform;

String getEnvFromPlatform(String key, String fallback) {
  return Platform.environment[key] ?? fallback;
}

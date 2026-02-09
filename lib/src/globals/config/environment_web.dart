// Web platform implementation
// For web, we use compile-time constants via --dart-define or fallback values
// Environment variables are not available at runtime on web

String getEnvFromPlatform(String key, String fallback) {
  // On web, we can't access Platform.environment
  // Instead, we rely on compile-time constants passed via --dart-define
  // or use the fallback values
  return fallback;
}

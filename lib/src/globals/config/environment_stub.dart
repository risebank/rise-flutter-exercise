// Stub file for conditional imports
// This file is used when neither dart:io nor dart:html are available
// (e.g., in some test environments). Returns fallback values.

String getEnvFromPlatform(String key, String fallback) {
  // In environments where Platform.environment is not available,
  // return the fallback value
  return fallback;
}

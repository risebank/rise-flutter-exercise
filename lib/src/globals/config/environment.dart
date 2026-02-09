// Conditional imports for platform-specific environment variable access
import 'environment_stub.dart'
    if (dart.library.io) 'environment_io.dart'
    if (dart.library.html) 'environment_web.dart'
    as platform_env;

enum EnvironmentType { dev, staging, prod }

class Environment {
  // Read from environment variables (GitHub Secrets in CI, system env locally)
  // Falls back to hardcoded values if not set (for test-takers without access)
  //
  // Note: On web, environment variables are not available at runtime.
  // The app will use fallback values. For CI/CD, use --dart-define flags
  // or configure via build-time constants.
  static EnvironmentType get type {
    final envString = _getEnv('ENVIRONMENT', 'dev').toLowerCase();
    return EnvironmentType.values.firstWhere(
      (e) => e.name == envString,
      orElse: () => EnvironmentType.dev,
    );
  }

  static String get apiBaseUrl => _getEnv(
    'API_BASE_URL',
    'https://6fsryeht36.execute-api.eu-central-1.amazonaws.com',
  );

  static String get cognitoUserPoolId =>
      _getEnv('COGNITO_USER_POOL_ID', 'eu-central-1_Z1eAi51xP');

  static String get cognitoClientId =>
      _getEnv('COGNITO_CLIENT_ID', '2fc1pebmi9acbnt8r42c6srbpe');

  static String get awsRegion => _getEnv('AWS_REGION', 'eu-central-1');

  // Helper to read from environment variables with fallback
  static String _getEnv(String key, String fallback) {
    // On native platforms (iOS, Android, Desktop), this reads from Platform.environment
    // On web, this returns the fallback value (env vars not available at runtime)
    // In CI/CD, native builds can use GitHub Secrets via environment variables
    // For web builds, use --dart-define flags or rely on fallback values
    return platform_env.getEnvFromPlatform(key, fallback);
  }

  static bool get isDev => type == EnvironmentType.dev;
  static bool get isStaging => type == EnvironmentType.staging;
  static bool get isProd => type == EnvironmentType.prod;

  static String get environmentName => type.name.toUpperCase();
}

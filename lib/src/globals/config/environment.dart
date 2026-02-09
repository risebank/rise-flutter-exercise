enum EnvironmentType { dev, staging, prod }

class Environment {
  // Hardcoded development environment configuration
  // These values are safe to commit as they are for the exercise/test environment
  static const EnvironmentType _type = EnvironmentType.dev;

  static const String _apiBaseUrl =
      'https://6fsryeht36.execute-api.eu-central-1.amazonaws.com';
  static const String _cognitoUserPoolId = 'eu-central-1_Z1eAi51xP';
  static const String _cognitoClientId = '2fc1pebmi9acbnt8r42c6srbpe';
  static const String _awsRegion = 'eu-central-1';

  static EnvironmentType get type => _type;
  static String get apiBaseUrl => _apiBaseUrl;
  static String get cognitoUserPoolId => _cognitoUserPoolId;
  static String get cognitoClientId => _cognitoClientId;
  static String get awsRegion => _awsRegion;

  static bool get isDev => type == EnvironmentType.dev;
  static bool get isStaging => type == EnvironmentType.staging;
  static bool get isProd => type == EnvironmentType.prod;

  static String get environmentName => type.name.toUpperCase();
}

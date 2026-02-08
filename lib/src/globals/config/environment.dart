import 'package:flutter_dotenv/flutter_dotenv.dart';

enum EnvironmentType { dev, staging, prod }

class Environment {
  static EnvironmentType get type {
    final envString = dotenv.env['ENVIRONMENT'] ?? 'dev';
    return EnvironmentType.values.firstWhere(
      (e) => e.name == envString,
      orElse: () => EnvironmentType.dev,
    );
  }

  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get cognitoUserPoolId =>
      dotenv.env['COGNITO_USER_POOL_ID'] ?? '';
  static String get cognitoClientId => dotenv.env['COGNITO_CLIENT_ID'] ?? '';
  static String get awsRegion => dotenv.env['AWS_REGION'] ?? 'eu-central-1';

  static bool get isDev => type == EnvironmentType.dev;
  static bool get isStaging => type == EnvironmentType.staging;
  static bool get isProd => type == EnvironmentType.prod;

  static String get environmentName => type.name.toUpperCase();
}

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'https://api.risebank.com';
  }
  
  static String get amplifyApiKey {
    return dotenv.env['AMPLIFY_API_KEY'] ?? '';
  }
  
  static String get amplifyAuthRegion {
    return dotenv.env['AMPLIFY_AUTH_REGION'] ?? 'eu-west-1';
  }
}

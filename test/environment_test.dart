import 'package:flutter_test/flutter_test.dart';
import 'package:rise_flutter_exercise/src/globals/config/environment.dart';

void main() {
  group('Environment', () {
    test('should return dev environment type', () {
      expect(Environment.type, EnvironmentType.dev);
    });

    test('should have valid API base URL', () {
      final url = Environment.apiBaseUrl;
      expect(url, isNotEmpty);
      expect(url, startsWith('http'));
    });

    test('should have valid Cognito configuration', () {
      expect(Environment.cognitoUserPoolId, isNotEmpty);
      expect(Environment.cognitoClientId, isNotEmpty);
      expect(Environment.awsRegion, isNotEmpty);
    });

    test('should identify as dev environment', () {
      expect(Environment.isDev, isTrue);
      expect(Environment.isStaging, isFalse);
      expect(Environment.isProd, isFalse);
    });

    test('should return correct environment name', () {
      expect(Environment.environmentName, 'DEV');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:rise_flutter_exercise/src/globals/config/environment.dart';

void main() {
  group('Environment', () {
    test('should return dev environment type', () {
      expect(Environment.type, EnvironmentType.dev);
    });

    test('should have correct API base URL', () {
      expect(
        Environment.apiBaseUrl,
        'https://6fsryeht36.execute-api.eu-central-1.amazonaws.com',
      );
    });

    test('should have correct Cognito configuration', () {
      expect(Environment.cognitoUserPoolId, 'eu-central-1_Z1eAi51xP');
      expect(Environment.cognitoClientId, '2fc1pebmi9acbnt8r42c6srbpe');
      expect(Environment.awsRegion, 'eu-central-1');
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

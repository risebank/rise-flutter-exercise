import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String getAmplifyConfig() {
  return ''' {
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "auth": {
      "plugins": {
        "awsCognitoAuthPlugin": {
          "IdentityManager": {
            "Default": {}
          },
          
          "CognitoUserPool": {
            "Default": {
              "PoolId": "${dotenv.env['COGNITO_USER_POOL_ID']}",
              "AppClientId": "${dotenv.env['COGNITO_CLIENT_ID']}",
              "Region": "${dotenv.env['AWS_REGION']}"
            }
          },
           "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "usernameAttributes": ["email"],
            "signupAttributes": [
              "email", "name"
             ],
            "passwordProtectionSettings": {
                "passwordPolicyMinLength": 8,
                "passwordPolicyCharacters": []
            }
          }
        }
      }
    }
  }
}''';
}

Future<void> configureAmplify() async {
  try {
    // Add Cognito Auth Plugin
    final auth = AmplifyAuthCognito();
    await Amplify.addPlugin(auth);

    // Configure Amplify
    await Amplify.configure(getAmplifyConfig());

    safePrint('Successfully configured Amplify');
  } catch (e) {
    safePrint('Error configuring Amplify: $e');
    rethrow;
  }
}

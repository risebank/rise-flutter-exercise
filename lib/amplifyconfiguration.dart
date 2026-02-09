import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:rise_flutter_exercise/src/globals/config/environment.dart';

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
              "PoolId": "${Environment.cognitoUserPoolId}",
              "AppClientId": "${Environment.cognitoClientId}",
              "Region": "${Environment.awsRegion}"
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

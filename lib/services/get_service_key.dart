import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getServerKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];
    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "phone-store-ae5d0",
          "private_key_id": "13b931fd85a094ca6fa11818dee3c991b0e9ce8d",
          "private_key":
              "",
          "client_email":
              "firebase-adminsdk-xz0sk@phone-store-ae5d0.iam.gserviceaccount.com",
          "client_id": "114155777604937743344",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xz0sk%40phone-store-ae5d0.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        scopes);
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}

import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get appwriteEndpoint =>
      dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1';
  static String get appwriteProjectId =>
      dotenv.env['APPWRITE_PROJECT_ID'] ?? 'oblns-dev';
  static bool get selfSigned => dotenv.env['APPWRITE_SELF_SIGNED'] == 'true';
}

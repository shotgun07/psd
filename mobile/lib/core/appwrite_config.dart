import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteConfig {
  static String get endpoint =>
      dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1';
  static String get projectId =>
      dotenv.env['APPWRITE_PROJECT_ID'] ?? '697278c2003aaabdb975';
  static String get dbId => dotenv.env['APPWRITE_DATABASE_ID'] ?? 'oblns';
  static String get tripsCollectionId =>
      dotenv.env['APPWRITE_TRIPS_COLLECTION_ID'] ?? 'trips';
  static String get usersCollectionId =>
      dotenv.env['APPWRITE_USERS_COLLECTION_ID'] ?? 'users';
  static String get driversCollectionId =>
      dotenv.env['APPWRITE_DRIVERS_COLLECTION_ID'] ?? 'drivers';
  static String get walletCollectionId =>
      dotenv.env['APPWRITE_WALLETS_COLLECTION_ID'] ?? 'wallets';
  static String get transactionsCollectionId =>
      dotenv.env['APPWRITE_TRANSACTIONS_COLLECTION_ID'] ?? 'transactions';

  static String get otpFunctionId =>
      dotenv.env['APPWRITE_FUNCTION_OTP_ID'] ?? 'function_otp';
  static String get dispatchFunctionId =>
      dotenv.env['APPWRITE_FUNCTION_DISPATCH_ID'] ?? 'function_dispatch';

  static Client client = Client()
    ..setEndpoint(endpoint)
    ..setProject(projectId)
    ..setSelfSigned(status: true);
}

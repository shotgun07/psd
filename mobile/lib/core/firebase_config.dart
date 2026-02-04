import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseConfig {
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseFunctions get functions => FirebaseFunctions.instance;
  static FirebaseDatabase get database => FirebaseDatabase.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp();

    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    await auth.setLanguageCode('ar');
  }

  static String get usersCollection =>
      dotenv.env['FIREBASE_USERS_COLLECTION'] ?? 'users';
  static String get driversCollection =>
      dotenv.env['FIREBASE_DRIVERS_COLLECTION'] ?? 'drivers';
  static String get tripsCollection =>
      dotenv.env['FIREBASE_TRIPS_COLLECTION'] ?? 'trips';
  static String get transactionsCollection =>
      dotenv.env['FIREBASE_TRANSACTIONS_COLLECTION'] ?? 'transactions';
  static String get driverLocationsCollection =>
      dotenv.env['FIREBASE_DRIVER_LOCATIONS_COLLECTION'] ?? 'driver_locations';
  static String get chatsCollection =>
      dotenv.env['FIREBASE_CHATS_COLLECTION'] ?? 'chats';
  static String get messagesCollection =>
      dotenv.env['FIREBASE_MESSAGES_COLLECTION'] ?? 'messages';
  static String get notificationsCollection =>
      dotenv.env['FIREBASE_NOTIFICATIONS_COLLECTION'] ?? 'notifications';
}

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Google Sign-In provider (optional - may not work on all platforms)
final googleSignInProvider = Provider<GoogleSignIn?>((ref) {
  return null;
  // try {
  //   return GoogleSignIn(scopes: ['email', 'profile']);
  // } catch (e) {
  //   return null;
  // }
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instance;
});

final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

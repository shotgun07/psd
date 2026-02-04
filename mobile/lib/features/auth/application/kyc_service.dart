import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/infrastructure/appwrite_client.dart';
import 'package:oblns/infrastructure/appwrite_database_wrapper.dart';

class KycService {
  final Storage _storage;
  final Databases _databases;
  final String _bucketId = 'kyc_documents';
  final String _dbId = 'oblns';
  final String _usersCollection = 'users';

  KycService(this._storage, this._databases);

  AppwriteDatabaseWrapper get _dbWrapper => AppwriteDatabaseWrapper(_databases);

  Future<void> submitKyc(String userId, String filePath) async {
    final file = InputFile.fromPath(path: filePath);

    final kycFile = await _storage.createFile(
      bucketId: _bucketId,
      fileId: ID.unique(),
      file: file,
    );

    await _dbWrapper.updateDocument(
      databaseId: _dbId,
      collectionId: _usersCollection,
      documentId: userId,
      data: {
        'kyc_status': 'submitted',
        'kyc_document_id': kycFile.$id,
        'kyc_submitted_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<String> getKycStatus(String userId) async {
    final doc = await _dbWrapper.getDocument(
      databaseId: _dbId,
      collectionId: _usersCollection,
      documentId: userId,
    );
    return doc.data['kyc_status'] ?? 'pending';
  }
}

final kycServiceProvider = Provider<KycService>((ref) {
  final storage = ref.watch(appwriteStorageProvider);
  final db = ref.watch(appwriteDatabasesProvider);
  return KycService(storage, db);
});
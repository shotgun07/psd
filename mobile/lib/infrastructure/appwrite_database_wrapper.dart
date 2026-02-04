import 'package:appwrite/appwrite.dart';

/// Small compatibility wrapper to centralize Appwrite DB deprecation ignores.
/// Returns dynamic to avoid SDK type mismatches across versions.
class AppwriteDatabaseWrapper {
  final Databases _databases;

  AppwriteDatabaseWrapper(this._databases);

  Future<dynamic> getDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
  }) async {
    final db = _databases as dynamic;
    // ignore: deprecated_member_use
    return await db.getDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }

  Future<dynamic> createDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final db = _databases as dynamic;
    // ignore: deprecated_member_use
    return await db.createDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
      data: data,
    );
  }

  Future<dynamic> listDocuments({
    required String databaseId,
    required String collectionId,
    List? queries,
  }) async {
    final db = _databases as dynamic;
    // ignore: deprecated_member_use
    return await db.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: queries,
    );
  }

  Future<dynamic> updateDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final db = _databases as dynamic;
    // ignore: deprecated_member_use
    return await db.updateDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
      data: data,
    );
  }
}

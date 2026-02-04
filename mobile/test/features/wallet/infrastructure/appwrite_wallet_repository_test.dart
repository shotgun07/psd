import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:appwrite/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:oblns/core/models/transaction_model.dart';
import 'package:oblns/features/wallet/infrastructure/appwrite_wallet_repository.dart';

@GenerateMocks([Databases, Functions])
import 'appwrite_wallet_repository_test.mocks.dart';

void main() {
  late AppwriteWalletRepository repository;
  late MockDatabases mockDatabases;
  late MockFunctions mockFunctions;

  setUp(() {
    mockDatabases = MockDatabases();
    mockFunctions = MockFunctions();
    repository = AppwriteWalletRepository(mockDatabases, mockFunctions);
  });

  group('getBalance', () {
    test('returns balance when document exists', () async {
      final mockData = {'\$id': 'user1', 'wallet_balance': 100.0};
      when(
        mockDatabases.getDocument(
          databaseId: anyNamed('databaseId'),
          collectionId: anyNamed('collectionId'),
          documentId: anyNamed('documentId'),
        ),
      ).thenAnswer((_) async => _FakeDocument(mockData));

      final result = await repository.getBalance();

      expect(result, 100.0);
      verify(
        mockDatabases.getDocument(
          databaseId: 'oblns',
          collectionId: 'users',
          documentId: 'current_user_id',
        ),
      ).called(1);
    });

    test('throws exception when document not found', () async {
      when(
        mockDatabases.getDocument(
          databaseId: anyNamed('databaseId'),
          collectionId: anyNamed('collectionId'),
          documentId: anyNamed('documentId'),
        ),
      ).thenThrow(Exception('Document not found'));

      expect(() => repository.getBalance(), throwsException);
    });
  });

  group('getTransactionHistory', () {
    test('returns list of transactions', () async {
      final mockDocs = [
        {
          'id': 'tx1',
          'user_id': 'user1',
          'amount': 50.0,
          'type': 'credit',
          'status': 'completed',
          'created_at': '2023-01-01T00:00:00.000Z',
        },
      ];
      when(
        mockDatabases.listDocuments(
          databaseId: anyNamed('databaseId'),
          collectionId: anyNamed('collectionId'),
          queries: anyNamed('queries'),
        ),
      ).thenAnswer((_) async => _FakeDocumentList(mockDocs));

      final result = await repository.getTransactionHistory();

      expect(result, isA<List<TransactionModel>>());
      expect(result.length, 1);
      expect(result.first.amount, 50.0);
    });
  });

  group('addFunds', () {
    test('calls function successfully', () async {
      when(
        mockFunctions.createExecution(
          functionId: anyNamed('functionId'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => _FakeExecution('{"success":true}'));

      await repository.addFunds(100.0, 'pm1');

      verify(
        mockFunctions.createExecution(
          functionId: 'walletSync',
          body: anyNamed('body'),
        ),
      ).called(1);
    });
  });
}

class _FakeDocument extends Fake implements models.Document {
  @override
  final Map<String, dynamic> data;
  _FakeDocument(this.data);
}

class _FakeDocumentList extends Fake implements models.DocumentList {
  final List<Map<String, dynamic>> _docs;

  _FakeDocumentList(List<Map<String, dynamic>> docs) : _docs = docs;

  @override
  List<models.Document> get documents =>
      _docs.map((d) => _FakeDocument(d)).toList();
}

class _FakeExecution extends Fake implements models.Execution {
  @override
  final String responseBody;

  _FakeExecution(this.responseBody);

  @override
  ExecutionStatus get status {
    return ExecutionStatus.completed;
  }
}

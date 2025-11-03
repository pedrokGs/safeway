import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/core/di/alert_providers.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/domain/repositories/auth_repository.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main(){
  late MockFirebaseFirestore firestore;
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;

  setUp(() {
    firestore = MockFirebaseFirestore();
    mockAuthRepository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        cloudFirestoreProvider.overrideWithValue(firestore),
        authRepositoryProvider.overrideWithValue(mockAuthRepository)
      ]
    );
    addTearDown(container.dispose);
  },);
}
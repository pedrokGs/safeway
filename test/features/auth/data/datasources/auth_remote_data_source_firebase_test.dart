import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/core/di/auth_providers.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main(){
  late MockFirebaseAuth mockFirebaseAuth;
  late ProviderContainer providerContainer;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();

    providerContainer = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockFirebaseAuth)
      ]
    );

    addTearDown(providerContainer.dispose);
  },);

}
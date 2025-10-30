import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/data/models/auth_user_model.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late ProviderContainer providerContainer;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    providerContainer = ProviderContainer(
      overrides: [firebaseAuthProvider.overrideWithValue(mockFirebaseAuth)],
    );

    addTearDown(providerContainer.dispose);
  });

  final tEmail = "test@gmail.com";
  final tPassword = "Password123";
  final tId = 'test123';
  final tUser = AuthUserModel(email: tEmail, id: tId);

  group('authUserChanges', () {
    test(
      'should emit a value of AuthUserModel when user is logged in',
      () async {
        when(() => mockUser.email).thenReturn(tEmail);
        when(() => mockUser.uid).thenReturn(tId);
        when(
          () => mockFirebaseAuth.authStateChanges(),
        ).thenAnswer((_) => Stream.fromIterable([mockUser]));

        final dataSource = providerContainer.read(authRemoteDataSourceProvider);

        final expected = tUser;

        expectLater(dataSource.authUserChanges, emits(expected));
      },
    );

    test(
      'should emit a value of null when user is not logged in (sign out)',
      () async {
        when(
          () => mockFirebaseAuth.authStateChanges(),
        ).thenAnswer((_) => Stream.fromIterable([null]));

        final dataSource = providerContainer.read(authRemoteDataSourceProvider);

        expectLater(dataSource.authUserChanges, emits(null));
      },
    );

    test(
      'should emits values in order when authState changes (sign in / sign out)',
      () async {
        when(() => mockUser.email).thenReturn(tEmail);
        when(() => mockUser.uid).thenReturn(tId);
        when(
          () => mockFirebaseAuth.authStateChanges(),
        ).thenAnswer((_) => Stream.fromIterable([null, mockUser, null]));

        final dataSource = providerContainer.read(authRemoteDataSourceProvider);

        final expected = [null, tUser, null];

        expectLater(dataSource.authUserChanges, emitsInOrder(expected));
      },
    );
  });

  group('currentUser', () {
    test('should return an AuthUserModel if currentUser is not null', () {
      when(() => mockUser.email).thenReturn(tEmail);
      when(() => mockUser.uid).thenReturn(tId);
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      expect(dataSource.currentUser, tUser);
    });

    test('should return null when currentUser is null', () async {
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      expect(dataSource.currentUser, null);
    });
  });

  
}

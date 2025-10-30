import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:safeway/features/auth/data/models/auth_user_model.dart';
import 'package:safeway/features/auth/domain/entities/auth_user_entity.dart';
import 'package:safeway/features/auth/domain/exceptions/data_source_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/invalid_credentials_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/network_exception.dart';

class MockRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late ProviderContainer providerContainer;
  late MockRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    providerContainer = ProviderContainer(
      overrides: [
        authRemoteDataSourceProvider.overrideWithValue(mockRemoteDataSource),
      ],
    );
    addTearDown(providerContainer.dispose);
  });

  final String tId = "testId";
  final String tEmail = 'test@gmail.com';
  final String tPassword = "Password123";
  final AuthUserModel mockUser = AuthUserModel(id: tId, email: tEmail);

  group('authUserChanges', () {
    test('emits AuthUserEntity when a user is logged in', () async {
      when(
        () => mockRemoteDataSource.authUserChanges,
      ).thenAnswer((_) => Stream.fromIterable([mockUser]));

      final repository = providerContainer.read(authRepositoryProvider);

      final expected = AuthUserEntity(id: tId, email: tEmail);

      expectLater(repository.authUserChanges, emits(expected));
    });

    test('emits null when user logs out (stream is null', () async {
      when(
        () => mockRemoteDataSource.authUserChanges,
      ).thenAnswer((_) => Stream.fromIterable([null]));

      final repository = providerContainer.read(authRepositoryProvider);

      expectLater(repository.authUserChanges, emits(null));
    });

    test('emits multiple events in order', () async {
      when(
        () => mockRemoteDataSource.authUserChanges,
      ).thenAnswer((_) => Stream.fromIterable([null, mockUser, null]));

      final repository = providerContainer.read(authRepositoryProvider);

      final expected = [null, AuthUserEntity(id: tId, email: tEmail), null];

      await expectLater(repository.authUserChanges, emitsInOrder(expected));
    });
  });

  group('currentUser', () {
    test('should return an AuthUserEntity if currentUser is not null', () {
      when(() => mockRemoteDataSource.currentUser).thenReturn(mockUser);

      final repository = providerContainer.read(authRepositoryProvider);

      final expected = AuthUserEntity(id: tId, email: tEmail);

      expect(repository.currentUser, equals(expected));
    });

    test(
      'should return an empty AuthUserEntity when currentUser returns null',
      () {
        when(() => mockRemoteDataSource.currentUser).thenReturn(null);

        final repository = providerContainer.read(authRepositoryProvider);

        expect(repository.currentUser, null);
      },
    );
  });

  group('signInWithEmailAndPassword', () {
    test(
      'should return an String id when operation is successful, should also pass correct values',
      () async {
        when(
          () => mockRemoteDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => tId);

        final repository = providerContainer.read(authRepositoryProvider);

        final result = await repository.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );

        expect(result, equals(tId));
        verify(
          () => mockRemoteDataSource.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).called(1);
      },
    );

    test(
      'should return exception when datasource throws InvalidCredentialsException',
      () async {
        when(
          () => mockRemoteDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(InvalidCredentialsException());

        final repository = providerContainer.read(authRepositoryProvider);

        expectLater(
          repository.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
          throwsA(isA<InvalidCredentialsException>()),
        );
        verify(
          () => mockRemoteDataSource.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).called(1);
      },
    );

    test(
      'should return exception when datasource throws NetworkException',
      () async {
        when(
          () => mockRemoteDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(NetworkException());

        final repository = providerContainer.read(authRepositoryProvider);

        expectLater(
          repository.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
          throwsA(isA<NetworkException>()),
        );
        verify(
          () => mockRemoteDataSource.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).called(1);
      },
    );

    test(
      'should return an DataSourceException when datasource throws generic exception',
      () async {
        when(
          () => mockRemoteDataSource.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(DataSourceException('test error'));

        final repository = providerContainer.read(authRepositoryProvider);

        expectLater(
          repository.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
          throwsA(isA<DataSourceException>()),
        );
        verify(
          () => mockRemoteDataSource.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).called(1);
      },
    );
  });

  group('signUpWithEmailAndPassword', () {
    test(
      'should return an String id when operation is successful, should also pass correct values',
      () async {
        when(
          () => mockRemoteDataSource.signUpWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => tId);

        final repository = providerContainer.read(authRepositoryProvider);

        final result = await repository.signUpWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );

        expect(result, equals(tId));
        verify(
          () => mockRemoteDataSource.signUpWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).called(1);
      },
    );

    test(
      'should return exception when datasource throws InvalidCredentialsException',
      () async {
        when(
          () => mockRemoteDataSource.signUpWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(InvalidCredentialsException());

        final repository = providerContainer.read(authRepositoryProvider);

        expectLater(
          repository.signUpWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
          throwsA(isA<InvalidCredentialsException>()),
        );
        verify(
          () => mockRemoteDataSource.signUpWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).called(1);
      },
    );

    test(
      'should return exception when datasource throws NetworkException',
      () async {
        when(
          () => mockRemoteDataSource.signUpWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(NetworkException());

        final repository = providerContainer.read(authRepositoryProvider);

        expectLater(
          repository.signUpWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
          throwsA(isA<NetworkException>()),
        );
        verify(
          () => mockRemoteDataSource.signUpWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).called(1);
      },
    );

    test(
      'should return an DataSourceException when datasource throws generic exception',
      () async {
        when(
          () => mockRemoteDataSource.signUpWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(DataSourceException('test error'));

        final repository = providerContainer.read(authRepositoryProvider);

        expectLater(
          repository.signUpWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
          throwsA(isA<DataSourceException>()),
        );
        verify(
          () => mockRemoteDataSource.signUpWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).called(1);
      },
    );
  });

  group('signOut', () {
    test('should complete successfully when operation succeeds', () async {
      when(() => mockRemoteDataSource.signOut()).thenAnswer((_) async => true);

      final repository = providerContainer.read(authRepositoryProvider);

      await repository.signOut();

      verify(() => mockRemoteDataSource.signOut()).called(1);
    });

    test('should throw DataSourceException when datasource fails', () async {
      when(
        () => mockRemoteDataSource.signOut(),
      ).thenThrow(DataSourceException('test error'));

      final repository = providerContainer.read(authRepositoryProvider);

      expectLater(repository.signOut(), throwsA(isA<DataSourceException>()));

      verify(() => mockRemoteDataSource.signOut()).called(1);
    });
  });

  group('signInWithGoogle', () {
    test('should return an id when operation is successful', () async {
      when(
        () => mockRemoteDataSource.signInWithGoogle(),
      ).thenAnswer((_) async => tId);

      final repository = providerContainer.read(authRepositoryProvider);

      final result = await repository.signInWithGoogle();

      expect(result, equals(tId));
      verify(() => mockRemoteDataSource.signInWithGoogle()).called(1);
    });

    test(
      'should throw NetworkException when datasource fails due to network',
      () async {
        when(
          () => mockRemoteDataSource.signInWithGoogle(),
        ).thenThrow(NetworkException());

        final repository = providerContainer.read(authRepositoryProvider);

        expectLater(
          repository.signInWithGoogle(),
          throwsA(isA<NetworkException>()),
        );

        verify(() => mockRemoteDataSource.signInWithGoogle()).called(1);
      },
    );

    test(
      'should throw DataSourceException when datasource throws generic exception',
      () async {
        when(
          () => mockRemoteDataSource.signInWithGoogle(),
        ).thenThrow(DataSourceException('test error'));

        final repository = providerContainer.read(authRepositoryProvider);

        expectLater(
          repository.signInWithGoogle(),
          throwsA(isA<DataSourceException>()),
        );

        verify(() => mockRemoteDataSource.signInWithGoogle()).called(1);
      },
    );
  });

  group('sendResetPasswordEmail', () {
    test('should complete successfully when operation succeeds', () async {
      when(
        () => mockRemoteDataSource.sendResetPasswordEmail(
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => true);

      final repository = providerContainer.read(authRepositoryProvider);

      await repository.sendResetPasswordEmail(email: tEmail);

      verify(
        () => mockRemoteDataSource.sendResetPasswordEmail(email: tEmail),
      ).called(1);
    });

    test(
      'should throw NetworkException when datasource fails due to network',
      () async {
        when(
          () => mockRemoteDataSource.sendResetPasswordEmail(
            email: any(named: 'email'),
          ),
        ).thenThrow(NetworkException());

        final repository = providerContainer.read(authRepositoryProvider);

        expectLater(
          repository.sendResetPasswordEmail(email: tEmail),
          throwsA(isA<NetworkException>()),
        );

        verify(
          () => mockRemoteDataSource.sendResetPasswordEmail(email: tEmail),
        ).called(1);
      },
    );

    test(
      'should throw DataSourceException when datasource throws generic exception',
      () async {
        when(
          () => mockRemoteDataSource.sendResetPasswordEmail(
            email: any(named: 'email'),
          ),
        ).thenThrow(DataSourceException('test error'));

        final repository = providerContainer.read(authRepositoryProvider);

        expectLater(
          repository.sendResetPasswordEmail(email: tEmail),
          throwsA(isA<DataSourceException>()),
        );

        verify(
          () => mockRemoteDataSource.sendResetPasswordEmail(email: tEmail),
        ).called(1);
      },
    );
  });
}

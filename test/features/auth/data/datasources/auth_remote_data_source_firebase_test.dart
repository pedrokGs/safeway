import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/data/models/auth_user_model.dart';
import 'package:safeway/features/auth/domain/exceptions/data_source_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/email_already_in_use_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/google_sign_in_cancelled_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/google_sign_in_failed_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/google_sign_in_interrupted_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/invalid_credentials_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/unknown_data_source_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/user_not_found_exception.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}
class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late ProviderContainer providerContainer;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
    registerFallbackValue(FakeAuthCredential());

    providerContainer = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
        googleSignInProvider.overrideWithValue(mockGoogleSignIn),
      ],
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

  group('signInWithEmailAndPassword', () {
    test('should return an String with User Id when sign in is successful', () async {
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn(tId);
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')),)
          .thenAnswer((_) async => mockUserCredential,);

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      final result = await dataSource.signInWithEmailAndPassword(email: tEmail, password: tPassword);

      await expectLater(result, equals(tId));
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(email: tEmail, password: tPassword)).called(1);
    },);

    test('should throw an UserNotFoundException in case of user not found', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      await expectLater(dataSource.signInWithEmailAndPassword(email: tEmail, password: tPassword), throwsA(isA<UserNotFoundException>()));
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(email: tEmail, password: tPassword)).called(1);
    },);
    
    test('shold throw an InvalidCredentialsException when user tries to sign in with invalid credentials', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(FirebaseAuthException(code: 'invalid-credentials'));

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      await expectLater(dataSource.signInWithEmailAndPassword(email: tEmail, password: tPassword), throwsA(isA<InvalidCredentialsException>()));
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(email: tEmail, password: tPassword)).called(1);
    },);

    test('should throw an UnknownDataSourceException when an unexpected error occours', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(Exception());

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      await expectLater(dataSource.signInWithEmailAndPassword(email: tEmail, password: tPassword), throwsA(isA<UnknownDataSourceException>()));
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(email: tEmail, password: tPassword)).called(1);
    },);
  },);

  group('signUpWithEmailAndPassword', () {
    test('should return an String with User Id when sign up is successful', () async {
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn(tId);
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')),)
          .thenAnswer((_) async => mockUserCredential,);

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      final result = await dataSource.signUpWithEmailAndPassword(email: tEmail, password: tPassword);

      await expectLater(result, equals(tId));
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(email: tEmail, password: tPassword)).called(1);
    },);

    test('should throw an EmailAlreadyInUseException in case of user already being on the system', () async {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      await expectLater(dataSource.signUpWithEmailAndPassword(email: tEmail, password: tPassword), throwsA(isA<EmailAlreadyInUseException>()));
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(email: tEmail, password: tPassword)).called(1);
    },);

    test('shold throw an InvalidCredentialsException when user tries to sign in with invalid credentials', () async {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(FirebaseAuthException(code: 'invalid-credentials'));

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      await expectLater(dataSource.signUpWithEmailAndPassword(email: tEmail, password: tPassword), throwsA(isA<InvalidCredentialsException>()));
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(email: tEmail, password: tPassword)).called(1);
    },);

    test('should throw an UnknownDataSourceException when an unexpected error occours', () async {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(Exception());

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      await expectLater(dataSource.signUpWithEmailAndPassword(email: tEmail, password: tPassword), throwsA(isA<UnknownDataSourceException>()));
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(email: tEmail, password: tPassword)).called(1);
    },);
  },);

  group('signInWithGoogle', () {
    test('should return an String with User Id on successful sign in', () async {
      when(() => mockGoogleSignIn.authenticate()).thenAnswer((_) async => mockGoogleSignInAccount,);
      when(() => mockGoogleSignInAccount.authentication).thenReturn(mockGoogleSignInAuthentication);
      when(() => mockGoogleSignInAuthentication.idToken).thenReturn('fake-access-token');
      when(() => mockFirebaseAuth.signInWithCredential(any())).thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn(tId);

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      final result = await dataSource.signInWithGoogle();

      await expectLater(result, tId);
      verify(() => mockGoogleSignIn.authenticate()).called(1);
    },);

    test('should throw an GoogleSignInCancelledException when user cancels sign in', () async {
      when(() => mockGoogleSignIn.authenticate()).thenThrow(GoogleSignInException(code: GoogleSignInExceptionCode.canceled));

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      await expectLater(dataSource.signInWithGoogle(), throwsA(isA<GoogleSignInCancelledException>()));
      verify(() => mockGoogleSignIn.authenticate()).called(1);
    });

    test('should throw an GoogleSignInInterruptedException when sign in gets interrupted', () async {
        when(() => mockGoogleSignIn.authenticate()).thenThrow(GoogleSignInException(code: GoogleSignInExceptionCode.interrupted));

        final dataSource = providerContainer.read(authRemoteDataSourceProvider);

        await expectLater(dataSource.signInWithGoogle(), throwsA(isA<GoogleSignInInterruptedException>()));
        verify(() => mockGoogleSignIn.authenticate()).called(1);
    });

    test('should throw an GoogleSignInFailedException when login has failed (either client or server)', () async {
      when(() => mockGoogleSignIn.authenticate()).thenThrow(GoogleSignInException(code: GoogleSignInExceptionCode.clientConfigurationError));

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      await expectLater(dataSource.signInWithGoogle(), throwsA(isA<GoogleSignInFailedException>()));
      verify(() => mockGoogleSignIn.authenticate()).called(1);
    },);
    
    test('should throw an UnknownDataSourceException when error is unknown', () async {
      when(() => mockGoogleSignIn.authenticate()).thenThrow(Exception());

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      await expectLater(dataSource.signInWithGoogle(),throwsA(isA<UnknownDataSourceException>()));
      verify(() => mockGoogleSignIn.authenticate()).called(1);
    },);
  },);

  group('sendResetPasswordEmail', () {
    test('should complete operation successfully and passes the correct argument', () async {
      when(() => mockFirebaseAuth.sendPasswordResetEmail(email: any(named: 'email'))).thenAnswer((_) async => {},);

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      await dataSource.sendResetPasswordEmail(email: tEmail);

      verify(() => mockFirebaseAuth.sendPasswordResetEmail(email: tEmail)).called(1);
    },);

    test('should throw an DataSourceException when error is known', () async {
      when(() => mockFirebaseAuth.sendPasswordResetEmail(email: any(named: 'email'))).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      await expectLater(dataSource.sendResetPasswordEmail(email: tEmail), throwsA(isA<DataSourceException>()));
      verify(() => mockFirebaseAuth.sendPasswordResetEmail(email: tEmail)).called(1);
    },);

    test('should throw an UnknownDataSourceException when error is unknown', () async {
      when(() => mockFirebaseAuth.sendPasswordResetEmail(email: any(named: 'email'))).thenThrow(Exception());

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      await expectLater(dataSource.sendResetPasswordEmail(email: tEmail), throwsA(isA<UnknownDataSourceException>()));
      verify(() => mockFirebaseAuth.sendPasswordResetEmail(email: tEmail)).called(1);
    },);
  },);

  group('signOut', () {
    test('should complete operation successfully', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async => {},);

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      await dataSource.signOut();

      verify(() => mockFirebaseAuth.signOut()).called(1);
    },);

    test('should throw an DataSourceException when error is known', () async {
      when(() => mockFirebaseAuth.signOut()).thenThrow(FirebaseAuthException(code: 'network-request-failed'));

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      await expectLater(dataSource.signOut(), throwsA(isA<DataSourceException>()));
      verify(() => mockFirebaseAuth.signOut()).called(1);
    },);

    test('should throw an UnknownDataSourceException when error is unknown', () async {
      when(() => mockFirebaseAuth.signOut()).thenThrow(Exception());

      final dataSource = providerContainer.read(authRemoteDataSourceProvider);

      await expectLater(dataSource.signOut(), throwsA(isA<UnknownDataSourceException>()));
      verify(() => mockFirebaseAuth.signOut()).called(1);
    },);
  },);
}

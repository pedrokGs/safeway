import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/domain/exceptions/data_source_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/google_sign_in_cancelled_exception.dart';
import 'package:safeway/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main(){
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer providerContainer;

  setUp(() {
    mockAuthRepository = MockAuthRepository();

    providerContainer = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(mockAuthRepository),
    ]);
    addTearDown(providerContainer.dispose);
  },);
  
  final String tId = 'test123';

  test('should return an String id when repository returns correct value', () async {
    when(() => mockAuthRepository.signInWithGoogle(),).thenAnswer((_) async => tId,);

    final signInWithGoogleUseCase = providerContainer.read(signInWithGoogleUseCaseProvider);

    final result = await signInWithGoogleUseCase.call();

    expect(result, tId);
    verify(() => mockAuthRepository.signInWithGoogle()).called(1);
  },);

  test('should return an exception when google sign in is cancelled', () async {
    when(() => mockAuthRepository.signInWithGoogle()).thenThrow(GoogleSignInCancelledException());

    final signInWithGoogleUseCase = providerContainer.read(signInWithGoogleUseCaseProvider);

    expectLater(signInWithGoogleUseCase.call(), throwsA(isA<GoogleSignInCancelledException>()));
    verify(() => mockAuthRepository.signInWithGoogle(),).called(1);
  },);

  test('should return an exception when repository throws an DatasourceException', () async {
    when(() => mockAuthRepository.signInWithGoogle()).thenThrow(DataSourceException('erro teste'));

    final signInWithGoogleUseCase = providerContainer.read(signInWithGoogleUseCaseProvider);

    expectLater(signInWithGoogleUseCase.call(), throwsA(isA<DataSourceException>()));
    verify(() => mockAuthRepository.signInWithGoogle()).called(1);
  },);
}
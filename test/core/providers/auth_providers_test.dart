import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeway/core/di/auth_providers.dart'; // Importe o arquivo que criamos
import 'package:mockito/mockito.dart'; // Precisaremos de mocks

// --- PREPARAÇÃO DO MOCK ---
// Como não queremos usar o Firebase REAL no teste, nós o "simulamos" (mock).
// Criamos uma classe 'MockFirebaseAuth' que 'finge' ser o FirebaseAuth.
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('authRepositoryProvider', () {

    test('deve criar um FirebaseAuthRepository', () {
      // 1. ARRANGE (Organizar)
      // Criamos um "ProviderContainer" que é um ambiente de teste do Riverpod.
      // E dizemos a ele para "sobrescrever" (override) o provider do firebase
      // para usar nossa classe FAKE (MockFirebaseAuth) em vez do real.
      final container = ProviderContainer(
        overrides: [
          firebaseAuthProvider.overrideWithValue(MockFirebaseAuth()),
        ],
      );

      // 2. ACT (Agir)
      // Lemos o nosso provider principal, o 'authRepositoryProvider'.
      // Internamente, ele vai pedir pelo 'firebaseAuthProvider',
      // mas o container vai entregar o nosso 'MockFirebaseAuth'.
      final repository = container.read(authRepositoryProvider);

      // 3. ASSERT (Verificar)
      // Verificamos se o provider realmente criou a instância correta,
      // que é o 'FirebaseAuthRepository' (a classe que depende do Firebase).
      expect(repository, isA<FirebaseAuthRepository>());
    });
  });
}
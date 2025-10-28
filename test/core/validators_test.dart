// Importa o pacote de teste
import 'package:flutter_test/flutter_test.dart';

// Importa a classe que você quer testar
import '../../lib/core/validators.dart'; // Ajuste para importação relativa ao arquivo de teste
void main() {

  // group() é opcional, mas ótimo para organizar testes
  group('Testes do Validators', () {

    // test() define um caso de teste individual
    test('isEmailValid deve retornar falso para email vazio', () {

      // 1. ARRANGE (Organizar): Prepara os dados do teste
      final email = '';

      // 2. ACT (Agir): Executa a função que está sendo testada
      final result = Validators.isEmailValid(email);

      // 3. ASSERT (Verificar): Checa se o resultado é o esperado
      expect(result, false);
    });

    test('isEmailValid deve retornar falso para email sem @', () {
      // ARRANGE
      final email = 'teste.com';

      // ACT
      final result = Validators.isEmailValid(email);

      // ASSERT
      expect(result, false);
    });

    test('isEmailValid deve retornar verdadeiro para email válido', () {
      // ARRANGE
      final email = 'teste@email.com';

      // ACT
      final result = Validators.isEmailValid(email);

      // ASSERT
      expect(result, true);
    });
  });
}
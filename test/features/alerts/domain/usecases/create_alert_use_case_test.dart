import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/core/di/alert_providers.dart';
import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';

class MockAlertRepository extends Mock implements AlertRepository {}

void main(){
  late MockAlertRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockAlertRepository();
    container = ProviderContainer(
      overrides: [
        alertRepositoryProvider.overrideWithValue(repository)
      ]
    );
    addTearDown(container.dispose);
  },);
}
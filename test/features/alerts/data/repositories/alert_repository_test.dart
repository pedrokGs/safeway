import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/core/di/alert_providers.dart';
import 'package:safeway/features/alerts/data/datasources/alert_remote_datasource.dart';

class MockAlertDataSource extends Mock implements AlertRemoteDataSource {}

void main(){
  late MockAlertDataSource dataSource;
  late ProviderContainer container;

  setUp(() {
    dataSource = MockAlertDataSource();
    container = ProviderContainer(
        overrides: [
          alertRemoteDataSourceProvider.overrideWithValue(dataSource)
        ]
    );
    addTearDown(container.dispose);
  },);
}
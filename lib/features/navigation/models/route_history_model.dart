import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

part 'route_history_model.g.dart';

@HiveType(typeId: 1)
class RouteHistoryModel extends HiveObject {
  @HiveField(0)
  final List<LatLng> routePoints;

  @HiveField(1)
  final double etaSeconds;

  @HiveField(2)
  final String transportMode;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final String origem;

  @HiveField(5)
  final String destino;

  RouteHistoryModel({
    required this.routePoints,
    required this.etaSeconds,
    required this.transportMode,
    required this.createdAt,
    required this.origem,
    required this.destino
  });
}

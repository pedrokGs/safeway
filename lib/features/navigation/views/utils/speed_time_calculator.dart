import 'package:latlong2/latlong.dart';

enum TransportMode { walking, bike, car }

/// velocidades médias em m/s
const Map<TransportMode, double> _baseSpeedMps = {
  TransportMode.walking: 5.0 / 3.6, // 5 km/h -> m/s
  TransportMode.bike: 15.0 / 3.6,   // 15 km/h -> m/s
  TransportMode.car: 40.0 / 3.6,    // 40 km/h -> m/s (exemplo urbano)
};

final Distance _distance = const Distance();

/// Retorna tempo estimado em segundos
double estimateEtaInSeconds({
  required List<LatLng> routePoints,
  required TransportMode transportMode,
  // multiplicador de tráfego (1.0 = sem tráfego, >1 significa mais lento)
  double trafficMultiplier = 1.0,
  // tempo extra por cruzamento/semáforo em segundos (média)
  double perIntersectionDelay = 30.0,
  // função opcional para sobrescrever velocidade por segmento (ex.: por tipo de via)
  double Function(LatLng a, LatLng b)? speedOverrideMps,
}) {
  if (routePoints.length < 2) return 0.0;
  double totalSeconds = 0.0;

  for (int i = 0; i < routePoints.length - 1; i++) {
    final a = routePoints[i];
    final b = routePoints[i + 1];

    final segmentDistance = _distance.as(LengthUnit.Meter, a, b); // metros
    final segmentSpeed = speedOverrideMps?.call(a, b) ?? _baseSpeedMps[transportMode]!;
    final segmentTime = segmentDistance / segmentSpeed; // segundos
    totalSeconds += segmentTime;
  }

  // estimativa de interseções: assume 1 interseção a cada N metros (exemplo: 300m)
  final routeLengthMeters = routePoints
      .asMap()
      .entries
      .fold<double>(0.0, (acc, e) {
    if (e.key == routePoints.length - 1) return acc;
    return acc + _distance.as(LengthUnit.Meter, routePoints[e.key], routePoints[e.key + 1]);
  });

  final intersectionsEstimate = (routeLengthMeters / 300.0).floor(); // ajuste localmente
  totalSeconds += intersectionsEstimate * perIntersectionDelay;

  // aplica tráfego e margem mínima de segurança (ex.: +10%)
  totalSeconds *= trafficMultiplier;
  totalSeconds *= 1.10;

  return totalSeconds;
}

/// Helper para formatar tempo
String formatDurationFromSeconds(double seconds) {
  final int s = seconds.round();
  final int hours = s ~/ 3600;
  final int minutes = (s % 3600) ~/ 60;
  final int secs = s % 60;
  if (hours > 0) return '${hours}h ${minutes}m';
  if (minutes > 0) return '${minutes}m ${secs}s';
  return '${secs}s';
}

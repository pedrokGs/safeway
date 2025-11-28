import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:safeway/common/widgets/custom_drawer.dart';
import 'package:safeway/core/configs/route_names.dart';

class AlertDetails extends StatefulWidget {
  const AlertDetails({super.key});

  @override
  State<AlertDetails> createState() => _AlertDetailsState();
}

class _AlertDetailsState extends State<AlertDetails> {
  String? currentAddress;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Checa se a localização está habilitada
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception("Serviço de localização desativado.");
    }

    // Permissão
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Permissão negada.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Permissão negada permanentemente.");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> _getStreetFromPosition(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final place = placemarks.first;

    return "${place.street}, ${place.subLocality ?? ''} ${place.subAdministrativeArea ?? ''}";
  }

  Future<String> getUserAddress() async {
    final position = await _getCurrentPosition();
    final street = await _getStreetFromPosition(position);
    return street;
  }

  Future<void> _loadAddress() async {
    try {
      final address = await getUserAddress();
      setState(() => currentAddress = address);
    } catch (e) {
      setState(() => currentAddress = "Não foi possível obter localização.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // antes era 16
          child: Column(
            children: [
              // Cartão de sucesso
              Card(
                color: Colors.green[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14), // maior
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),  // maior
                  child: Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green[800], size: 38), // maior
                      const SizedBox(width: 16), // maior
                      Expanded(
                        child: Text(
                          "Alerta enviado à Polícia com sucesso!",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 19,                 // maior
                            color: Colors.green[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),  // antes era 24

              // Localização
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: theme.colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(20.0), // maior
                  child: Row(
                    children: [
                      Icon(Icons.location_on,
                          color: theme.colorScheme.primary,
                          size: 30), // maior
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Localização e dados enviados",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 18,   // maior
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currentAddress ?? "Carregando localização...",
                              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Suporte
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: theme.colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Icon(Icons.phone,
                          color: theme.colorScheme.primary,
                          size: 30),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ações e Suporte",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                "Ligar para a Polícia",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              subtitle: Text(
                                "(Ouvir status) - 190",
                                style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botão maior
              SizedBox(
                width: double.infinity,
                height: 56, // maior (antes 48)
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => context.goNamed(RouteNames.home),
                  child: Text(
                    "CANCELAR ALERTA",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 18,            // maior
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Text(
                "Apenas se o alerta tiver sido acionado por engano",
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

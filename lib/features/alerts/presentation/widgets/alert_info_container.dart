import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:safeway/core/utils/convert_risk_to_color.dart';
import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';

class AlertInfoContainer extends StatelessWidget {
  final AlertEntity alertEntity;

  const AlertInfoContainer({required this.alertEntity, super.key});

  Future<String?> getLocationAdress() async {
    final List<Placemark> placemarks = await placemarkFromCoordinates(alertEntity.latitude, alertEntity.longitude);
    return placemarks.first.street;
  }

  @override
  Widget build(BuildContext context) {
    
    final dateFormatted = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(alertEntity.data);

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            alertEntity.titulo,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            alertEntity.descricao,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _InfoChip(
                  label: 'Risco',
                  value: alertEntity.risco.name.toUpperCase(),
                  color: alertRiskToColor(alertEntity.risco),
                ),
              ),
              Expanded(
                child: _InfoChip(
                  label: 'Tipo',
                  value: alertEntity.tipo.name,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Data: $dateFormatted',
            style: Theme.of(context).textTheme.bodyMedium
          ),
          const SizedBox(height: 10),
          FutureBuilder<String?>(
            future: getLocationAdress(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(
                  'Endereço: carregando...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)
                );
              } else if (snapshot.hasError) {
                return  Text(
                  'Endereço: erro ao carregar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent)
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                return Text(
                  'Endereço: ${snapshot.data}',
                  style: Theme.of(context).textTheme.bodyMedium
                );
              } else {
                return  Text(
                  'Endereço: não disponível',
                  style: Theme.of(context).textTheme.bodyMedium
                );
              }
            },
          ),

        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color.withOpacity(0.2),
      label: Text(
        '$label: $value',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

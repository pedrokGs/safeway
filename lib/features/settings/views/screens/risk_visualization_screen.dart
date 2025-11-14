import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/common/widgets/custom_drawer.dart';

import '../../../../core/di/alert_providers.dart';
import '../../../alerts/domain/enums/alert_risk.dart';
import '../../../alerts/domain/enums/alert_type.dart';

class RiskVisualizationScreen extends ConsumerStatefulWidget {
  const RiskVisualizationScreen({super.key});

  @override
  RiskVisualizationScreenState createState() => RiskVisualizationScreenState();
}

class RiskVisualizationScreenState extends ConsumerState<RiskVisualizationScreen> {
  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(alertFilterProvider);
    final notifier = ref.read(alertFilterProvider.notifier);

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
        title: Text(
          'Visualização de Riscos',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ============================
          //      TIPOS DE ALERTA
          // ============================
          Text(
            "Tipos de Alerta",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          ...AlertType.values.map((type) {
            final active = filter.categorias.contains(type);

            return SwitchListTile(
              title: Text(type.name.toUpperCase(), style: Theme.of(context).textTheme.bodyLarge,),
              value: active,
              onChanged: (_) => notifier.toggleCategoria(type),
            );
          }),

          const SizedBox(height: 30),

          // ============================
          //      NÍVEL DE RISCO
          // ============================
          Text(
            "Nível de Risco",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          ...AlertRisk.values.map((risk) {
            final active = filter.riscos.contains(risk);

            return SwitchListTile(
              title: Text(risk.name.toUpperCase(), style: Theme.of(context).textTheme.bodyLarge),
              value: active,
              onChanged: (_) => notifier.toggleRisco(risk),
            );
          }),

          const SizedBox(height: 30),

          // Botão limpar filtros
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer
            ),
            onPressed: () => notifier.clear(),
            child: const Text("Limpar Filtros"),
          )
        ],
      ),
    );
  }
}

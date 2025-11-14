import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:safeway/core/di/alert_providers.dart';
import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'package:safeway/features/alerts/domain/enums/alert_risk.dart';
import 'package:safeway/features/alerts/domain/enums/alert_type.dart';

class AlertFormScreen extends ConsumerStatefulWidget {
  final LatLng latLng;
  const AlertFormScreen({super.key, required this.latLng});

  @override
  ConsumerState<AlertFormScreen> createState() => _AlertFormScreenState();
}

class _AlertFormScreenState extends ConsumerState<AlertFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  AlertType? _tipo;
  AlertRisk? _risco;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final notifier = ref.read(alertFormNotifierProvider.notifier);
    final state = ref.read(alertFormNotifierProvider);

    if (_formKey.currentState!.validate()) {
      final alert = AlertEntity(
        uid: '',
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        tipo: _tipo!,
        risco: _risco!,
        data: DateTime.now(),
        latitude: widget.latLng.latitude,
        longitude: widget.latLng.longitude,
        userId: '',
      );

      await notifier.createAlert(alert);

      if (mounted && state.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerta criado com sucesso!')),
        );
        context.goNamed('home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(alertFormNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Novo Alerta',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: BackButton(onPressed: () => context.goNamed('home'),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- TÍTULO ---
              TextFormField(
                controller: _tituloController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Informe o título'
                    : null,
              ),
              const SizedBox(height: 16),

              // --- DESCRIÇÃO ---
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Informe a descrição'
                    : null,
              ),
              const SizedBox(height: 16),

              // --- TIPO ---
              DropdownButtonFormField<AlertType>(
                initialValue: _tipo,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Tipo de Alerta',
                  border: OutlineInputBorder(),
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                items: AlertType.values.map((t) {
                  final String name = t.name.replaceRange(
                    0,
                    1,
                    t.name[0].toUpperCase(),
                  );
                  return DropdownMenuItem(value: t, child: Text(name));
                }).toList(),
                onChanged: (value) => setState(() => _tipo = value),
                validator: (value) =>
                    value == null ? 'Selecione um tipo' : null,
              ),
              const SizedBox(height: 16),

              // --- RISCO ---
              DropdownButtonFormField<AlertRisk>(
                initialValue: _risco,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Nível de Risco',
                  border: OutlineInputBorder(),
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                items: AlertRisk.values.map((r) {
                  final String name = r.name.replaceRange(
                    0,
                    1,
                    r.name[0].toUpperCase(),
                  );
                  return DropdownMenuItem(value: r, child: Text(name));
                }).toList(),
                onChanged: (value) => setState(() => _risco = value),
                validator: (value) =>
                    value == null ? 'Selecione o risco' : null,
              ),
              const SizedBox(height: 16),

              // --- BOTÃO SALVAR ---
              ElevatedButton.icon(
                onPressed: formState.isLoading ? null : _submitForm,
                icon: formState.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  formState.isLoading ? 'Salvando...' : 'Salvar Alerta',
                ),
              ),

              if (formState.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  formState.error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

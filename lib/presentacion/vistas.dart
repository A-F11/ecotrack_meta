import 'package:flutter/material.dart';

import '../dominio/consumo.dart';

class FormularioRegistro extends StatefulWidget {
  const FormularioRegistro({
    super.key,
    required this.alGuardar,
    required this.error,
    required this.guardando,
  });

  final Future<bool> Function(String laboratorio, String litros) alGuardar;
  final String? error;
  final bool guardando;

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  final _litros = TextEditingController();
  String _laboratorio = laboratoriosUtez.first;

  @override
  void dispose() {
    _litros.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final ok = await widget.alGuardar(_laboratorio, _litros.text);
    if (!ok || !mounted) return;
    _litros.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consumo guardado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _laboratorio,
          decoration: const InputDecoration(labelText: 'Laboratorio'),
          items: [
            for (final lab in laboratoriosUtez)
              DropdownMenuItem(value: lab, child: Text(lab)),
          ],
          onChanged: (lab) => setState(() => _laboratorio = lab!),
        ),
        TextField(
          key: const Key('litros'),
          controller: _litros,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Litros',
            errorText: widget.error,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: widget.guardando ? null : _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class ListaHistorial extends StatelessWidget {
  const ListaHistorial({
    super.key,
    required this.consumos,
    required this.total,
  });

  final List<Consumo> consumos;
  final double total;

  @override
  Widget build(BuildContext context) {
    if (consumos.isEmpty) {
      return const Center(child: Text('Sin consumos'));
    }
    return ListView(
      children: [
        ListTile(
          title: Text('Total: ${total.toStringAsFixed(1)} L'),
          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        for (final consumo in consumos)
          ListTile(
            leading: const Icon(Icons.water_drop),
            title: Text(consumo.laboratorio),
            subtitle: Text('${consumo.litros} L'),
          ),
      ],
    );
  }
}

class PanelMeta extends StatelessWidget {
  const PanelMeta({
    super.key,
    required this.usado,
    required this.meta,
    required this.avance,
    required this.superada,
    required this.alSubir,
    required this.alBajar,
  });

  final double usado;
  final double meta;
  final double avance;
  final bool superada;
  final VoidCallback alSubir;
  final VoidCallback alBajar;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Usado: ${usado.toStringAsFixed(1)} de ${meta.toStringAsFixed(1)} L',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(value: avance.clamp(0.0, 1.0).toDouble()),
        const SizedBox(height: 16),
        Text(superada ? 'Te pasaste de la meta' : 'Dentro de la meta'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              key: const Key('bajarMeta'),
              onPressed: alBajar,
              icon: const Icon(Icons.remove),
              label: const Text('Bajar meta'),
            ),
            FilledButton.icon(
              key: const Key('subirMeta'),
              onPressed: alSubir,
              icon: const Icon(Icons.add),
              label: const Text('Subir meta'),
            ),
          ],
        ),
      ],
    );
  }
}

class PantallasEcoTrack extends StatefulWidget {
  const PantallasEcoTrack({
    super.key,
    required this.titulo,
    required this.registro,
    required this.historial,
    required this.meta,
  });

  final String titulo;
  final Widget registro;
  final Widget historial;
  final Widget meta;

  @override
  State<PantallasEcoTrack> createState() => _PantallasEcoTrackState();
}

class _PantallasEcoTrackState extends State<PantallasEcoTrack> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: IndexedStack(
        index: _indice,
        children: [widget.registro, widget.historial, widget.meta],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.add), label: 'Registro'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
          NavigationDestination(icon: Icon(Icons.flag), label: 'Meta'),
        ],
      ),
    );
  }
}

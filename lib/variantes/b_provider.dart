import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../datos/consumo_repository.dart';
import '../presentacion/consumos_view_model.dart';
import '../presentacion/vistas.dart';

class AppProvider extends StatelessWidget {
  const AppProvider({super.key, required this.repositorio});

  final ConsumoRepository repositorio;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ConsumosViewModel>(
      create: (_) {
        final vm = ConsumosViewModel(repositorio);
        vm.cargar();
        return vm;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
        home: const PantallaProvider(),
      ),
    );
  }
}

class PantallaProvider extends StatelessWidget {
  const PantallaProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return const PantallasEcoTrack(
      titulo: 'B · provider',
      registro: RegistroProvider(),
      historial: HistorialProvider(),
      meta: MetaProvider(),
    );
  }
}

class RegistroProvider extends StatelessWidget {
  const RegistroProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConsumosViewModel>();
    return FormularioRegistro(
      alGuardar: (laboratorio, litrosTexto) {
        return context
            .read<ConsumosViewModel>()
            .guardar(laboratorio, litrosTexto);
      },
      error: vm.error,
      guardando: vm.guardando,
    );
  }
}

class HistorialProvider extends StatelessWidget {
  const HistorialProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConsumosViewModel>();
    return ListaHistorial(consumos: vm.consumos, total: vm.total);
  }
}

class MetaProvider extends StatelessWidget {
  const MetaProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConsumosViewModel>();
    return PanelMeta(
      usado: vm.total,
      meta: vm.meta,
      avance: vm.avance,
      superada: vm.metaSuperada,
      alSubir: context.read<ConsumosViewModel>().subirMeta,
      alBajar: context.read<ConsumosViewModel>().bajarMeta,
    );
  }
}

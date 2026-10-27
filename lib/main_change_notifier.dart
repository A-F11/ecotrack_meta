import 'package:flutter/material.dart';

import 'datos/memoria_consumo_repository.dart';
import 'variantes/a_change_notifier.dart';

void main() {
  runApp(AppChangeNotifier(repositorio: MemoriaConsumoRepository()));
}

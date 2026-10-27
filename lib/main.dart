import 'package:flutter/material.dart';

import 'datos/memoria_consumo_repository.dart';
import 'variantes/b_provider.dart';

void main() {
  runApp(AppProvider(repositorio: MemoriaConsumoRepository()));
}

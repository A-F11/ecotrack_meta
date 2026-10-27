import 'package:ecotrack_meta/datos/consumo_repository.dart';
import 'package:ecotrack_meta/datos/memoria_consumo_repository.dart';
import 'package:ecotrack_meta/dominio/consumo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empieza vacio', () async {
    final repo = MemoriaConsumoRepository();
    expect(await repo.todos(), isEmpty);
  });

  test('guarda y devuelve los consumos', () async {
    final repo = MemoriaConsumoRepository();
    await repo.guardar(const Consumo(laboratorio: 'Lab Química', litros: 12.5));
    final todos = await repo.todos();
    expect(todos, hasLength(1));
    expect(todos.single.laboratorio, 'Lab Química');
    expect(todos.single.litros, 12.5);
  });

  test('todos regresa una lista no modificable', () async {
    final repo = MemoriaConsumoRepository();
    await repo.guardar(const Consumo(laboratorio: 'Lab Redes', litros: 3));
    final todos = await repo.todos();
    expect(
      () => todos.add(const Consumo(laboratorio: 'Lab Física', litros: 1)),
      throwsUnsupportedError,
    );
  });

  test('cumple el contrato ConsumoRepository', () async {
    final ConsumoRepository repo = MemoriaConsumoRepository();
    await repo.guardar(const Consumo(laboratorio: 'Lab Física', litros: 7));
    expect((await repo.todos()).single.litros, 7);
  });
}

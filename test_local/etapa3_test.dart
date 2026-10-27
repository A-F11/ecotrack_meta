import 'dart:async';

import 'package:ecotrack_meta/datos/consumo_repository.dart';
import 'package:ecotrack_meta/dominio/consumo.dart';
import 'package:ecotrack_meta/presentacion/consumos_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class RepoFalso implements ConsumoRepository {
  RepoFalso([this.iniciales = const []]);

  final List<Consumo> iniciales;
  final List<Consumo> guardados = [];
  Completer<void>? bloqueo;

  @override
  Future<void> guardar(Consumo consumo) async {
    if (bloqueo != null) await bloqueo!.future;
    guardados.add(consumo);
  }

  @override
  Future<List<Consumo>> todos() async {
    return List<Consumo>.unmodifiable([...iniciales, ...guardados]);
  }
}

void main() {
  test('estado inicial', () {
    final vm = ConsumosViewModel(RepoFalso());
    expect(vm.consumos, isEmpty);
    expect(vm.error, isNull);
    expect(vm.guardando, isFalse);
    expect(vm.meta, 100.0);
    expect(vm.total, 0.0);
    expect(vm.avance, 0.0);
    expect(vm.metaSuperada, isFalse);
  });

  test('total, avance y metaSuperada son derivados', () {
    final vm = ConsumosViewModel(RepoFalso());
    vm.consumos = const [
      Consumo(laboratorio: 'Lab Química', litros: 60),
      Consumo(laboratorio: 'Lab Redes', litros: 50),
    ];
    expect(vm.total, 110.0);
    expect(vm.avance, 1.0);
    expect(vm.metaSuperada, isTrue);
  });

  test('cargar lee del repositorio y avisa', () async {
    final vm = ConsumosViewModel(
      RepoFalso(const [Consumo(laboratorio: 'Lab Física', litros: 4)]),
    );
    var avisos = 0;
    vm.addListener(() => avisos++);
    await vm.cargar();
    expect(vm.consumos.single.litros, 4);
    expect(avisos, 1);
  });

  test('guardar valido guarda, recarga y avisa', () async {
    final repo = RepoFalso();
    final vm = ConsumosViewModel(repo);
    var avisos = 0;
    vm.addListener(() => avisos++);

    final ok = await vm.guardar('Lab Química', '12.5');

    expect(ok, isTrue);
    expect(repo.guardados.single.litros, 12.5);
    expect(vm.consumos.single.laboratorio, 'Lab Química');
    expect(vm.error, isNull);
    expect(vm.guardando, isFalse);
    expect(avisos, 2);
  });

  test('acepta coma decimal y espacios', () async {
    final repo = RepoFalso();
    final vm = ConsumosViewModel(repo);
    expect(await vm.guardar('Lab Redes', ' 12,5 '), isTrue);
    expect(repo.guardados.single.litros, 12.5);
  });

  test('guardar invalido no toca el repositorio', () async {
    final repo = RepoFalso();
    final vm = ConsumosViewModel(repo);

    expect(await vm.guardar('Lab Redes', '0'), isFalse);
    expect(vm.error, 'Los litros deben ser mayores que cero');
    expect(vm.guardando, isFalse);
    expect(repo.guardados, isEmpty);

    expect(await vm.guardar('Lab Redes', 'abc'), isFalse);
    expect(vm.error, 'Escribe los litros con número');
    expect(repo.guardados, isEmpty);
  });

  test('guardando es true mientras el repositorio tarda', () async {
    final repo = RepoFalso()..bloqueo = Completer<void>();
    final vm = ConsumosViewModel(repo);

    final futuro = vm.guardar('Lab Física', '5');
    expect(vm.guardando, isTrue);

    repo.bloqueo!.complete();
    expect(await futuro, isTrue);
    expect(vm.guardando, isFalse);
  });

  test('subirMeta y bajarMeta cambian un paso y avisan', () {
    final vm = ConsumosViewModel(RepoFalso());
    var avisos = 0;
    vm.addListener(() => avisos++);

    vm.subirMeta();
    expect(vm.meta, 110);
    vm.bajarMeta();
    expect(vm.meta, 100);
    expect(avisos, 2);
  });

  test('bajarMeta nunca baja del minimo', () {
    final vm = ConsumosViewModel(RepoFalso());
    for (var i = 0; i < 20; i++) {
      vm.bajarMeta();
    }
    expect(vm.meta, 10);
  });

  test('subirMeta actualiza avance y metaSuperada', () {
    final vm = ConsumosViewModel(RepoFalso());
    vm.consumos = const [Consumo(laboratorio: 'Lab Química', litros: 105)];
    expect(vm.metaSuperada, isTrue);
    vm.subirMeta();
    expect(vm.meta, 110);
    expect(vm.metaSuperada, isFalse);
    expect(vm.avance, closeTo(105 / 110, 1e-9));
  });
}

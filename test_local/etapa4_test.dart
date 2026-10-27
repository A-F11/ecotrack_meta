import 'dart:async';

import 'package:ecotrack_meta/datos/consumo_repository.dart';
import 'package:ecotrack_meta/datos/memoria_consumo_repository.dart';
import 'package:ecotrack_meta/dominio/consumo.dart';
import 'package:ecotrack_meta/variantes/a_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class RepoEspia implements ConsumoRepository {
  final List<Consumo> recibidos = [];

  @override
  Future<void> guardar(Consumo consumo) async => recibidos.add(consumo);

  @override
  Future<List<Consumo>> todos() async => List.unmodifiable(recibidos);
}

class RepoLento implements ConsumoRepository {
  final completer = Completer<void>();
  final List<Consumo> recibidos = [];

  @override
  Future<void> guardar(Consumo consumo) async {
    await completer.future;
    recibidos.add(consumo);
  }

  @override
  Future<List<Consumo>> todos() async => List.unmodifiable(recibidos);
}

Future<void> montar(WidgetTester tester, ConsumoRepository repo) async {
  await tester.pumpWidget(AppChangeNotifier(repositorio: repo));
  await tester.pumpAndSettle();
}

Future<void> escribirYGuardar(WidgetTester tester, String litros) async {
  await tester.enterText(find.byKey(const Key('litros')), litros);
  await tester.tap(find.text('Guardar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra titulo y las tres pestanas', (tester) async {
    await montar(tester, MemoriaConsumoRepository());
    expect(find.text('A · ChangeNotifier'), findsOneWidget);
    expect(find.text('Registro'), findsOneWidget);
    expect(find.text('Historial'), findsOneWidget);
    expect(find.text('Meta'), findsOneWidget);
  });

  testWidgets('guardar muestra snackbar y limpia el campo', (tester) async {
    await montar(tester, MemoriaConsumoRepository());
    await escribirYGuardar(tester, '12.5');
    expect(find.text('Consumo guardado'), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const Key('litros'))).controller!.text, isEmpty);
  });

  testWidgets('dato compartido: Registro guarda e Historial lo ve', (tester) async {
    await montar(tester, MemoriaConsumoRepository());
    await escribirYGuardar(tester, '12.5');
    await tester.tap(find.text('Historial'));
    await tester.pumpAndSettle();
    expect(find.text('Total: 12.5 L'), findsOneWidget);
    expect(find.text('Lab Química'), findsOneWidget);
  });

  testWidgets('meta: dentro y fuera de la meta', (tester) async {
    await montar(tester, MemoriaConsumoRepository());
    await tester.tap(find.text('Meta'));
    await tester.pumpAndSettle();
    expect(find.text('Usado: 0.0 de 100.0 L'), findsOneWidget);
    expect(find.text('Dentro de la meta'), findsOneWidget);

    await tester.tap(find.text('Registro'));
    await tester.pumpAndSettle();
    await escribirYGuardar(tester, '120');
    await tester.tap(find.text('Meta'));
    await tester.pumpAndSettle();
    expect(find.text('Usado: 120.0 de 100.0 L'), findsOneWidget);
    expect(find.text('Te pasaste de la meta'), findsOneWidget);
  });

  testWidgets('botones de meta suben y bajan con sus llaves', (tester) async {
    await montar(tester, MemoriaConsumoRepository());
    await tester.tap(find.text('Meta'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('subirMeta')));
    await tester.pumpAndSettle();
    expect(find.text('Usado: 0.0 de 110.0 L'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bajarMeta')));
    await tester.pumpAndSettle();
    expect(find.text('Usado: 0.0 de 100.0 L'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bajarMeta')));
    await tester.pumpAndSettle();
    expect(find.text('Usado: 0.0 de 90.0 L'), findsOneWidget);
  });

  testWidgets('error de validacion visible y no guarda', (tester) async {
    final repo = RepoEspia();
    await montar(tester, repo);
    await escribirYGuardar(tester, '0');
    expect(find.text('Los litros deben ser mayores que cero'), findsOneWidget);
    expect(repo.recibidos, isEmpty);
  });

  testWidgets('boton desactivado mientras guarda', (tester) async {
    final repo = RepoLento();
    await montar(tester, repo);

    await tester.enterText(find.byKey(const Key('litros')), '5');
    await tester.tap(find.text('Guardar'));
    await tester.pump();

    final boton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Guardar'),
    );
    expect(boton.onPressed, isNull);

    repo.completer.complete();
    await tester.pumpAndSettle();
    expect(repo.recibidos.single.litros, 5);
  });

  testWidgets('sustitucion: el repositorio espia recibe el consumo', (tester) async {
    final repo = RepoEspia();
    await montar(tester, repo);
    await escribirYGuardar(tester, '7,5');
    expect(repo.recibidos.single.litros, 7.5);
  });

  testWidgets('al desmontar libera el ViewModel sin errores', (tester) async {
    await montar(tester, MemoriaConsumoRepository());
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}

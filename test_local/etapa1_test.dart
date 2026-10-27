import 'package:ecotrack_meta/dominio/consumo.dart';
import 'package:ecotrack_meta/dominio/meta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dominio/consumo', () {
    test('laboratoriosUtez tiene los tres laboratorios', () {
      expect(laboratoriosUtez, ['Lab Química', 'Lab Redes', 'Lab Física']);
    });

    test('Consumo guarda laboratorio y litros', () {
      const c = Consumo(laboratorio: 'Lab Redes', litros: 12.5);
      expect(c.laboratorio, 'Lab Redes');
      expect(c.litros, 12.5);
    });

    test('validarLitros rechaza null', () {
      expect(validarLitros(null), 'Escribe los litros con número');
    });

    test('validarLitros rechaza cero y negativos', () {
      expect(validarLitros(0), 'Los litros deben ser mayores que cero');
      expect(validarLitros(-1), 'Los litros deben ser mayores que cero');
    });

    test('validarLitros rechaza mas de 10000', () {
      expect(validarLitros(10000.1), 'Los litros superan el tope de 10000');
    });

    test('validarLitros acepta valores validos', () {
      expect(validarLitros(0.1), isNull);
      expect(validarLitros(12.5), isNull);
      expect(validarLitros(10000), isNull);
    });
  });

  group('dominio/meta', () {
    test('constantes de la meta', () {
      expect(metaInicial, 100.0);
      expect(pasoMeta, 10.0);
      expect(metaMinima, 10.0);
    });

    test('ajustarMeta suma y respeta el minimo', () {
      expect(ajustarMeta(100, 10), 110.0);
      expect(ajustarMeta(100, -10), 90.0);
      expect(ajustarMeta(10, -10), 10.0);
      expect(ajustarMeta(15, -10), 10.0);
    });

    test('avanceDeMeta calcula fraccion y topa en 1', () {
      expect(avanceDeMeta(total: 50, meta: 100), 0.5);
      expect(avanceDeMeta(total: 100, meta: 100), 1.0);
      expect(avanceDeMeta(total: 150, meta: 100), 1.0);
      expect(avanceDeMeta(total: 0, meta: 100), 0.0);
    });

    test('avanceDeMeta cuida la division entre cero', () {
      final avance = avanceDeMeta(total: 50, meta: 0);
      expect(avance.isNaN, isFalse);
      expect(avance, inInclusiveRange(0, 1));
    });
  });
}

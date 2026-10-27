# EcoTrack Meta — `ChangeNotifier` y provider desde cero

Implementación de la práctica **EcoTrack Meta**: una app Flutter con tres pestañas
(Registro, Historial y Meta) que comparten el mismo estado mediante MVVM, cableada
dos veces sobre el mismo `ConsumosViewModel`:

- **A · ChangeNotifier puro:** el ViewModel se pasa por constructor.
- **B · provider:** el ViewModel se cuelga del árbol con `ChangeNotifierProvider`.

## Estado del proyecto

| Verificación | Resultado |
|---|---|
| `flutter analyze` | Sin issues |
| Pruebas locales (`test_local/`) | **40 / 40 en verde** |
| Pruebas oficiales del kit (`kit_alumno/`) | Pendientes: el kit no está en el equipo |
| `verificar_estado.sh` | Pendiente junto con el kit |

## Estructura

```
lib/
├── dominio/
│   ├── consumo.dart                 Consumo, laboratoriosUtez y validarLitros
│   └── meta.dart                    Constantes, ajustarMeta y avanceDeMeta
├── datos/
│   ├── consumo_repository.dart      Contrato abstracto
│   └── memoria_consumo_repository.dart
├── presentacion/
│   ├── consumos_view_model.dart     Estado compartido + ChangeNotifier
│   └── vistas.dart                  FormularioRegistro, ListaHistorial, PanelMeta,
│                                    PantallasEcoTrack
├── variantes/
│   ├── a_change_notifier.dart       AppChangeNotifier + adaptadores CN
│   └── b_provider.dart              AppProvider + adaptadores Provider
├── main.dart                        Arranca la variante B (provider)
└── main_change_notifier.dart        Arranca la variante A (ChangeNotifier)
docs/
└── estado.md                        Comparación de gestores con evidencia
test_local/                          Pruebas de verificación propias (40)
```

## Cómo correr

```bash
flutter pub get

# Variante B · provider
flutter run

# Variante A · ChangeNotifier puro
flutter run -t lib/main_change_notifier.dart

# Verificación local
flutter analyze
flutter test test_local -r expanded
```

Cuando esté disponible el kit oficial:

```bash
cp -R ../kit_alumno/test .
cp ../kit_alumno/verificar_estado.sh .
flutter test
bash verificar_estado.sh
```

## Pruebas locales

Estas pruebas viven en `test_local/` y **no sustituyen** a las 35 pruebas oficiales
del kit. Sirven como evidencia de que cada etapa cumple los contratos de la página.

<details>
<summary><strong>Etapa 1 — Dominio</strong> · <code>test_local/etapa1_test.dart</code> · 10 pruebas</summary>

- `laboratoriosUtez tiene los tres laboratorios`
- `Consumo guarda laboratorio y litros`
- `validarLitros rechaza null`
- `validarLitros rechaza cero y negativos`
- `validarLitros rechaza mas de 10000`
- `validarLitros acepta valores validos`
- `constantes de la meta`
- `ajustarMeta suma y respeta el minimo`
- `avanceDeMeta calcula fraccion y topa en 1`
- `avanceDeMeta cuida la division entre cero`

</details>

<details>
<summary><strong>Etapa 2 — Datos</strong> · <code>test_local/etapa2_test.dart</code> · 4 pruebas</summary>

- `empieza vacio`
- `guarda y devuelve los consumos`
- `todos regresa una lista no modificable`
- `cumple el contrato ConsumoRepository`

</details>

<details>
<summary><strong>Etapa 3 — ViewModel</strong> · <code>test_local/etapa3_test.dart</code> · 10 pruebas</summary>

- `estado inicial`
- `total, avance y metaSuperada son derivados`
- `cargar lee del repositorio y avisa`
- `guardar valido guarda, recarga y avisa`
- `acepta coma decimal y espacios`
- `guardar invalido no toca el repositorio`
- `guardando es true mientras el repositorio tarda`
- `subirMeta y bajarMeta cambian un paso y avisan`
- `bajarMeta nunca baja del minimo`
- `subirMeta actualiza avance y metaSuperada`

</details>

<details>
<summary><strong>Etapa 4 — Vistas y variante A</strong> · <code>test_local/etapa4_test.dart</code> · 9 pruebas</summary>

- `muestra titulo y las tres pestanas`
- `guardar muestra snackbar y limpia el campo`
- `dato compartido: Registro guarda e Historial lo ve`
- `meta: dentro y fuera de la meta`
- `botones de meta suben y bajan con sus llaves`
- `error de validacion visible y no guarda`
- `boton desactivado mientras guarda`
- `sustitucion: el repositorio espia recibe el consumo`
- `al desmontar libera el ViewModel sin errores`

</details>

<details>
<summary><strong>Etapa 5 — Variante B con provider</strong> · <code>test_local/etapa5_test.dart</code> · 7 pruebas</summary>

- `muestra titulo B y las tres pestanas`
- `dato compartido entre las tres pestanas`
- `los callbacks usan read y actualizan la meta`
- `aviso de meta rebasada`
- `error de validacion y repositorio intacto`
- `el boton se desactiva mientras guarda`
- `sustitucion: otra fuente de datos, mismas pantallas`

</details>

### Última ejecución

```
00:02 +40: All tests passed!
```

## Pruebas oficiales pendientes

| Archivo del kit | Pruebas esperadas |
|---|---|
| `test/etapa1_dominio_test.dart` | 10 |
| `test/etapa2_datos_test.dart` | 4 |
| `test/etapa3_viewmodel_test.dart` | 11 |
| `test/etapa4_change_notifier_test.dart` | 5 |
| `test/etapa5_provider_test.dart` | 5 |
| **Total** | **35** |

## Commits por etapa

| Etapa | Commit |
|---|---|
| 0 | `chore: proyecto base con kit de pruebas` |
| 1 | `feat(dominio): consumo y reglas de meta` |
| 2 | `feat(datos): contrato y repositorio en memoria` |
| 3 | `feat(presentacion): ConsumosViewModel con ChangeNotifier` |
| 4 | `feat(variante-a): vistas tontas y cableado con ChangeNotifier` |
| 5 | `feat(variante-b): cableado con provider sobre el mismo ViewModel` |
| 6 | `docs: comparación de gestores con evidencia` |

## Notas de implementación

- `vistas.dart` no importa el ViewModel, ni provider, ni `datos/`: solo `material.dart`
  y `dominio/consumo.dart`.
- El ViewModel depende del contrato `ConsumoRepository`, nunca de la implementación
  en memoria.
- `total`, `avance` y `metaSuperada` son getters derivados; no se guardan como campos.
- `avanceDeMeta` evita la división entre cero: si `meta <= 0` regresa `0.0`.
- Solo `main.dart` y `main_change_notifier.dart` conocen `MemoriaConsumoRepository`.

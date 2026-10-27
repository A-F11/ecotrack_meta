# Gestión de estado — EcoTrack Meta

**Equipo:** A-F11
**Fecha:** 26 de octubre de 2026

## Tipos de estado en nuestro código

| Dato | Tipo (efímero, compartido, derivado, persistido) | Dónde vive |
|---|---|---|
| Pestaña activa | Efímero | `_PantallasEcoTrackState._indice` en `lib/presentacion/vistas.dart`, cambiado con `setState`. |
| Texto del campo de litros | Efímero | `_FormularioRegistroState._litros`, un `TextEditingController` en `lib/presentacion/vistas.dart`. |
| consumos y meta | Compartido | Campos `consumos` y `meta` de `ConsumosViewModel` en `lib/presentacion/consumos_view_model.dart`. |
| total y metaSuperada | Derivado | Getters `total`, `avance` y `metaSuperada` del ViewModel; no se guardan en campos. |
| Lo que regresa todos() | Persistido | `MemoriaConsumoRepository._consumos`, expuesto por `todos()` en `lib/datos/memoria_consumo_repository.dart`. |

## Criterios

| Criterio | A · ChangeNotifier puro | B · provider |
|---|---|---|
| Dato compartido | El mismo `_vm` se pasa a `RegistroCN`, `HistorialCN` y `MetaCN`, y cada uno escucha con `ListenableBuilder` (`lib/variantes/a_change_notifier.dart`). | Un solo `ChangeNotifierProvider<ConsumosViewModel>` arriba de `MaterialApp`; las tres pestañas lo leen con `context.watch` (`lib/variantes/b_provider.dart`). |
| Capas | `vistas.dart` solo importa `material.dart` y `dominio/consumo.dart`; el ViewModel depende del contrato `ConsumoRepository`. | Se reutilizan sin cambios `vistas.dart`, el ViewModel y el repositorio; solo cambia el cableado en `b_provider.dart`. |
| Encaje con el diagrama | Las flechas se ven como parámetros de constructor: `main_change_notifier.dart` crea el ViewModel y lo entrega a las vistas. | Las flechas se resuelven por el árbol: `AppProvider` crea el ViewModel y las vistas lo buscan con `provider`. |
| Constructores que reciben vm | Tres: `RegistroCN`, `HistorialCN` y `MetaCN` reciben `vm` (`lib/variantes/a_change_notifier.dart`). | Cero: `RegistroProvider`, `HistorialProvider` y `MetaProvider` solo reciben `super.key` (`lib/variantes/b_provider.dart`). |
| Quién libera el ViewModel | `_AppChangeNotifierState.dispose()` llama a `_vm.dispose()` porque ese State es su dueño. | `ChangeNotifierProvider` libera el ViewModel automáticamente al desmontarse; no escribimos `dispose()`. |
| Costo de adoptarla ahora | Bajo: no exige paquete extra y el cableado es explícito, pero cada pantalla nueva obliga a pasar `vm` por constructor. | Bajo: `provider` ya está en `pubspec.yaml` y `context.watch`/`context.read` evita propagar `vm`; el costo es depender del paquete y conocer su API. |
| Sustitución de la fuente de datos | `AppChangeNotifier` recibe `ConsumoRepository`; cambiar `MemoriaConsumoRepository` no toca las vistas (`lib/main_change_notifier.dart`). | `AppProvider` recibe el mismo contrato y solo `main.dart` conoce `MemoriaConsumoRepository`; las pantallas no cambian. |

## Elección

Elegimos: **B · provider**, porque el ViewModel se crea una sola vez arriba del árbol, las pantallas no arrastran `vm` por constructores y el `ChangeNotifierProvider` se encarga de liberarlo; además, agregar la pestaña Meta no exigió cambiar `vistas.dart` ni el ViewModel.

Se mantiene esta pieza del diagrama: el `ChangeNotifierProvider<ConsumosViewModel>` colgado arriba de `MaterialApp` en `lib/variantes/b_provider.dart`, con el ViewModel como único dueño del estado compartido.

Esta pieza es la que podría sustituirse después: `MemoriaConsumoRepository` por una implementación con API o base de datos que cumpla `ConsumoRepository`, cambiándola solo en `main.dart` o `main_change_notifier.dart`.

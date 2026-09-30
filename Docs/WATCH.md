# Apple Watch

App companion en `MyBarTrackWatch` (watchOS 10, embebida en la app iOS) + complicación en `DrinkTrackWatchWidget`.
El **iPhone es la fuente de verdad**: CoreData no se comparte con el reloj.

## Funcionalidad
- Resumen: cantidad, gasto y barra de presupuesto (mismos contadores acumulados que la app y el widget).
- Hasta 8 bebidas ordenadas por uso: tocar = +1, deslizar a la izquierda = −1 sobre esa bebida.
- Botón de deshacer: revierte la última bebida añadida desde el reloj.
- Vibración al superar el presupuesto.
- Complicación (`accessoryCircular`, `accessoryRectangular`, `accessoryInline`): contador y progreso del presupuesto.

## Sincronización (`Shared/Watch/`)
| Dirección | Mecanismo | Contenido |
|---|---|---|
| iPhone → Watch | `updateApplicationContext` | `WatchState` (gana el último) |
| Watch → iPhone | `transferUserInfo` (cola fiable, funciona offline) | `WatchCommand` (`add`/`undo` + id único) |

- `WidgetSync.refresh()` (iPhone) recalcula totales y publica al widget iOS y al Watch; no depende de ninguna vista, así que un comando del reloj funciona con la app en segundo plano.
- `WatchBridge` aplica los comandos con `CoreDataManager` y descarta ids ya procesados (últimos 500).
- Si el estado se envía antes de que `WCSession` se active se pierde: se reenvía al activarse (`onNeedsState`).
- El reloj guarda un `WidgetSnapshot` en el App Group `group.com.polidisio.MyBarTrack` (entitlement en la app del reloj y en la complicación) y recarga las timelines.

## Analítica
Solo la emite el iPhone: `consumption_added` con `source=watch` cuando el alta viene del reloj.

## Probar
- Simuladores emparejados (`xcrun simctl list pairs`): instalar la app iOS y `Watch/MyBarTrackWatch.app` en el reloj (`simctl install`).
- Los simuladores no permiten pulsar: la ruta reloj → iPhone se prueba en un reloj real.

## Versiones
`MARKETING_VERSION` y `CURRENT_PROJECT_VERSION` viven solo en `project.yml`; app, widget, reloj y complicación deben coincidir o App Store Connect rechaza la subida.

# Apple Watch v1 — plan

## Objetivo
Apuntar bebidas desde la muñeca sin sacar el iPhone. iPhone = fuente de verdad (CoreData sin tocar); Watch = mando ligero.

## Alcance v1
1. Lista de bebidas top con emoji + contador; tap = +1, botón deshacer última.
2. Resumen: cantidad, coste, progreso presupuesto (reusa `WidgetSnapshot`).
3. Complicación WidgetKit (accessory circular/rectangular: contador + anillo presupuesto).
4. Haptic al llegar a presupuesto ≥ 100 %.
Fuera de v1: gráficos, HealthKit, CoreData/CloudKit en watch, analytics propio en watch.

## Arquitectura
- WatchConnectivity (`WCSession`), un `WatchSyncService` en `Shared/`:
  - iPhone → Watch: `updateApplicationContext` con `WatchState { bebidas top N [id, emoji, count], snapshot }` (Codable, estado más reciente gana).
  - Watch → iPhone: `transferUserInfo` con `WatchCommand { id: UUID, kind: add|undo, bebidaID, ts }` (cola fiable offline).
- iPhone aplica el comando vía `ConsumicionViewModel`/`CoreDataManager.addConsumicion` (mismo camino → dispara `Analytics` y `updateWidgetSnapshot`). Idempotencia: guardar `command.id` procesados (Set en UserDefaults, cap 500) para descartar duplicados.
- Tras cada cambio en iPhone (`refreshTodayData`) → push `WatchState`.
- Complicación lee `WidgetSnapshot` copiada al App Group del watch (o recibida por WCSession y guardada en UserDefaults del watch; App Group no cruza dispositivos).

## Pasos
1. [x] `project.yml`: target `MyBarTrackWatch` (type `application`, platform watchOS, deploy 9.0, bundle `com.polidisio.MyBarTrack.watchkitapp`, `WKCompanionAppBundleIdentifier`), embed en app iOS; target `DrinkTrackWatchWidget` (app-extension watchOS) para complicación. Regenerar con xcodegen. Probar que scheme iOS sigue compilando.
2. [x] `Shared/WatchModels.swift` (WatchState, WatchCommand) + tests de codificación en `DrinkTrackTests`.
3. [x] `Shared/WatchSyncService.swift` (WCSession delegate, iOS y watch con `#if os(watchOS)`).
4. [x] iOS: activar sesión en `MiConsumoBarApp.init`; hook en `ConsumicionViewModel.refreshTodayData` para push de estado; handler de comandos con idempotencia. Test unitario de idempotencia.
5. [x] watchOS UI: `WatchContentView` (List de bebidas, tap +1, toolbar undo, cabecera resumen), haptic `WKInterfaceDevice.current().play(.success)`.
6. [x] Complicación: reutilizar vista del widget iOS (`DrinkTrackWidget.swift`) adaptada a `accessory*` families.
7. [x] Strings es/en (`Localizable.xcstrings` compartido con el target watch).
8. [x] Privacy: watch no envía analytics; iPhone ya emite `consumption_added` al procesar comando (añadir prop `source=watch`).
9. [x] Docs: README/`Docs/WATCH.md`; actualizar CLAUDE.md estructura.

## Riesgos
- Extraer `ConsumicionViewModel` de la vista para llamarlo sin UI (hoy vive en `ContentView` como @StateObject) → usar `CoreDataManager` directo + notificar UI (`NotificationCenter`) — decidir en paso 4.
- WCSession sólo entrega si app instalada en ambos; `updateApplicationContext` no funciona en simulador sin par emparejado (probar con par iPhone+Watch simulados).
- Sin Apple Developer team configurado (`DEVELOPMENT_TEAM: ""`): firma manual necesaria para dispositivo real.
- Revisión App Store: capturas watch obligatorias.

## Verificación
- `xcodebuild` iOS + watch schemes compilan; tests pasan.
- Par simulado iPhone 17 + Apple Watch: tap +1 en watch → aparece en iPhone y contador watch se actualiza; modo avión watch → cola entrega al reconectar; comando duplicado no duplica consumo.
- Complicación muestra contador tras cambios.
- Flujo export/import sin regresión (regla CLAUDE.md).

## Estimación
Pasos 1–5 ≈ 3 días; 6–9 ≈ 1–2 días.

## Estado (2026-09-30)
Hecho: pasos 1–5, 7, 8 (commits a099f29 + fix de activación WCSession). Verificado en simuladores emparejados (iPhone 17 + Watch Ultra 4): el reloj recibe el estado del iPhone.
Pendiente: 6 (complicación: target widget watchOS + App Group en watch), 9 (docs), y probar Watch→iPhone (tap +1 / deshacer) en simulador o dispositivo real; solo hay tests unitarios de modelos e idempotencia.

2026-09-30 (tarde): complicación (DrinkTrackWatchWidget) y docs hechos; build 1.6 (4). Verificado: build simulador + archive firmado con la complicación embebida. Sin verificar visualmente la complicación en una esfera.

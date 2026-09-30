# Analytics (PostHog)

Mismo patrón que Synctrackers (`SyncSalud/Docs/ANALYTICS.md`): PostHog Cloud EU, **opt-in**, off por defecto.

- Proyecto PostHog compartido con Synctrackers; todos los eventos llevan `app = "drinktrack"` (filtra por ella).
- Sin `identify`, sin autocapture, sin session replay, `$geoip_disable = true`.
- Activar "Discard client IP data" en el proyecto PostHog (ajuste manual, no controlable desde el SDK).
- Consentimiento: sheet en primer arranque (`AnalyticsConsentView`) + toggle en Ajustes.

## Setup local
1. `cp Secrets.example.xcconfig Secrets.xcconfig` (gitignored).
2. `POSTHOG_API_KEY` = **Project token `phc_…`** (nunca `phx_`/`phs_`). Host sin `https://`.
3. `xcodegen`.

## Regla
Solo contadores, booleanos y categorías. **Nunca** nombres de bebida, precios, importes ni notas.

## Eventos
| Evento | Props | Origen |
|---|---|---|
| `consumption_added` | `category`, `quantity`, `has_notes` | `CoreDataManager.addConsumicion` |
| `consumption_removed` | — | `CoreDataManager.deleteConsumicion` |
| `drink_created` / `drink_edited` / `drink_deleted` | `category` | `CoreDataManager` |
| `import_done` | `mode`, `source` (`settings`/`open_url`) | `SettingsView`, `ImportViewModel` |
| `history_range_changed` | `range_days` | `HistorialView` |
| `$screen` | `$screen_name` (`settings`, `history`) | `Analytics.screen` |
| lifecycle | SDK | `captureApplicationLifecycleEvents` |

Nota: `export_done` no se emite (ShareLink no informa de finalización).

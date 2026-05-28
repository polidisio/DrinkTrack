# CLAUDE.md - DrinkTrack

## Project Overview

**Name:** DrinkTrack (MyBarTrack)  
**Type:** iOS App (SwiftUI)  
**Description:** App for tracking beverage consumption, managing favorite drinks, analyzing spending with charts, and export/import via JSON.  
**Owner:** @polidisio  

## Tech Stack

- **Language:** Swift 5.0+
- **Framework:** SwiftUI + CoreData + Swift Charts
- **Min iOS:** 15.0
- **Architecture:** MVVM + Combine
- **Build System:** XcodeGen (project.yml)

## Quick Start

```bash
# Open in Xcode
open DrinkTrack.xcodeproj
# or
open MyBarTrack.xcodeproj

# Build (Cmd+R)
```

## File Structure

```
DrinkTrack/
├── MIConsumoBar/
│   ├── Models/
│   │   ├── CoreDataManager.swift
│   │   └── DrinkTrackExportTypes.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── HistorialView.swift
│   │   ├── AddConsumicionView.swift
│   │   └── ConsumptionChartView.swift
│   ├── ViewModels/
│   │   ├── ConsumicionViewModel.swift
│   │   └── BebidaListViewModel.swift
│   └── Utils/
│       ├── BebidaExporter.swift
│       └── BebidaImporter.swift
├── MIConsumoBarTests/
├── MyBarTrack.xcodeproj
├── project.yml
├── README.es.md
├── README.md
├── AGENTS.md
├── DOCUMENTATION.md
└── CLAUDE.md
```

## Features

- ✅ Track daily beverage consumption
- ✅ Manage drinks (name, emoji, price)
- ✅ Spending statistics with charts
- ✅ Consumption by category
- ✅ Export/Import via JSON + AirDrop
- ✅ Multi-language (Spanish/English)
- ✅ History by date

## Architecture

### Pattern: MVVM + Combine
- **CoreData:** Local persistent storage
- **Swift Charts:** Visual analytics
- **Combine:** Reactive state management

### Data Models
- CoreData entities for drinks and consumption
- Export types in `DrinkTrackExportTypes.swift`

## Conventions

- SwiftUI for UI
- CoreData for persistence
- Swift Charts for visualizations

## Important Rules

### ✅ Always Do
- Test export/import flow before major changes
- Follow CoreData naming conventions

### ❌ Never Do
- Hardcode prices in views (use models)

## Resources

- Token optimization tips: `shared/claude-optimization-tips.md` (Obsidian Vault)

---

**Owner:** Jose Maudisio (@polidisio)  
**Last updated:** 2026-04-24

---

---

## Workflow

### Para tareas simples
Sé directo: "Añade validación al form" — no necesitas explicar contexto.

### Para tareas complejas (>3 pasos)
1. Agent propone plan primero
2. Usuario confirma
3. Agent ejecuta
4. Agent verifica con tests

### Para cada tarea
1. **Plan** → Si son >3 pasos, escribir en `tasks/todo.md`
2. **Verify** → Confirmar antes de cambios grandes
3. **Execute** → Cambio más pequeño posible
4. **Test** → Ejecutar tests, verificar regression
5. **Document** → Actualizar si es necesario

---

## Code Quality

### SIEMPRE
- Código legible y mantenible
- Seguir convenciones del proyecto
- DRY — no duplicar lógica
- Validar input antes de procesar

### NUNCA
- Hardcodear credenciales o tokens
- "Hacky fixes" sin justificación
- Duplicar código sin razón
- Commits sin mensaje descriptivo

---

## Security

- **NUNCA hardcodear** credenciales — usar environment variables
- **NUNCA exponer** tokens en logs o errores
- **Validar input** antes de procesar
- Si hay secrets, usar `.env` y nunca commitearlo

---

## Self-Improvement

### Si cometes un error
1. Documentar en `lessons.md` — qué salió mal, por qué, cómo evitarlo
2. Actualizar este archivo si la convención no estaba clara
3. No repetir

### Si descubres algo útil
- Documentar en notas del proyecto
- Compartir con Jose si es relevante

---

## Token Optimization

### Hacer
- Agrupar múltiples requests en uno
- Editar en vez de reply (menos historial)
- Nuevo tema = nueva conversación
- Planificar en chat, construir en workspace

### Evitar
- Subir carpetas enteras — solo archivos necesarios
- Múltiples prompts cortos seguidos
- Usar Opus para tareas simples
- Mantener contexto irrelevante

**Budget:** ~88% de tokens en conversaciones largas = solo historial. Mantenerlo limpio.

---

## Resources

**Obsidian Vault:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Saraiba/`

| Recurso | Ubicación en Vault |
|---------|---------------------|
| Best practices | `shared/coding-best-practices.md` |
| Optimization tips | `shared/claude-optimization-tips.md` |
| Skills docs | `shared/openclw-skills.md` |
| Guía coding agents | `shared/guia-coding-agents.md` |

---

## Contact

**Jose Maudisio** — @polidisio
**Issues:** Abrir en GitHub o preguntar en Telegram

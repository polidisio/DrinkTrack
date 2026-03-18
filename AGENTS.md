# AGENTS.md - MyBarTrack Development Guide

This file provides guidelines for agentic coding agents working on the MyBarTrack iOS app.

## Project Overview

- **iOS Target**: 16.0+
- **Swift Version**: 5.0+
- **Xcode Version**: 15.0+
- **Framework**: SwiftUI with CoreData
- **Bundle ID**: com.polidisio.MyBarTrack
- **Languages**: English (en), Spanish (es)

## Build Commands

### Build for Simulator
```bash
xcodebuild -project MyBarTrack.xcodeproj -scheme MyBarTrack -configuration debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

### Build for Device
```bash
xcodebuild -project MyBarTrack.xcodeproj -scheme MyBarTrack -configuration Release -destination 'generic/platform=iOS' build
```

### Build for TestFlight
```bash
xcodebuild -project MyBarTrack.xcodeproj -scheme MyBarTrack -configuration Release -archive -archive-path ./MyBarTrack.xcarchive
```

### Run All Tests
```bash
xcodebuild test -project MyBarTrack.xcodeproj -scheme MyBarTrack -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

### Run Single Test
```bash
xcodebuild test -project MyBarTrack.xcodeproj -scheme MyBarTrack -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:DrinkTrackTests/DrinkTrackExportTypesTests/testBebidaExportDataCodable
```

### Open in Xcode
```bash
open MyBarTrack.xcodeproj
```

## Code Structure

```
MyBarTrack/
├── MIConsumoBar/
│   ├── Models/
│   │   ├── CoreDataManager.swift      # CoreData singleton
│   │   └── DrinkTrackExportTypes.swift # Codable export types
│   ├── Views/
│   │   ├── ContentView.swift          # Main screen
│   │   ├── HistorialView.swift         # History view
│   │   ├── AddConsumicionView.swift    # Add consumption
│   │   ├── ConsumptionChartView.swift  # Charts
│   │   └── ...
│   ├── ViewModels/
│   │   ├── ConsumicionViewModel.swift
│   │   └── BebidaListViewModel.swift
│   ├── Utils/
│   │   ├── BebidaExporter.swift        # JSON export
│   │   ├── BebidaImporter.swift         # JSON import
│   │   └── BebidaConstants.swift        # Constants
│   └── Resources/
│       └── Localizable.xcstrings       # Translations
└── MyBarTrack.xcodeproj
```

## Code Style Guidelines

### Imports

Organize imports in the following order:
1. System frameworks: `import Foundation`, `import CoreData`, `import Combine`, `import SwiftUI`
2. Third-party libraries
3. Local project imports

Example:
```swift
import Foundation
import CoreData
import Combine
import SwiftUI
import UniformTypeIdentifiers
```

### Naming Conventions

- **Types/Classes/Structs/Enums**: PascalCase (`CoreDataManager`, `ConsumicionViewModel`)
- **Properties/Variables/Functions**: camelCase (`bebidas`, `fetchBebidas()`, `totalHoy`)
- **Constants**: camelCase with meaningful names (`exportVersion`, `retentionDays`)
- **CoreData Entities**: PascalCase (`Bebida`, `Consumicion`)

### SwiftUI Patterns

Use appropriate property wrappers based on ownership:
- `@State`: Local view state, private to the view
- `@StateObject`: Create and own an ObservableObject
- `@EnvironmentObject`: Inject a shared ObservableObject
- `@Environment`: Access environment values
- `@Published`: Observable properties in ViewModels

```swift
struct MyView: View {
    @State private var showingAlert = false
    @StateObject private var viewModel = MyViewModel()
    @EnvironmentObject private var sharedViewModel: SharedViewModel
    @Environment(\.scenePhase) private var scenePhase
}
```

### CoreData Patterns

- Use `CoreDataManager.shared` as a singleton for database access
- Always access CoreData through the manager, not directly
- Use `NSFetchRequest<T>` with predicates and sort descriptors
- Always save context after modifications

```swift
func fetchBebidas() -> [Bebida] {
    let request: NSFetchRequest<Bebida> = Bebida.fetchRequest()
    request.predicate = NSPredicate(format: "id != nil")
    request.sortDescriptors = [NSSortDescriptor(key: "orden", ascending: true)]
    
    do {
        return try context.fetch(request)
    } catch {
        print("Error fetching bebidas: \(error)")
        return []
    }
}
```

### Error Handling

- Use `guard` for early returns and validation
- Use `print()` for logging errors (current convention)
- Use `fatalError()` only for unrecoverable initialization failures

```swift
func processImport(url: URL?) {
    guard let url = url else { return }
    
    guard let exportData = BebidaImporter.shared.parseExportData(from: url) else {
        print("Error parsing export data")
        return
    }
    // Process data
}
```

### Code Organization

Use MARK comments to organize code into logical sections:
```swift
// MARK: - Properties

// MARK: - Initialization

// MARK: - Public Methods

// MARK: - Private Methods

// MARK: - CoreData Operations
```

### Combine Usage

- Use `@Published` for observable properties
- Use `Task { @MainActor in }` for async operations that update UI
- Always dispatch UI updates to the main actor

```swift
func loadData() {
    Task { @MainActor in
        bebidas = coreDataManager.fetchBebidas()
        refreshTodayData()
    }
}
```

### Property Declaration Order

1. `@Published` / `@State` / `@StateObject` properties
2. `@EnvironmentObject` / `@Environment` properties
3. Private properties
4. Computed properties
5. Functions/Methods

### Strings and Localization

- Use `NSLocalizedString(key, comment: "")` for user-facing strings
- Add keys to `Localizable.xcstrings` for translations
- Use keys like `"total_hoy"`, `"historial_title"`, `"anadir_consumicion_button"`

### View Modifiers Order

Apply modifiers in this order for consistency:
1. Structural modifiers (`frame`, `padding`, `background`)
2. Appearance modifiers (`foregroundColor`, `font`, `cornerRadius`)
3. Interaction modifiers (`onTapGesture`, `sheet`, `alert`)

### Architecture Patterns

- **Views**: SwiftUI views, focus on UI only
- **ViewModels**: ObservableObject classes that manage state and business logic
- **Models**: CoreData entities and Codable types
- **Utils**: Helper classes (Exporter, Importer)
- **Services**: CoreDataManager as the main data service

### Testing

- Create test files with `XCTest`
- Name test files: `ClassNameTests.swift`
- Group tests by functionality
- Use `@MainActor` for UI-related tests
- Test target: `DrinkTrackTests`

### Common Patterns

**Sharing/Exporting**:
```swift
private func createShareURL() -> URL? {
    let exportItems = bebidas.map { bebida in
        BebidaExportItem(...)
    }
    let exportData = BebidaExportData(...)
    guard let jsonData = try? JSONEncoder().encode(exportData) else {
        return nil
    }
    let fileURL = tempDir.appendingPathComponent("bebidas.json")
    try? jsonData.write(to: fileURL)
    return fileURL
}
```

**Sheet Presentation**:
```swift
.sheet(isPresented: $showingSheet) {
    TargetView(onSave: {
        reloadData()
    })
}
```

## Important Notes

- This project does not use SwiftLint - follow the conventions in this file
- Tests are located in `MIConsumoBarTests/` target
- CoreData entities are defined in `MiConsumoBar.xcdatamodeld`
- The app uses historical consumption tracking (counters persist until reset)
- Export/Import functionality uses JSON with ISO8601 date encoding

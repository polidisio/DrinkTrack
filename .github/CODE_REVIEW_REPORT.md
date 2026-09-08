# Code Review Report: DrinkTrack
**Generated:** 2026-09-10 by Hermes Nightly Review
**Commit analyzed:** current HEAD (no new commits vs main)

---

## CRITICAL Issues

### 1. ConsumicionViewModel decrements quantity without atomic save
**File:** `MIConsumoBar/ViewModels/ConsumicionViewModel.swift`, line 91-93
```swift
if ultima.cantidad > 1 {
    ultima.cantidad -= 1
    coreDataManager.save()
```
**Problem:** `Consumicion.cantidad` is mutated directly then `save()` is called. If two concurrent calls happen (e.g. rapid button taps), Core Data's `NSMergeByPropertyObjectTrumpMergePolicy` on the context means one change could be silently lost. Core Data manages object identity — the same `Consumicion` instance is referenced, but concurrent writes are not serialized.

**Suggested fix:** Use `performAndWait` or a serial `actor` to ensure the decrement-and-save is atomic:
```swift
private func safeDecrement(consumicion: Consumicion) {
    context.performAndWait {
        if consumicion.cantidad > 1 {
            consumicion.cantidad -= 1
        } else {
            context.delete(consumicion)
        }
        saveContext()
    }
}
```

### 2. Memory leak: `ConsumicionViewModel` never deallocates
**File:** `MIConsumoBar/ViewModels/ConsumicionViewModel.swift`, line 8
```swift
@StateObject private var viewModel = ConsumicionViewModel()
```
**Problem:** `@StateObject` is owned by the view lifecycle. If `ContentView` is presented multiple times (e.g. navigation), the previous `ConsumicionViewModel` is not released because no `onDisappear` resets it. More critically, the `ConsumicionViewModel` captures `coreDataManager` strongly, and CoreData's `persistentContainer` holds onto view contexts.

**Suggested fix:** Consider calling `refreshTodayData()` in `onDisappear` or use a shared singleton pattern with proper cleanup.

---

## HIGH Issues

### 3. Missing error propagation in `parseExportData`
**File:** `MIConsumoBar/Utils/BebidaImporter.swift`, line 39
```swift
print("Error decoding JSON data")
return nil
```
**Problem:** Silent failure — the import UI will behave identically whether the file is corrupted or the format is wrong. The user gets no feedback.

**Suggested fix:** Return a typed `Result<BebidaExportData, ImportError>` or throw, so the caller can show a meaningful alert.

### 4. No validation of imported `precioBase` bounds
**File:** `MIConsumoBar/Utils/BebidaImporter.swift`, line 173
```swift
private func isValid(_ item: BebidaExportItem) -> Bool {
    !item.nombre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && item.precioBase >= 0
}
```
**Problem:** Only checks `>= 0`. A malicious or buggy export could set `precioBase` to `Double.infinity` or `Double.nan`, causing division-by-zero or NaN display in the UI.

**Suggested fix:** Add a max bound:
```swift
item.precioBase >= 0 && item.precioBase < 10000 && item.precioBase.isFinite
```

### 5. `deleteBebida` cascades delete without save rollback on partial failure
**File:** `MIConsumoBar/Models/CoreDataManager.swift`, line 146-152
```swift
func deleteBebida(_ bebida: Bebida) {
    if let bebidaID = bebida.id {
        deleteConsumiciones(forBebidaID: bebidaID)
    }
    context.delete(bebida)
    save()
}
```
**Problem:** If `deleteConsumiciones` succeeds but `context.delete(bebida)` fails (or vice versa), there's no rollback. Also, if `bebida.id` is nil, the consumiciones are not deleted but the bebida still is — orphaning records.

**Suggested fix:** Wrap the whole operation in a single save, or use `NSBatchDeleteRequest` for bulk deletes.

### 6. No `@MainActor` guarantee on `ConsumicionViewModel` mutations
**File:** `MIConsumoBar/ViewModels/ConsumicionViewModel.swift`
**Problem:** `ConsumicionViewModel` methods modify `@Published` properties (which must happen on main actor) but there's no `@MainActor` annotation. If called from a background `Task`, this is undefined behaviour.

**Suggested fix:** Add `@MainActor class ConsumicionViewModel` or annotate each mutating method.

---

## MEDIUM Issues

### 7. Hardcoded currency symbol fallback
**File:** `MIConsumoBar/Views/ContentView.swift`, line 181
```swift
Locale.current.currencySymbol ?? "€"
```
**Problem:** Two issues: (1) hardcoded "€" is inconsistent with the `currencyCode` which may be "USD" or "GBP"; (2) `Locale.current` can return nil for the symbol in some locales.

**Suggested fix:** Use `NumberFormatter` configured with `Locale.current` and the detected `currencyCode`:
```swift
let formatter = NumberFormatter()
formatter.numberStyle = .currency
formatter.locale = Locale.current
formatter.currencyCode = Locale.current.currency?.identifier ?? "EUR"
```

### 8. Export CSV doesn't escape newlines in notes
**File:** `MIConsumoBar/Utils/BebidaExporter.swift`, line 25
```swift
let notas = (consumicion.notas ?? "").replacingOccurrences(of: "\"", with: "\"\"")
```
**Problem:** Only escapes quotes, not newlines or commas inside the notes field. This corrupts the CSV structure.

**Suggested fix:** Either escape all special chars or wrap the field and escape internal quotes:
```swift
let notasField = "\"\(notas.replacingOccurrences(of: "\"", with: "\"\"").replacingOccurrences(of: "\n", with: " "))\""
```

### 9. `fetchConsumiciones(for: Date?)` treats nil date as "no filter"
**File:** `MIConsumoBar/Models/CoreDataManager.swift`, line 187-212
```swift
if last7Days {
    ...
} else if let date = date {
    ...
}
// nil date: no filter applied — returns ALL consumiciones
```
**Problem:** Inconsistent API: `fetchConsumiciones()` with no args returns all records, but `fetchConsumiciones(for: nil)` also returns all records without any error or warning. This is confusing at call sites.

**Suggested fix:** Split into `fetchAllConsumiciones()` and `fetchConsumiciones(for: Date)` — remove the optional parameter.

### 10. `periodStart` computed property in ContentView duplicates CoreDataManager logic
**File:** `MIConsumoBar/Views/ContentView.swift`, line 116-118
```swift
private var periodStart: Date {
    CoreDataManager.shared.periodStart(for: budgetPeriod)
}
```
**Problem:** Minor duplication. Also, this recomputes on every render because it's a computed property without caching. `ConsumicionViewModel` already has a similar computation via `updateWidgetSnapshot()`.

**Suggested fix:** Pass `periodStart` as a `@State` variable, or cache it in `UserDefaults` with an `onChange` invalidation.

---

## MINOR Suggestions

### 11. `fetchBebidas()` uses redundant predicate
**File:** `MIConsumoBar/Models/CoreDataManager.swift`, line 80
```swift
request.predicate = NSPredicate(format: "id != nil")
```
**Problem:** Every managed object has a non-nil `id` by definition (it's the primary key). This predicate is always true and adds unnecessary filtering overhead.

### 12. Widget uses `.never` refresh policy
**File:** `DrinkTrackWidget/DrinkTrackWidget.swift`, line 22
```swift
completion(Timeline(entries: [entry], policy: .never))
```
**Problem:** If the app never calls `WidgetCenter.shared.reloadAllTimelines()` (e.g. after a crash), the widget shows stale data forever. Consider a `.atEnd` policy with a reasonable future date as fallback.

### 13. No test coverage for `BebidaImporter.mergeBebidasSync` conflict resolution
**File:** `MIConsumoBarTests/`
**Problem:** The tests cover exporter but not the importer's merge logic, particularly what happens when imported IDs conflict with existing ones.

### 14. `cleanupOldConsumiciones` saves even when nothing to delete
**File:** `MIConsumoBar/Models/CoreDataManager.swift`, line 259-279
```swift
// Always calls save() even if oldConsumiciones is empty
```
**Problem:** Wastes a Core Data save operation every time. Check `isEmpty` before saving.

---

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 2     |
| HIGH     | 4     |
| MEDIUM   | 4     |
| MINOR    | 4     |
| **Total**| **14**|

### Recommendation
Priority should be given to CRITICAL-1 (race condition in decrement) and CRITICAL-2 (memory leak / lifecycle). HIGH-6 (`@MainActor` missing) is also important for iOS 15+ with Swift concurrency.

No security vulnerabilities (auth, injection, data leakage) were found — the app is a local-only tracker with no network calls in the reviewed code.

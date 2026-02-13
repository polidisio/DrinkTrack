# DrinkTrack

[![iOS](https://img.shields.io/badge/iOS-15.0+--blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

iOS app to track your drink consumption. Monitor your daily intake, manage your favorite drinks, and analyze your spending.

## Features

- ✅ **Daily consumption tracking** - Record every drink you consume
- ✅ **Drink management** - Add, edit and delete drinks with name, emoji and price
- ✅ **Spending statistics** - View how much you spend on drinks
- ✅ **Charts by type** - Analysis of consumption by drink category
- ✅ **Export/Import** - Share your drinks via JSON and AirDrop
- ✅ **Multilingual** - Support for Spanish and English
- ✅ **History** - Review your consumption by date

## Screenshots

| Main Screen | History | Manage Drinks |
|-------------|---------|---------------|
| ![Main](screenshots/main.png) | ![History](screenshots/history.png) | ![Manage](screenshots/manage.png) |

*(Add your screenshots to the `screenshots/` folder)*

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.0+

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/polidisio/DrinkTrack.git
   cd DrinkTrack
   ```

2. **Open in Xcode:**
   ```bash
   open DrinkTrack.xcodeproj
   ```

3. **Select a simulator or device** and press `Cmd + R` to run.

## Project Structure

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
│   │   ├── ConsumptionChartView.swift
│   │   └── ...
│   ├── ViewModels/
│   │   ├── ConsumicionViewModel.swift
│   │   └── BebidaListViewModel.swift
│   └── Utils/
│       ├── BebidaExporter.swift
│       └── BebidaImporter.swift
├── DrinkTrack-Info.plist
└── README.md
```

## Technologies

- **SwiftUI** - Modern user interface
- **CoreData** - Persistent local storage
- **Swift Charts** - Consumption charts
- **Combine** - Reactive programming

## Export/Import Drinks

The app allows you to export your drinks as a JSON file and share them via AirDrop:

1. Tap the share button (arrow up icon)
2. Select AirDrop or another app to send
3. To import, receive the JSON file in the app

## Contributing

1. Fork the repository
2. Create a branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author

Developed by [polidisio](https://github.com/polidisio)

---

⭐️ If you like this project, don't forget to give it a star on GitHub!

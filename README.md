# DrinkTrack

[![iOS](https://img.shields.io/badge/iOS-15.0+--blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

App iOS para seguir el consumo de bebidas. Controla tu consumo diario, gestiona tus bebidas favoritas y analiza tus gastos.

## Características

- ✅ **Control de consumo diario** - Registra cada bebida que consumes
- ✅ **Gestión de bebidas** - Añade, edita y elimina bebidas con nombre, emoji y precio
- ✅ **Estadísticas de gasto** - Visualiza cuánto gastas en bebidas
- ✅ **Gráficos por tipo** - Análisis de consumo por categoría de bebida
- ✅ **Exportar/Importar** - Comparte tus bebidas via JSON y AirDrop
- ✅ **Multiidioma** - Soporte para Español e Inglés
- ✅ **Historial** - Revisa tu consumo por fecha

## Capturas de Pantalla

| Pantalla Principal | Historial | Gestión de Bebidas |
|-------------------|-----------|-------------------|
| ![Main](screenshots/main.png) | ![History](screenshots/history.png) | ![Manage](screenshots/manage.png) |

*(Agrega tus capturas de pantalla en la carpeta `screenshots/`)*

## Requisitos

- iOS 15.0+
- Xcode 15.0+
- Swift 5.0+

## Instalación

1. **Clona el repositorio:**
   ```bash
   git clone https://github.com/polidisio/DrinkTrack.git
   cd DrinkTrack
   ```

2. **Abre en Xcode:**
   ```bash
   open DrinkTrack.xcodeproj
   ```

3. **Selecciona un simulador o dispositivo** y presiona `Cmd + R` para ejecutar.

## Estructura del Proyecto

```
DrinkTrack/
├── MIConsumoBar/
│   ├── Models/
│   │   ├── CoreDataManager.swift      # Gestor de CoreData
│   │   └── DrinkTrackExportTypes.swift # Tipos de exportación
│   ├── Views/
│   │   ├── ContentView.swift          # Vista principal
│   │   ├── HistorialView.swift        # Historial de consumo
│   │   ├── AddConsumicionView.swift   # Añadir consumición
│   │   ├── ConsumptionChartView.swift  # Gráficos
│   │   └── ...
│   ├── ViewModels/
│   │   ├── ConsumicionViewModel.swift
│   │   └── BebidaListViewModel.swift
│   └── Utils/
│       ├── BebidaExporter.swift       # Exportar JSON
│       └── BebidaImporter.swift       # Importar JSON
├── DrinkTrack-Info.plist
└── README.md
```

## Tecnologías

- **SwiftUI** - Interfaz de usuario moderna
- **CoreData** - Almacenamiento local persistente
- **Swift Charts** - Gráficos de consumo
- **Combine** - Programación reactiva

## Exportar/Importar Bebidas

La app permite exportar tus bebidas como archivo JSON y compartirlas via AirDrop:

1. Toca el botón de compartir (icono de flecha arriba)
2. Selecciona AirDrop u otra app para enviar
3. Para importar, recibe el archivo JSON en la app

## Contribuir

1. Haz fork del repositorio
2. Crea una rama (`git checkout -b feature/nueva-caracteristica`)
3. Haz commit de tus cambios (`git commit -m 'Agrega nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## Autor

Desarrollado por [polidisio](https://github.com/polidisio)

---

⭐️ Si te gusta este proyecto, no olvides una estrella en GitHub!

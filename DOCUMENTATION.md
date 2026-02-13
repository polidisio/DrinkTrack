# DrinkTrack - Documentación para App Store

## 1. Información General de la App

| Campo | Valor |
|-------|-------|
| **Nombre de la App** | DrinkTrack |
| **Bundle ID** | com.polidisio.DrinkTrack |
| **Versión actual** | 1.0 |
| **Target iOS** | iOS 15.0+ |
| **Idiomas** | Inglés (en), Español (es) |
| **Dispositivos** | iPhone, iPad |

---

## 2. Descripción de la App

**DrinkTrack** es una aplicación de seguimiento de consumo de bebidas que permite:

- 📊 **Control de consumo**: Registra la cantidad y coste de bebidas consumidas diariamente
- 🍺 **Gestión de bebidas**: Añade, edita y elimina bebidas con nombre, emoji y precio
- 📈 **Estadísticas**: Visualiza el historial de consumo con gráficos
- 📤 **Exportar/Importar**: Comparte tus bebidas via AirDrop y JSON
- 🔄 **Sincronización**: Importa bebidas desde otros dispositivos

---

## 3. Estructura del Proyecto

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
│   │   ├── GestionarBebidasView.swift # Gestionar bebidas
│   │   ├── EmojiPickerView.swift      # Selector de emoji
│   │   └── ...
│   ├── ViewModels/
│   │   ├── ConsumicionViewModel.swift
│   │   └── BebidaListViewModel.swift
│   ├── Utils/
│   │   ├── BebidaExporter.swift       # Exportar JSON
│   │   └── BebidaImporter.swift       # Importar JSON
│   └── Resources/
│       └── Localizable.xcstrings      # Traducciones
└── DrinkTrack-Info.plist
```

---

## 4. Configuración Actual

### Info.plist keys configuradas:
- ✅ `UIFileSharingEnabled` = YES
- ✅ `LSSupportsOpeningDocumentsInPlace` = YES
- ✅ `CFBundleDocumentTypes` = public.json
- ✅ `CFBundleLocalizations` = en, es
- ✅ `UIApplicationSceneManifest`

---

## 5. Assets Requeridos para App Store

### 5.1 Iconos de App (App Icon)

| Tamaño | Descripción |
|--------|-------------|
| 1024x1024 | App Store (obligatorio) |
| 180x180 | iPhone @3x |
| 120x120 | iPhone @2x |
| 167x167 | iPad Pro |
| 152x152 | iPad |
| 76x76 | iPad @1x |

### 5.2 Capturas de Pantalla (Screenshots)

| Dispositivo | Tamaño | Cantidad mínima |
|-------------|--------|-----------------|
| iPhone 6.7" | 1290x2796 | 2-3 capturas |
| iPhone 6.5" | 1242x2688 | 2-3 capturas |
| iPad Pro 12.9" | 2048x2732 | 2-3 capturas |

### 5.3 Descripción de Capturas Recomendadas:

1. **Pantalla principal**: Muestra el contador de bebidas con el total del día
2. **Historial**: Gráfico de consumo
3. **Gestión de bebidas**: Lista de bebidas con opciones de editar
4. **Compartir**: Botón de exportar

---

## 6. Metadatos para App Store

### 6.1 Información Requerida

| Campo | Descripción |
|-------|-------------|
| **Nombre** | DrinkTrack |
| **Subtítulo** | Track your drinks |
| **Descripción** | App para seguir el consumo de bebidas... (200 caracteres mínimo) |
| **Palabras clave** | drinks, tracker, consumo, bar, bebidas |
| **URL de soporte** | Tu email o web |
| **URL de privacidad** | Política de privacidad |

### 6.2 Categorías

- **Primaria**: Lifestyle
- **Secundaria**: Utilities (opcional)

### 6.3 Clasificación de Contenido

- **Edad**: 4+ (todos los públicos)

---

## 7. Política de Privacidad

### 7.1 Datos Recopilados

| Tipo | Recopilado | Notas |
|------|------------|-------|
| Datos de uso | ❌ No | No se recopila analytics |
| Información del dispositivo | ❌ No | No se accede a identifiers |
| Datos de salud | ❌ No | No relevante |
| Localización | ❌ No | No se usa |

### 7.2 Prácticas de Datos

- ✅ Almacenamiento local con CoreData
- ✅ No comparte datos con terceros
- ✅ No incluye publicidad
- ✅ Sin compras dentro de la app

### 7.3 Plantilla de Política de Privacidad

```
Política de Privacidad de DrinkTrack

DrinkTrack no recopila, transmite ni comparte ningún dato personal del usuario.

Datos Almacenados:
- Todos los datos (bebidas, consumiciones) se almacenan exclusivamente en el dispositivo del usuario.
- No existe ningún servidor externo que procese o almacene información del usuario.

Permisos:
- La app no requiere permisos especiales más allá del acceso básico al sistema de archivos para importar/exportar datos.

Cambios:
- Esta política puede actualizarse en futuras versiones. La versión actual siempre estará disponible en la app.

Contacto:
- Para cualquier consulta sobre privacidad, contactar a [tu email].
```

---

## 8. Checklist de Envío

### ✅ Preparación del Build

- [ ] Versión de Xcode actualizada
- [ ] Build exitoso en Release mode
- [ ] Dispositivo de prueba conectado (si aplica)
- [ ] Perfil de provisioning configurado
- [ ] Certificados válidos

### ✅ Assets

- [ ] App Icon en todos los tamaños
- [ ] 2-3 capturas de pantalla por tamaño
- [ ] Capturas de iPhone y iPad

### ✅ Metadatos

- [ ] Nombre y descripción completos
- [ ] Palabras clave configuradas
- [ ] URL de soporte válida
- [ ] Política de privacidad publicada

### ✅ Configuración Técnica

- [ ] Info.plist completo
- [ ] Capabilities configuradas (si aplica)
- [ ] Testflight Build subido (recomendado)

---

## 9. Notas Adicionales

### 9.1 Importar/Exportar JSON

La app permite exportar bebidas como JSON y compartirlas via AirDrop. Para recibir archivos:
- Configurar CFBundleDocumentTypes (ya configurado)
- El archivo debe ser .json

### 9.2 Problemas Conocidos

- La importación de archivos por AirDrop puede requerir configuración adicional en algunos casos
- Verificar funcionamiento en dispositivo físico antes de envío

---

## 10. Próximos Pasos

| Paso | Acción |
|------|--------|
| 1 | Subir iconos y capturas a App Store Connect |
| 2 | Publicar política de privacidad (puede ser un enlace simple) |
| 3 | Subir build a App Store Connect |
| 4 | Completar información de la app |
| 5 | Enviar para revisión |

---

## 11. Comandos de Build

### Build para Simulador

```bash
xcodebuild -project DrinkTrack.xcodeproj -scheme MIConsumoBar -configuration debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

### Build para Dispositivo

```bash
xcodebuild -project DrinkTrack.xcodeproj -scheme MIConsumoBar -configuration Release -destination 'generic/platform=iOS' build
```

### Build para TestFlight

```bash
xcodebuild -project DrinkTrack.xcodeproj -scheme MIConsumoBar -configuration Release -archive -archive-path ./DrinkTrack.xcarchive
```

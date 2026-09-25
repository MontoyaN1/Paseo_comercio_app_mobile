# Paseo del Comercio - App Móvil

Aplicación Flutter para el proyecto Paseo del Comercio.

## Estructura del Proyecto

```
lib/
├── core/              # Configuración, utilidades y servicios base
├── data/              # Capa de datos (repositorios, datasources)
├── di/                # Inyección de dependencias (GetIt)
├── domain/            # Capa de dominio (entidades, interfaces)
├── presentation/      # Capa de presentación (BLoCs, páginas, widgets)
├── main.dart          # Punto de entrada de la aplicación
└── firebase_options.dart  # Configuración de Firebase
```

## Capas de Arquitectura

| Carpeta | Responsabilidad |
|---------|----------------|
| **core** | Configuración global, servicios compartidos, utilidades |
| **domain** | Entidades de negocio, interfaces de repositorios |
| **data** | Implementaciones de repositorios, fuentes de datos |
| **presentation** | UI (páginas, widgets) y estado (BLoCs) |
| **di** | Inyección de dependencias con GetIt |

## Arquitectura

La aplicación sigue **Clean Architecture** con 4 capas:

```
presentation/   → domain/   → data/   → core/
    (UI)        (reglas)    (datos)  (infra)
```

**Patrones implementados:**
- **BLoC Pattern** - Gestión de estado con `flutter_bloc`
- **Repository Pattern** - Abstracción de fuentes de datos
- **Service Locator** - Inyección de dependencias con `get_it`

## Módulos Principales

### Auth (Autenticación)
- Firebase Auth + Google Sign In
- Estados: autenticado, no autenticado, invitado

### Favoritos
- Sistema de favoritos para tiendas y productos
- Sincronización con Supabase

### Tiendas
- Catálogo de tiendas
- Detalle de tienda con horarios, productos

### Productos
- Catálogo de productos
- Detalle de producto con imágenes

### Plazoletas
- Áreas comunes del centro comercial
- Tiendas y organizaciones por plazoleta

### Organizaciones
- Organizaciones comerciales
- Miembros y tiendas asociadas

## Tecnologías

| Categoría | Tecnología |
|-----------|------------|
| Framework | Flutter |
| State Management | flutter_bloc |
| Navigation | go_router |
| Backend | Supabase PostgreSQL |
| Auth | Firebase Auth |
| Image Storage | Cloudflare R2 |
| Local Storage | Hive |
| DI | get_it |

## Comandos de Desarrollo

```bash
# Instalar dependencias
flutter pub get

# Ejecutar app
flutter run

# Analizar código
flutter analyze

# Formatear código
flutter format .

# Build release
flutter build apk --release
```

## Documentación

- `doc/` - Documentación del proyecto
- `doc/README.md` - Índice de documentación

---

**Última actualización:** Marzo 2026

# Core

Configuración base, servicios compartidos y utilidades de la aplicación.

## Estructura

```
core/
├── app/           # Configuración principal de la app
├── config/        # Configuraciones por entorno
├── constants/     # Constantes globales
├── errors/        # Manejo de errores
├── localization/  # Internacionalización
├── routing/       # Navegación (GoRouter)
└── utils/         # Utilidades y servicios
```

## Servicios Principales

| Servicio | Descripción |
|----------|-------------|
| `FirebaseAuthService` | Autenticación Firebase + Google Sign In |
| `ShareService` | Compartir contenido |
| `CacheService` | Caché en memoria |
| `LocalCacheService` | Caché persistente con Hive |
| `ConnectivityService` | Monitoreo de conectividad |

## Utilidades

| Archivo | Descripción |
|---------|-------------|
| `app_utils.dart` | Utilidades generales |
| `auth_state.dart` | Enum de estados de autenticación |
| `firebase_config_loader.dart` | Carga configuración Firebase |
| `result.dart` | Patrón Result para errores funcionales |

## Principios

1. **Independencia** - No depende de otras capas
2. **Reutilización** - Componentes genéricos
3. **Configurabilidad** - Fácil modificación por entorno

---

**Última actualización:** Marzo 2026

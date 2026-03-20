# DI (Dependency Injection)

Inyección de dependencias con GetIt (Service Locator).

## Archivo Principal

| Archivo | Descripción |
|---------|-------------|
| `service_locator.dart` | Configuración de todas las dependencias |

## Servicios Registrados

### Core
- `AppConfig` - Configuración de la app
- `FirebaseAuthService` - Autenticación Firebase
- `CacheService` - Caché en memoria
- `LocalCacheService` - Caché persistente (Hive)
- `ConnectivityService` - Conectividad
- `ShareService` - Compartir

### Data
- `SupabaseClientService` - Cliente Supabase

### Repositorios
- `AuthRepository`
- `TiendaRepository`
- `ProductoRepository`
- `PlazoletaRepository`
- `OrganizacionRepository`
- `FavoritoRepositoryImpl`

### BLoCs
- `AuthBloc`
- `FavoritoBloc`
- `TiendaBloc`
- `ProductoBloc`
- `PlazoletaBloc`
- `OrganizacionBloc`
- `ImageBloc`

## Tipos de Registro

| Tipo | Uso |
|------|-----|
| `registerSingleton` | Instancia única compartida |
| `registerLazySingleton` | Se crea solo cuando se necesita |
| `registerFactory` | Nueva instancia cada vez |

---

**Última actualización:** Marzo 2026

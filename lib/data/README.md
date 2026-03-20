# Data

Capa de datos - implementaciones de repositorios y fuentes de datos.

## Estructura

```
data/
├── datasources/
│   ├── local/       # Fuentes locales (Hive)
│   └── remote/      # Fuentes remotas (Supabase, S3)
├── models/          # Modelos/DTOs de datos
└── repositories/    # Implementaciones de repositorios
```

## Repositorios Implementados

| Repositorio | Descripción |
|-------------|-------------|
| `AuthRepository` | Autenticación |
| `TiendaRepository` | Tiendas |
| `ProductoRepository` | Productos |
| `PlazoletaRepository` | Plazoletas |
| `OrganizacionRepository` | Organizaciones |
| `FavoritoRepositoryImpl` | Favoritos |

## Fuentes de Datos

### Remotas
- **SupabaseClientService** - Cliente PostgreSQL
- **Firebase services** - Auth, Storage

### Locales
- **LocalCacheService** - Hive para caché local
- **CacheService** - Caché en memoria

## Principios

1. **Patrón Repository** - Abstracción del acceso a datos
2. **Caching estratégico** - Datos en local y remoto
3. **Transformación** - DTOs → Entidades de dominio

---

**Última actualización:** Marzo 2026

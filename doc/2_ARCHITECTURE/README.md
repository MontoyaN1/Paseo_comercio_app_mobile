# 2. Arquitectura

Documentación de la arquitectura técnica del proyecto.

## Archivos

| Archivo | Descripción |
|---------|-------------|
| [ESTRUCTURA_PROYECTO.md](./ESTRUCTURA_PROYECTO.md) | Arquitectura Clean Architecture completa del proyecto Flutter |

## Arquitectura Resumida

```
lib/
├── core/           # Funcionalidad core (app, config, constants, routing, utils)
├── domain/         # Capa de dominio (entities, failures, repositories, usecases)
├── data/           # Capa de datos (datasources, models, repositories)
├── presentation/   # Capa de presentación (blocs, pages, widgets)
└── di/             # Inyección de dependencias (GetIt)
```

## Patrones Implementados

- **Clean Architecture** - Separación en 4 capas
- **BLoC Pattern** - Gestión de estado con flutter_bloc
- **Repository Pattern** - Abstracción de fuentes de datos
- **Service Locator** - Inyección de dependencias con GetIt

## BLoCs Implementados

1. `AuthBloc` - Autenticación
2. `FavoritoBloc` - Sistema de favoritos
3. `ImageBloc` - Manejo de imágenes
4. `OrganizacionBloc` - Organizaciones
5. `PlazoletaBloc` - Plazoletas
6. `ProductoBloc` - Productos
7. `TiendaBloc` - Tiendas

## Tecnologías

- **State Management:** flutter_bloc
- **Navigation:** go_router
- **Local Storage:** Hive
- **Backend:** Supabase PostgreSQL
- **Auth:** Firebase Auth + Google Sign In
- **Image Storage:** Cloudflare R2 + Supabase Storage

---

**Última actualización:** Marzo 2026

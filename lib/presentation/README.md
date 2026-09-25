# Presentation

Capa de presentación - UI y gestión de estado con BLoC.

## Estructura

```
presentation/
├── blocs/          # BLoCs (estado y lógica de negocio)
├── pages/          # Pantallas/páginas
├── widgets/        # Widgets reutilizables
└── providers/      # Providers (theme provider)
```

## BLoCs

| BLoC | Descripción |
|------|-------------|
| `AuthBloc` | Autenticación y sesión |
| `FavoritoBloc` | Sistema de favoritos |
| `TiendaBloc` | Catálogo de tiendas |
| `ProductoBloc` | Catálogo de productos |
| `PlazoletaBloc` | Plazoletas y áreas |
| `OrganizacionBloc` | Organizaciones |
| `ImageBloc` | Manejo de imágenes |

## Páginas Principales

| Página | Descripción |
|--------|-------------|
| `auth/` | Login, splash |
| `profile/` | Perfil de usuario |
| `tiendas/` | Lista y detalle de tiendas |
| `productos/` | Lista y detalle de productos |
| `plazoletas/` | Lista y detalle de plazoletas |
| `organizaciones/` | Lista y detalle de organizaciones |
| `settings/` | Configuración |
| `soporte/` | Soporte |
| `historial/` | Historial (postergado) |

## Widgets Comunes

| Widget | Descripción |
|--------|-------------|
| `TiendaCard` | Tarjeta de tienda |
| `ProductoCard` | Tarjeta de producto |
| `ProfileFloatingButton` | FAB de navegación |
| `ShareButton` | Botón de compartir |
| `CustomAppBar` | AppBar glassmorphism |

## Patrón BLoC

```
UI → Event → Bloc → State → UI
```

---

**Última actualización:** Marzo 2026

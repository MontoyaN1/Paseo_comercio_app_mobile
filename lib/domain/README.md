# Domain

Capa de dominio - entidades de negocio e interfaces de repositorios.

## Estructura

```
domain/
├── entities/      # Entidades de negocio
├── failures/      # Tipos de errores de dominio
├── repositories/  # Interfaces de repositorios
└── usecases/     # Casos de uso
```

## Entidades

| Entidad | Descripción |
|---------|-------------|
| `Usuario` | Usuario del sistema |
| `Tienda` | Tienda comercial |
| `Producto` | Producto |
| `Plazoleta` | Área/ubicación física |
| `Organizacion` | Organización comercial |
| `Categoria` | Categoría de producto |
| `Horario` | Horario de atención |
| `EtiquetaTienda` | Etiquetas de tienda |
| `EtiquetaProducto` | Etiquetas de producto |
| `Notificacion` | Notificación |
| `ImagenBase` | Modelo base de imagen |

## Interfaces de Repositorios

| Interfaz | Descripción |
|----------|-------------|
| `AuthRepositoryInterface` | Operaciones de autenticación |
| `TiendaRepositoryInterface` | Operaciones con tiendas |
| `ProductoRepositoryInterface` | Operaciones con productos |
| `PlazoletaRepositoryInterface` | Operaciones con plazoletas |
| `OrganizacionRepositoryInterface` | Operaciones organizacionales |
| `FavoritoRepositoryInterface` | Operaciones de favoritos |

## Principios

1. **Independencia** - No depende de frameworks externos
2. **Inmutabilidad** - Entidades inmutables con `copyWith`
3. **Validación** - Reglas de negocio en entidades

---

**Última actualización:** Marzo 2026

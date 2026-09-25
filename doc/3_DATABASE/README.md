# 3. Base de Datos

Documentación del esquema de PostgreSQL y estructuras de datos.

## Archivos

| Archivo | Descripción |
|---------|-------------|
| [ESQUEMA_BASE_DATOS.md](./ESQUEMA_BASE_DATOS.md) | Esquema completo de PostgreSQL (24+ tablas) |
| [ESQUEMA_FAVORITOS.md](./ESQUEMA_FAVORITOS.md) | Sistema de favoritos - tablas y SQL |

## Diagramas Mermaid

Located in parent `/diagrams/` directory:
- `entidades_completo.mmd` - Diagrama ER completo (24 tablas)
- `diagrama_favoritos.mmd` - Diagrama del sistema de favoritos

## Resumen de Tablas

### Tablas Principales (24)

| # | Tabla | Descripción |
|---|-------|-------------|
| 1 | usuario | Usuarios del sistema |
| 2 | roles | Roles disponibles |
| 3 | organizacion | Organizaciones |
| 4 | plazoleta | Ubicaciones físicas |
| 5 | categoria | Categorías de productos |
| 6 | tienda | Tiendas comerciales |
| 7 | producto | Productos |
| 8 | horario | Horarios de tiendas |
| 9 | valoracion_producto | Valoraciones |
| 10 | interaccion | Registro de interacciones |
| 11 | estadisticas_diarias | Estadísticas diarias |
| 12 | miembros_organizacion | Miembros de organizaciones |
| 13 | notificacion | Notificaciones |
| 14 | etiqueta_tienda | Etiquetas de tiendas |
| 15 | etiqueta_producto | Etiquetas de productos |
| 16 | imagen_tienda | Imágenes de tiendas |
| 17 | imagen_productos | Imágenes de productos |
| 18 | imagen_plazoleta | Imágenes de plazoletas |
| 19 | imagen_organizacion | Imágenes de organizaciones |
| 20 | imagen_valoracion_producto | Imágenes en valoraciones |
| 21 | contactos_empresa | Contactos de la empresa |
| 22 | redes_sociales | Redes sociales |
| 23 | trigger_logs | Logs de triggers |

### Tablas de Favoritos (2)

| # | Tabla | Descripción |
|---|-------|-------------|
| 24 | tienda_favorito | Favoritos de tiendas |
| 25 | producto_favorito | Favoritos de productos |

## Tecnologías

- **PostgreSQL** via Supabase
- **RLS Policies** para seguridad
- **Triggers** para automatizaciones
- **Índices** optimizados para queries frecuentes

---

**Última actualización:** Marzo 2026

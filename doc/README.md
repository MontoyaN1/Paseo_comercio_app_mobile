# 📚 DOCUMENTACIÓN - Paseo del Comercio App Móvil

Esta carpeta contiene toda la documentación del proyecto organizada por temas.

## 📋 ESTRUCTURA DE CARPETAS

```
doc/
├── README.md              # Este archivo
├── AGENTS.md              # Guía para agentes IA
├── PROPUESTAS_UI.md       # Propuestas de diseño UI/UX
├── PROGRESO_Y_PLAN.md     # Estado del proyecto y roadmap
│
├── db/                    # Documentación de Base de Datos
│   ├── ESQUEMA_BASE_DATOS.md    # Esquema completo de PostgreSQL
│   └── ESQUEMA_FAVORITOS.md     # Sistema de favoritos (nuevo)
│
├── architecture/          # Documentación de Arquitectura
│   └── ESTRUCTURA_PROYECTO.md   # Arquitectura Clean Architecture
│
└── diagrams/              # Diagramas Mermaid
    ├── entidades_completo.mmd  # Diagrama ER completo (24 tablas)
    └── diagrama_favoritos.mmd   # Diagramas del sistema de favoritos
```

## 📋 ÍNDICE DE DOCUMENTACIÓN

### 1. 🗃️ **db/ESQUEMA_BASE_DATOS.md** - **BASE DE DATOS COMPLETA**
**Descripción:** Documentación completa del esquema de PostgreSQL.

**Contenido:**
- 24 tablas principales con columnas, tipos y constraints
- 8 tipos personalizados (enums) definidos
- 40+ relaciones entre tablas documentadas
- Índices y triggers para optimización
- **NUEVO:** Tablas `tienda_favorito` y `producto_favorito`

### 2. 🗃️ **db/ESQUEMA_FAVORITOS.md** - **SISTEMA DE FAVORITOS**
**Descripción:** Documentación del sistema de favoritos.

**Contenido:**
- SQL de creación de tablas
- Funciones RPC
- Entidades Flutter
- Estados y eventos del BLoC
- Flujo de usuario

### 3. 📊 **PROGRESO_Y_PLAN.md** - **ESTADO Y PLANIFICACIÓN**
**Descripción:** Estado actual del proyecto y plan de implementación.

### 4. 🏗️ **architecture/ESTRUCTURA_PROYECTO.md** - **ARQUITECTURA TÉCNICA**
**Descripción:** Estructura técnica completa del proyecto Flutter.

### 5. 🎨 **PROPUESTAS_UI.md** - **DISEÑO Y EXPERIENCIA**
**Descripción:** Propuestas de diseño, wireframes y flujos de usuario.

### 6. 🤖 **AGENTS.md** - **AUTOMATIZACIONES**
**Descripción:** Configuración de agentes, workflows y automatizaciones.

## 📊 Diagramas Mermaid

### diagrams/entidades_completo.mmd
Diagrama ER completo con las 24 tablas de la base de datos:
- Modelo Entidad-Relación completo
- Diagrama de relaciones simplificado
- Jerarquía de entidades
- Flujo de datos general
- Arquitectura Clean
- Tipos Enum definidos

### diagrams/diagrama_favoritos.mmd
Diagramas específicos del sistema de favoritos:
- Arquitectura del sistema
- Flujo de usuario (agregar/quitar)
- Carga de favoritos
- Estados del BLoC
- Navegación
- UI de la página

---

## 🚀 GUÍA RÁPIDA DE INICIO

### Para desarrolladores nuevos:
1. **Comienza con:** `PROGRESO_Y_PLAN.md` → Entiende el estado actual
2. **Luego revisa:** `db/ESQUEMA_BASE_DATOS.md` → Conoce la estructura de datos
3. **Continúa con:** `architecture/ESTRUCTURA_PROYECTO.md` → Entiende la arquitectura
4. **Finaliza con:** `PROPUESTAS_UI.md` → Conoce el diseño

### Tablas de Base de Datos (24 totales)

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
| 24 | ⭐ tienda_favorito | Favoritos de tiendas (NUEVO) |
| 25 | ⭐ producto_favorito | Favoritos de productos (NUEVO) |

---

**📅 Última actualización:** 2026-03-17  
**📁 Estructura:** ✅ **Organizada en carpetas**  
**🔗 Diagramas:** ✅ **Mermaid (.mmd)**  
**📊 Total tablas:** 24 + 2 nuevas (favoritos)

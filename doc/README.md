# 📚 DOCUMENTACIÓN - Paseo del Comercio App Móvil

Esta carpeta contiene toda la documentación del proyecto organizada por temas.

## 📋 ÍNDICE DE DOCUMENTACIÓN

### 1. 🗃️ **ESQUEMA_BASE_DATOS.md** - **BASE DE DATOS COMPLETA**
**Descripción:** Documentación completa del esquema de base de datos PostgreSQL.

**Contenido:**
- 22 tablas principales con columnas, tipos y constraints
- 8 tipos personalizados (enums) definidos
- 40+ relaciones entre tablas documentadas
- Índices y triggers para optimización
- Consideraciones específicas para app Flutter
- Diagramas de relaciones y consultas optimizadas

**Relevancia para objetivos de la app:**
- ✅ **Objetivo 2-3:** Tabla `plazoleta` y relaciones con imágenes
- ✅ **Objetivo 4:** Tablas `tienda` y `producto` con todas las relaciones
- ✅ **Objetivo 5-6:** Tabla `organizacion` con miembros e imágenes
- ✅ **Login/Cuentas:** Tabla `usuario` integrada con Clerk

### 2. 📊 **PROGRESO_Y_PLAN.md** - **ESTADO Y PLANIFICACIÓN**
**Descripción:** Estado actual del proyecto y plan de implementación.

**Contenido:**
- Estado actual: 92% Fase 1 completada
- Plan de 12 semanas por fases
- Lo completado y pendiente por hacer
- Próximos pasos inmediatos (7 días para MVP)
- Métricas de calidad y verificaciones técnicas
- Equipo recomendado y credenciales necesarias

**Estadísticas clave:**
- 19 entidades del dominio definidas
- 4 BLoCs implementados (Auth, Tienda, Producto, Image)
- 150+ archivos, 15,000+ líneas de código
- Servicios core funcionando (Cache, Connectivity, ImageService)

### 3. 🏗️ **ESTRUCTURA_PROYECTO.md** - **ARQUITECTURA TÉCNICA**
**Descripción:** Estructura técnica completa del proyecto Flutter.

**Contenido:**
- Arquitectura Clean Architecture (4 capas)
- Servicios core implementados:
  - CacheService (Hive con TTL)
  - ConnectivityService (monitoreo red)
  - ImageService (multi-CDN: R2 → S3 → Supabase)
  - AuthService (Clerk + Supabase + Guest)
- BLoCs, pantallas y widgets disponibles
- Integración con backend (Supabase, Clerk, Cloudflare R2)
- Estrategias técnicas (offline-first, seguridad, navegación)
- Variables de entorno y guías de configuración

### 4. 🎨 **PROPUESTAS_UI.md** - **DISEÑO Y EXPERIENCIA**
**Descripción:** Propuestas de diseño, wireframes y flujos de usuario.

**Contenido:**
- Propuestas de diseño UI/UX
- Wireframes y mockups
- Flujos de navegación recomendados
- Componentes de interfaz reutilizables
- Consideraciones de usabilidad móvil
- Temas y paletas de colores

### 5. 🤖 **AGENTS.md** - **AUTOMATIZACIONES**
**Descripción:** Configuración de agentes, workflows y automatizaciones.

**Contenido:**
- Configuración de agentes de desarrollo
- Workflows de CI/CD
- Automatizaciones de testing
- Integraciones con herramientas externas
- Scripts y utilidades

## 🎯 OBJETIVOS DE LA APP - MAPA DE DOCUMENTACIÓN

| Objetivo | Documentación Relevante | Tablas DB Involucradas |
|----------|------------------------|------------------------|
| 1. Login y crear cuenta | `PROGRESO_Y_PLAN.md`<br>`ESTRUCTURA_PROYECTO.md` | `usuario`, `roles` |
| 2. Ver todas las plazoletas | `ESQUEMA_BASE_DATOS.md`<br>`PROPUESTAS_UI.md` | `plazoleta`, `imagen_plazoleta` |
| 3. Ver cada plazoleta | `ESQUEMA_BASE_DATOS.md` | `plazoleta`, `imagen_plazoleta`, `categoria` |
| 4. Ver tiendas y productos | `ESQUEMA_BASE_DATOS.md`<br>`PROGRESO_Y_PLAN.md` | `tienda`, `producto`, `imagen_tienda`, `imagen_productos`, `horario`, `etiqueta_*` |
| 5. Ver organizaciones | `ESQUEMA_BASE_DATOS.md` | `organizacion`, `miembros_organizacion`, `imagen_organizacion` |
| 6. Ver cada organización | `ESQUEMA_BASE_DATOS.md` | `organizacion`, `miembros_organizacion`, `imagen_organizacion`, `tienda` |

## 🚀 GUÍA RÁPIDA DE INICIO

### Para desarrolladores nuevos:
1. **Comienza con:** `PROGRESO_Y_PLAN.md` → Entiende el estado actual
2. **Luego revisa:** `ESQUEMA_BASE_DATOS.md` → Conoce la estructura de datos
3. **Continúa con:** `ESTRUCTURA_PROYECTO.md` → Entiende la arquitectura
4. **Finaliza con:** `PROPUESTAS_UI.md` → Conoce el diseño

### Para configurar el proyecto:
1. **Variables obligatorias:** Ver `ESTRUCTURA_PROYECTO.md#variables-de-entorno`
2. **Configuración Clerk:** Solo necesitas `CLERK_PUBLISHABLE_KEY`
3. **Configuración Supabase:** URL + ANON_KEY + SERVICE_ROLE_KEY
4. **Cloudflare R2 (opcional):** Para migración multi-CDN de imágenes

### Para entender la base de datos:
1. **Tablas principales:** Ver `ESQUEMA_BASE_DATOS.md#tablas-principales`
2. **Relaciones:** Ver `ESQUEMA_BASE_DATOS.md#diagrama-de-relaciones`
3. **Consultas optimizadas:** Ver `ESQUEMA_BASE_DATOS.md#consultas-optimizadas-para-móvil`

## 📞 SOPORTE Y ACTUALIZACIONES

### Mantenimiento de documentación:
- **Última actualización:** Reorganización completa de documentación
- **Responsable:** Equipo de desarrollo Flutter
- **Frecuencia de actualización:** Semanal o con cambios significativos

### Reportar problemas o mejoras:
1. **Documentación desactualizada:** Actualizar archivos correspondientes
2. **Información faltante:** Agregar a archivo relevante
3. **Errores técnicos:** Corregir en fuente y documentación

### Convenciones de documentación:
- **Archivos MD:** Usar formato Markdown con encabezados claros
- **Código SQL:** Incluir en bloques de código con sintaxis SQL
- **Diagramas:** Usar Mermaid o texto ASCII para claridad
- **Referencias cruzadas:** Enlazar entre archivos cuando sea relevante

---

**📅 Última reorganización:** Documentación consolidada en carpeta `doc/`  
**📊 Cobertura:** 100% de objetivos documentados  
**🔗 Integración:** Documentación alineada con código y base de datos  
**🎯 Estado:** ✅ **DOCUMENTACIÓN COMPLETA Y ORGANIZADA**

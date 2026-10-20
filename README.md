# Paseo del Comercio - Aplicación Móvil

Aplicación Flutter para el Centro Comercial Virtual "Paseo del Comercio". 
Arquitectura Clean Architecture con integración Supabase, Clerk y Cloudflare R2.

> **Vigencia:** el plan normativo es
> [`doc/1_PROJECT/PLAN_IMPLEMENTACION_FASES.md`](doc/1_PROJECT/PLAN_IMPLEMENTACION_FASES.md).
> Las secciones históricas de este README (Clerk, Contabo, 22 tablas, 92%) están desactualizadas:
> el proyecto usa Firebase Auth, Cloudflare R2 y PostgreSQL en Supabase.

## TRABAJO EN PARALELO — 4 TAREAS

**La Fase 0.5 — Contratos ya está completada** (commit `a872933`): modo invitado eliminado,
`hasRole()` real, rutas con stubs y migración `0006` creada. Las 4 personas pueden empezar
el día 1 sin esperar a nadie. Único pendiente operativo: **A debe ejecutar `0006` en el SQL
Editor de Supabase** (el archivo ya está en el repo).

### Reglas para no bloquearse

| Regla | Detalle |
|---|---|
| Fase 0.5 completada | Modo invitado eliminado, `hasRole()` real, rutas con stubs y `0006` creada. Solo falta ejecutar `0006` en Supabase. |
| Nombres finales desde el día 1 | Los stubs usan las clases definitivas (`MisTiendasPage`, `MiOrganizacionPage`, `NotificacionesPage`, etc.). Cada dueño rellena el cuerpo; **nadie edita el router después**. |
| Un dueño por archivo caliente | `app_router.dart`, `service_locator.dart` y `app_constants.dart` los mergea solo A. |
| DI sin conflictos | Cada dueño agrega su bloque de registro al final de la sección que le corresponde; A resuelve el merge. |
| Migraciones | Solo A las aplica en Supabase. C diseña las reglas de invitación y las revisa. |
| Ramas | `feat/a-nucleo`, `feat/b-comercio`, `feat/c-organizacion`, `feat/d-experiencia`. |
| PR | `flutter analyze` sin errores + revisión cruzada. |
| Documentos prohibidos | No editar `doc/2_ARCHITECTURE/*`. |

### Tarea A — Núcleo, roles y administración

**Fases:** 1, 2.
**Puede empezar:** día 1, sin esperar a nadie.
**Estado:** Fase 0.5 cerrada (commit `a872933`); Fase 1 base implementada (commit `73ee4fa`).

**Documentación de contexto:**
- `doc/1_PROJECT/PLAN_IMPLEMENTACION_FASES.md`: §1, §2.1, §2.2, §4 → Fase 1, §4 → Fase 2, §5.1.
- `doc/1_PROJECT/ANALISIS_DE_REQUERIMIENTOS.md`: RF-01, RF-02.
- `doc/2_ARCHITECTURE/ESTRUCTURA_PROYECTO.md`: capas, DI y routing (solo lectura).
- `doc/AGENTS.md`: comandos y estilo (verificar; puede estar desactualizado).

**Indicaciones:**
1. Fase 1: validar en dispositivo la redirección por rol y el guard estricto de `/admin` (la base ya está en `app_router.dart` y `AuthBloc`).
2. Fase 2: CRUD de plazoletas, implementar `CategoriaRepository`, panel admin y listados simples.

**Pendiente operativo:** ejecutar `supabase/migrations/0006_organizacion_invitaciones.sql` en el SQL Editor de Supabase.

**Archivos propios:** `auth_*`, `usuario.dart`, `plazoleta_repository*`, `categoria_repository.dart`, `usuario_repository*`, `presentation/pages/admin/*`, `app_router.dart`, `service_locator.dart`, `app_constants.dart`.

**Aceptación:** cliente → catálogo, vendedor → `/vendedor`, admin → `/admin`; sin “continuar como invitado”; CRUD admin funcional.

### Tarea B — Comercio: tiendas, productos y valoraciones

**Fases:** 3, 6.
**Puede empezar:** día 1 con handlers y repositorio; la UI desde el día 2, cuando existan los stubs de ruta.

**Documentación de contexto:**
- `doc/1_PROJECT/PLAN_IMPLEMENTACION_FASES.md`: §1, §2.5, §4 → Fase 3, §4 → Fase 6.
- `doc/1_PROJECT/ANALISIS_DE_REQUERIMIENTOS.md`: RF-03, RF-04, RF-07.
- Referencia de patrón: `lib/presentation/blocs/favorito/*`, `lib/data/repositories/favorito_repository_impl.dart`, `lib/data/datasources/remote/favorito_remote_datasource.dart`.

**Indicaciones:**
1. Registrar `on<TiendaCreateRequested>`, `on<TiendaUpdateRequested>`, `on<TiendaDeleteRequested>` y `on<TiendaByPropietarioRequested>` en `lib/presentation/blocs/tienda/tienda_bloc.dart` (hoy los eventos existen pero no están registrados).
2. Hacer lo mismo con los eventos CRUD de `lib/presentation/blocs/producto/producto_bloc.dart`.
3. Construir formularios, subida de imágenes con `lib/core/utils/image_service.dart:199` y pantallas “Mis tiendas” / “Mis productos”.
4. Validar propiedad en repositorio y BLoC: solo el dueño edita/elimina; usar `PermissionFailure`.
5. Fase 6: crear interfaz, data source, repositorio y BLoC de valoraciones; mover el insert inline de `lib/presentation/pages/productos/producto_detail_page.dart:518`.
6. Permitir editar/eliminar la reseña propia y calcular promedio real.

**Archivos propios:** `tienda_bloc.dart`, `producto_bloc.dart`, `tienda_repository.dart`, `producto_repository.dart`, `presentation/pages/vendedor/{mis_tiendas,mis_productos,tienda_form,producto_form}_page.dart`, `presentation/blocs/valoracion/*`, `data/**/valoracion*`, `producto_detail_page.dart`, `presentation/widgets/producto/detail/*`.

**Aceptación:** CRUD completo; un vendedor no puede tocar tiendas de otro; una reseña por usuario, editable y eliminable.

### Tarea C — Notificaciones, organización e invitaciones

**Fases:** 4, 5, 7 (condicional).
**Puede empezar:** día 1 con la entidad y el repositorio; la UI desde el día 2. La migración `0006` la aplica A el día 1.

**Documentación de contexto:**
- `doc/1_PROJECT/PLAN_IMPLEMENTACION_FASES.md`: §2.2, §2.3, §2.4, §4 → Fase 4, §4 → Fase 5, §5.1, §5.2.
- `doc/1_PROJECT/ANALISIS_DE_REQUERIMIENTOS.md`: RF-05, RF-09.1.
- `supabase/migrations/0002_tables.sql` y `0005_seed.sql`: columnas reales de `notificacion`, `organizacion` y `miembros_organizacion`.

**Indicaciones:**
1. Alinear `lib/domain/entities/notificacion.dart` con la tabla real (`destinatario_id`, `asunto`, `created_at`, `accion_url`, `referencia_id`, `referencia_tipo`, `metadata`).
2. Crear repositorio, data source, BLoC, bandeja y badge de no leídas.
3. Corregir `createOrganizacion` en `lib/data/repositories/organizacion_repository.dart:871` (inserta la columna inexistente `metadata`) y registrar al dueño como miembro `Activo`.
4. Implementar invitaciones: buscar por correo, validar que sea vendedor, que no sea uno mismo, que no pertenezca a otra organización y que no tenga invitación pendiente.
5. Registrar `on<InviteToOrganizacion>`, `on<AcceptInvitation>` y `on<RejectInvitation>` en `lib/presentation/blocs/organizacion/organizacion_bloc.dart`.
6. Insertar notificación en cada transición (`invitacion_organizacion`, `aceptacion_invitacion`, `rechazo_invitacion`).
7. Fase 7 solo si las fases 4 y 5 están cerradas.

**Archivos propios:** `notificacion*`, `organizacion*`, `presentation/pages/vendedor/{mi_organizacion,invitaciones}_page.dart`, `presentation/widgets/organizacion/*`, `core/services/push_notification_service.dart`, `supabase/functions/send-push/*`, `0007_push.sql`.

**Aceptación:** ciclo invitar → notificar → aceptar/rechazar → notificar → re-invitar; una sola organización por usuario; borrado bloqueado si hay tiendas.

### Tarea D — Experiencia, QA y entrega

**Fases:** 8, 9.
**Puede empezar:** día 1 (la Fase 8 no depende de nadie).

**Documentación de contexto:**
- `doc/1_PROJECT/PLAN_IMPLEMENTACION_FASES.md`: §4 → Fase 8, §4 → Fase 9, §7 (matriz de pruebas), §8 (riesgos).
- `doc/1_PROJECT/ANALISIS_DE_REQUERIMIENTOS.md`: RF-06, RF-08, RF-09.2, RF-09.3, RF-10.

**Indicaciones:**
1. Favoritos: persistencia y reactividad al iniciar/cerrar sesión (RF-06).
2. Historial local y limpieza de caché (RF-08.1).
3. Compartir robusto, sin dejar la app cargando (RF-08.2).
4. Mapa embebido con fallback al navegador (RF-08.3).
5. Ajustes: tema persistente y limpiar caché (RF-09.2).
6. Soporte, términos y privacidad (RF-09.3).
7. Escribir y ejecutar la matriz de pruebas y la regresión.
8. Preparar APK release, actualizar documentación y guion de demo.

**Archivos propios:** `presentation/blocs/favorito/*`, `presentation/pages/favoritos/*`, `presentation/pages/historial/*`, `core/utils/share_service.dart`, `core/utils/app_utils.dart`, `presentation/pages/settings/*`, `presentation/pages/soporte/*`, `test/*`, documentos de cierre.

**Aceptación:** RF restantes validados, APK instalable y documentación sin referencias a Contabo.

### Cronograma paralelo (3 semanas)

| Semana | A | B | C | D |
|---|---|---|---|---|
| 1 | Fase 1 | Fase 3 (handlers + UI) | Fase 4 + inicio Fase 5 | Fase 8 (favoritos/historial/share) + matriz |
| 2 | Cierre Fase 1 + Fase 2 | Cierre Fase 3 + Fase 6 | Fase 5 (invitaciones) | Cierre Fase 8 + regresión |
| 3 | Cierre Fase 2 + apoyo | Cierre Fase 6 + apoyo QA | Cierre Fase 5 (+ Fase 7) | Fase 9 (APK, docs, demo) |

### Reglas de código que aplican a las 4 tareas

- Ninguna página llama a Supabase directamente: pasa por repositorio.
- Toda feature nueva sigue el orden entidad → interfaz → data source → repositorio → DI → BLoC → página → ruta.
- Usar `Result`/`Failure` y `Equatable`; no introducir `dartz`.
- No reintroducir Contabo, Wompi ni modo invitado.
- `flutter analyze` sin errores antes de cada PR.

## 📋 DOCUMENTACIÓN ORGANIZADA


Toda la documentación está organizada en la carpeta `doc/`:

### 📁 **doc/ESQUEMA_BASE_DATOS.md** - **NUEVO**
- **Entidades:** 22 tablas documentadas con columnas y tipos
- **Relaciones:** 40+ relaciones entre tablas
- **Enums/Tipos:** 8 tipos personalizados (tipo_horario, tipo_imagen, etc.)
- **Índices y Triggers:** Optimizaciones para performance móvil
- **Consideraciones Flutter:** BLoCs recomendados, modelos, consultas optimizadas

### 📊 **doc/PROGRESO_Y_PLAN.md**
- Estado actual del proyecto (92% completado - Fase 1)
- Plan de implementación por fases (12 semanas)
- Lo completado y pendiente por hacer
- Próximos pasos inmediatos
- Métricas y verificaciones técnicas

### 🏗️ **doc/ESTRUCTURA_PROYECTO.md**
- Estructura completa de carpetas (Clean Architecture)
- Servicios core implementados (Cache, Connectivity, Image, Auth)
- BLoCs, pantallas y widgets disponibles
- Integración con backend (Supabase, Clerk, R2)
- Estrategias técnicas (offline-first, multi-CDN, seguridad)

### 🎨 **doc/PROPUESTAS_UI.md**
- Propuestas de diseño y experiencia de usuario
- Wireframes y flujos de navegación
- Componentes de interfaz recomendados

### 🤖 **doc/AGENTS.md**
- Configuración de agentes y automatizaciones
- Workflows de desarrollo
- Integraciones con herramientas externas

## 🎯 OBJETIVOS DE LA APP

### ✅ **OBJETIVOS PRINCIPALES:**
1. **Permitir login y crear cuenta** → Clerk configurado
2. **Ver todas las plazoletas** → Tabla `plazoleta` disponible
3. **Ver cada plazoleta** → Relaciones con imágenes definidas
4. **Ver las tiendas y productos** → Tablas `tienda` y `producto` con relaciones
5. **Ver las organizaciones** → Tabla `organizacion` con miembros e imágenes
6. **Ver cada organización** → Relaciones completas definidas

### 🔄 **SINCRONIZACIÓN CON APP WEB:**
- **Misma base de datos** → Compatibilidad garantizada
- **Estrategia multi-CDN** → Imágenes compartidas (R2 → S3 → Supabase)
- **Autenticación unificada** → Clerk como SSO
- **Datos consistentes** → Triggers y constraints en DB

## 🚀 INICIO RÁPIDO

### 1. Clonar y configurar
```bash
git clone <repository-url>
cd paseo-del-comercio-app-mobile-flutter
# Consulta doc/ESTRUCTURA_PROYECTO.md para todas las variables requeridas
cp .env.example .env
# Editar .env con tus credenciales
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Configurar credenciales (mínimo para funcionar):
```env
# Supabase (obligatorio)
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anon
SUPABASE_SERVICE_ROLE_KEY=tu-clave-servicio

# Clerk (obligatorio)
CLERK_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxxxxxxxxxxxxx
```

### 4. Ejecutar aplicación
```bash
flutter run
```

## 📱 ESTADO ACTUAL

✅ **FASE 1 COMPLETADA (92%)** - Estructura base lista
- Clean Architecture implementada (4 capas)
- **19 entidades** del dominio definidas
- **4 BLoCs** completos (Auth, Tienda, Producto, Image)
- **Servicios core** funcionando (Cache, Connectivity, ImageService)
- **Conexión Supabase** verificada (22 tablas accesibles)
- **Autenticación Clerk** integrada (solo publishableKey necesaria)
- **Navegación GoRouter** configurada (15+ rutas)
- **Widgets reutilizables** creados (TiendaCard, ProductoCard, ResilientImage)

🎯 **PRÓXIMO MVP:** 7 días para app funcional con:
- Autenticación Clerk + modo invitado
- Lista de tiendas con imágenes (multi-CDN)
- Detalle de tienda básico
- Perfil de usuario completo
- Navegación fluida entre secciones

## 🏗️ ARQUITECTURA TÉCNICA

### Clean Architecture - 4 Capas
```
lib/
├── core/      # Configuración y servicios compartidos
├── domain/    # Lógica de negocio (19 entidades)
├── data/      # Implementación de datos (Supabase + Hive)
├── presentation/ # UI (BLoCs + Widgets + Pages)
└── di/        # Dependency Injection (GetIt)
```

### Tecnologías Principales
- **Flutter 3.7+** - Framework UI multiplataforma
- **Supabase** - Base de datos PostgreSQL + Realtime
- **Clerk** - Autenticación simplificada (social logins, temas en dashboard)
- **Cloudflare R2** - Almacenamiento de imágenes (migración multi-CDN)
- **Hive** - Caché local offline-first
- **BLoC** - Gestión de estado reactiva
- **GetIt** - Service Locator / Dependency Injection
- **GoRouter** - Navegación declarativa con deep linking

### Estrategia Multi-CDN para Imágenes
```dart
// Orden de fallback automático:
1. Cloudflare R2 (primary - mejor performance/costo)
2. Contabo S3 (fallback 1 - existente)
3. Supabase Storage (fallback 2 - garantizado)
4. Asset local (último recurso - placeholder)
```

## 📊 BASE DE DATOS - RESUMEN

### 📋 **22 Tablas Principales:**
1. `usuario` - Usuarios con autenticación Clerk
2. `tienda` - Tiendas del centro comercial
3. `producto` - Productos ofrecidos
4. `organizacion` - Organizaciones que agrupan tiendas
5. `plazoleta` - Ubicaciones físicas
6. `valoracion_producto` - Reseñas de productos
7. `interaccion` - Registro de interacciones
8. `estadisticas_diarias` - Estadísticas agregadas
9. `miembros_organizacion` - Miembros de organizaciones
10. `notificacion` - Sistema de notificaciones
11. `horario` - Horarios de tiendas
12. `etiqueta_tienda` / `etiqueta_producto` - Categorización
13. `imagen_tienda` / `imagen_productos` / `imagen_plazoleta` / `imagen_organizacion` - Imágenes
14. `contactos_empresa` / `redes_sociales` - Información de contacto
15. `roles` - Roles del sistema
16. `trigger_logs` - Logs para debugging

### 🔗 **8 Tipos Personalizados (Enums):**
- `tipo_horario`, `tipo_imagen`, `tipo_organizacion`, `tipo_ubicacion`
- `estado_producto`, `estado_usuario`, `estado_valoracion`, `tipo_rol`

**📖 Ver `doc/ESQUEMA_BASE_DATOS.md` para documentación completa**

## 🔧 CONFIGURACIÓN COMPLETA

### Variables obligatorias (mínimo):
```env
# Supabase
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anon
SUPABASE_SERVICE_ROLE_KEY=tu-clave-servicio

# Clerk (solo publishableKey necesaria)
CLERK_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxxxxxxxxxxxxx
```

### Cloudflare R2 (opcional - para migración multi-CDN):
```env
CLOUDFLARE_ACCOUNT_ID=1234567890abcdef1234567890abcdef
CLOUDFLARE_R2_ACCESS_KEY_ID=1234567890abcdef1234567890abcdef
CLOUDFLARE_R2_SECRET_ACCESS_KEY=abcdef1234567890abcdef1234567890abcdef1234567890abcdef
CLOUDFLARE_R2_BUCKET_NAME=paseo-del-comercio-images
CLOUDFLARE_R2_PUBLIC_URL=https://pub-1234567890abcdef.r2.dev
```

**📋 Ver `doc/ESTRUCTURA_PROYECTO.md` para configuración completa con guías paso a paso**

## 📊 MÉTRICAS DE CALIDAD

- ✅ **Compila sin errores** - Verificado
- 🎯 **< 2s cold start** - Objetivo
- 🎯 **< 500ms carga imágenes** - Objetivo con multi-CDN
- 🎯 **0 crashes flujos principales** - Objetivo
- ✅ **Arquitectura testable** - Implementada (Clean Architecture)
- ✅ **Offline-first** - Cache con Hive + sincronización
- ✅ **Performance móvil** - Índices y consultas optimizadas

## 🚀 PRÓXIMOS PASOS

### 🔥 **Prioridad Alta (Esta semana):**
1. **Testing de integración** - Verificar conexión real con Supabase
2. **Pantallas de detalle** - TiendaDetailPage y ProductoDetailPage
3. **BLoCs faltantes** - OrganizacionBloc y PlazoletaBloc
4. **Testing R2** - Verificar carga de imágenes desde Cloudflare R2

### 📅 **Prioridad Media (Próxima semana):**
1. **Testing Unitario** - Coverage mínimo 70%
2. **Optimización Performance** - Bundle size y lazy loading
3. **CI/CD Pipeline** - GitHub Actions para builds automáticos
4. **Pantallas según objetivos** - PlazoletaListPage, OrganizacionDetailPage

### 🎨 **Prioridad Baja (Mes 2):**
1. **Temas Avanzados** - Dark mode completo
2. **Animaciones** - Transiciones y micro-interacciones
3. **Accessibilidad** - Soporte completo para screen readers
4. **Internacionalización** - Soporte multi-idioma

**📅 Ver `doc/PROGRESO_Y_PLAN.md` para plan completo de 12 semanas**

## 📞 SOPORTE Y CONTACTO

### Equipo Recomendado:
- **1-2 Desarrolladores Flutter** - UI + BLoCs + Testing
- **1 Backend/DevOps** - Supabase + Cloudflare + CI/CD
- **1 QA/Testing** - Testing + documentación
- **1 Producto/Diseño** - UX/UI + feedback usuarios

### Credenciales Requeridas:
1. **Supabase Dashboard** - `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`
2. **Clerk Dashboard** - `CLERK_PUBLISHABLE_KEY` (dashboard.clerk.com)
3. **Cloudflare R2** (opcional) - Para migración multi-CDN

### Documentación Completa:
- **📖 `doc/ESQUEMA_BASE_DATOS.md`** - Esquema completo de base de datos
- **📊 `doc/PROGRESO_Y_PLAN.md`** - Estado y planificación
- **🏗️ `doc/ESTRUCTURA_PROYECTO.md`** - Arquitectura y configuración
- **🎨 `doc/PROPUESTAS_UI.md`** - Diseño y experiencia
- **🤖 `doc/AGENTS.md`** - Automatizaciones y workflows

---

**📅 Última actualización:** Documentación reorganizada y esquema DB agregado  
**🎯 Estado:** ✅ **92% FASE 1 COMPLETADA** - LISTO PARA MVP  
**📁 Documentación:** Organizada en carpeta `doc/`  
**🗃️ Base de datos:** 22 tablas documentadas con relaciones  
**📱 Objetivos:** 6 objetivos principales definidos y alineados con DB  
**🔧 Configuración:** Clerk simplificado + Supabase + R2 multi-CDN

# Paseo del Comercio - Aplicación Móvil

Aplicación Flutter para el Centro Comercial Virtual "Paseo del Comercio". 
Arquitectura Clean Architecture con integración Supabase, Firebase Auth y Cloudflare R2.

> **Plan normativo:** [`doc/1_PROJECT/PLAN_IMPLEMENTACION_FASES.md`](doc/1_PROJECT/PLAN_IMPLEMENTACION_FASES.md).

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
- `doc/AGENTS.md`: comandos y estilo.

**Indicaciones:**
1. Fase 1: validar en dispositivo la redirección por rol y el guard estricto de `/admin` (la base ya está en `app_router.dart` y `AuthBloc`).
2. Fase 2: CRUD de plazoletas, implementar `CategoriaRepository`, panel admin y listados simples.

**Pendiente operativo:** ejecutar `supabase/migrations/0006_organizacion_invitaciones.sql` en el SQL Editor de Supabase.

**Archivos propios:** `auth_*`, `usuario.dart`, `plazoleta_repository*`, `categoria_repository.dart`, `usuario_repository*`, `presentation/pages/admin/*`, `app_router.dart`, `service_locator.dart`, `app_constants.dart`.

**Aceptación:** cliente → catálogo, vendedor → `/vendedor`, admin → `/admin`; sin “continuar como invitado”; CRUD admin funcional.

### Tarea B — Comercio: tiendas, productos, valoraciones y favoritos

**Fases:** 3, 6, 8.1.
**Puede empezar:** día 1 con handlers y repositorio; la UI desde el día 2, cuando existan los stubs de ruta.

**Documentación de contexto:**
- `doc/1_PROJECT/PLAN_IMPLEMENTACION_FASES.md`: §1, §2.5, §4 → Fase 3, §4 → Fase 6, §4 → Fase 8 (8.1).
- `doc/1_PROJECT/ANALISIS_DE_REQUERIMIENTOS.md`: RF-03, RF-04, RF-06, RF-07.
- Referencia de patrón: `lib/presentation/blocs/favorito/*`, `lib/data/repositories/favorito_repository_impl.dart`, `lib/data/datasources/remote/favorito_remote_datasource.dart`.

**Indicaciones:**
1. Registrar `on<TiendaCreateRequested>`, `on<TiendaUpdateRequested>`, `on<TiendaDeleteRequested>` y `on<TiendaByPropietarioRequested>` en `lib/presentation/blocs/tienda/tienda_bloc.dart` (hoy los eventos existen pero no están registrados).
2. Hacer lo mismo con los eventos CRUD de `lib/presentation/blocs/producto/producto_bloc.dart`.
3. Construir formularios, subida de imágenes con `lib/core/utils/image_service.dart:199` y pantallas “Mis tiendas” / “Mis productos”.
4. Validar propiedad en repositorio y BLoC: solo el dueño edita/elimina; usar `PermissionFailure`.
5. Fase 6: crear interfaz, data source, repositorio y BLoC de valoraciones; mover el insert inline de `lib/presentation/pages/productos/producto_detail_page.dart:518`.
6. Permitir editar/eliminar la reseña propia y calcular promedio real.
7. Fase 8.1: favoritos con persistencia y reactividad al iniciar/cerrar sesión, con estados vacío/error (RF-06).

**Archivos propios:** `tienda_bloc.dart`, `producto_bloc.dart`, `tienda_repository.dart`, `producto_repository.dart`, `presentation/pages/vendedor/{mis_tiendas,mis_productos,tienda_form,producto_form}_page.dart`, `presentation/blocs/valoracion/*`, `data/**/valoracion*`, `producto_detail_page.dart`, `presentation/widgets/producto/detail/*`, `presentation/blocs/favorito/*`, `presentation/pages/favoritos/*`.

**Aceptación:** CRUD completo; un vendedor no puede tocar tiendas de otro; una reseña por usuario, editable y eliminable; favoritos persisten y reaccionan a la sesión.

### Tarea C — Organización, invitaciones y notificaciones

**Fases:** 4, 5. **Fase 7 (push FCM):** stretch fuera de las 3 semanas.
**Puede empezar:** día 1 con la entidad y el repositorio; la UI desde el día 2. La migración `0006` la aplica A.
**Independencia:** C es dueño de **todo** el dominio de notificaciones (entidad, repositorio, BLoC, bandeja y los inserts de invitación). No se divide con D para evitar handoffs.

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
7. Fase 7 solo si 4 y 5 están cerradas y sobra tiempo; no cuenta para el compromiso de 3 semanas.

**Archivos propios:** `notificacion*`, `organizacion*`, `presentation/pages/vendedor/{mi_organizacion,invitaciones}_page.dart`, `presentation/widgets/organizacion/*`, `core/services/push_notification_service.dart`, `supabase/functions/send-push/*`, `0007_push.sql`.

**Aceptación:** ciclo invitar → notificar → aceptar/rechazar → notificar → re-invitar; una sola organización por usuario; borrado bloqueado si hay tiendas.

### Tarea D — Experiencia, QA y entrega

**Fases:** 8.2–8.6, 9. **Favoritos (8.1) pasa a B.**
**Puede empezar:** día 1 (historial, compartir y mapa no dependen de nadie).

**Documentación de contexto:**
- `doc/1_PROJECT/PLAN_IMPLEMENTACION_FASES.md`: §4 → Fase 8, §4 → Fase 9, §7 (matriz de pruebas), §8 (riesgos).
- `doc/1_PROJECT/ANALISIS_DE_REQUERIMIENTOS.md`: RF-08, RF-09.2, RF-09.3, RF-10.

**Indicaciones:**
1. Historial local y limpieza de caché (RF-08.1).
2. Compartir robusto, sin dejar la app cargando (RF-08.2).
3. Mapa embebido con fallback al navegador (RF-08.3).
4. Ajustes: tema persistente y limpiar caché (RF-09.2).
5. Soporte, términos y privacidad (RF-09.3).
6. Escribir la matriz de pruebas desde la semana 1 y ejecutar regresión continua.
7. Fase 9: APK release, documentación y guion de demo.

**Archivos propios:** `presentation/pages/historial/*`, `core/utils/share_service.dart`, `core/utils/app_utils.dart`, `presentation/pages/settings/*`, `presentation/pages/soporte/*`, `test/*`, documentos de cierre.

**Aceptación:** RF-08 y RF-09.2/09.3 validados, APK instalable y documentación sin referencias a Contabo.

### Cronograma paralelo (3 semanas)

| Semana | A | B | C | D |
|---|---|---|---|---|
| 1 | Fase 1 | Fase 3 (handlers + UI) + Favoritos | Fase 4 + inicio Fase 5 | Historial + Compartir + Mapa + matriz |
| 2 | Cierre Fase 1 + Fase 2 | Cierre Fase 3 + Fase 6 | Fase 5 (invitaciones) | Ajustes + Soporte + regresión |
| 3 | Cierre Fase 2 + apoyo | Cierre Fase 6 + apoyo QA | Cierre Fase 5 (+ Fase 7 stretch) | Fase 9 (APK, docs, demo) |

**Carga estimada:** A 11–13 días · B 10–13.5 · C 11–12 · D 9.5–12.5.

### Reparto por archivos (para no pisarse)

| Área | Dueño | Archivos clave |
|---|---|---|
| Router, DI y constantes | A (merge) | `app_router.dart`, `service_locator.dart`, `app_constants.dart` |
| Identidad y admin | A | `auth_*`, `usuario.dart`, `presentation/pages/admin/*`, `plazoleta_repository*`, `categoria_repository*`, `usuario_repository*` |
| Comercio y favoritos | B | `tienda_*`, `producto_*`, `valoracion*`, `favorito*`, `presentation/pages/vendedor/mis_*`, `producto_detail_page.dart` |
| Organización y notificaciones | C | `organizacion*`, `notificacion*`, `presentation/pages/vendedor/{mi_organizacion,invitaciones}_page.dart`, `presentation/widgets/organizacion/*` |
| Experiencia y QA | D | `historial*`, `share_service.dart`, `app_utils.dart`, `presentation/pages/settings/*`, `presentation/pages/soporte/*`, `test/*` |

Si necesitas un cambio en un archivo ajeno, pídelo al dueño; no lo edites directamente.

### Reglas de código que aplican a las 4 tareas

- Ninguna página llama a Supabase directamente: pasa por repositorio.
- Toda feature nueva sigue el orden entidad → interfaz → data source → repositorio → DI → BLoC → página → ruta.
- Usar `Result`/`Failure` y `Equatable`; no introducir `dartz`.
- No reintroducir Contabo, Wompi ni modo invitado.
- `flutter analyze` sin errores antes de cada PR.

## 📋 DOCUMENTACIÓN

El plan vigente es [`doc/1_PROJECT/PLAN_IMPLEMENTACION_FASES.md`](doc/1_PROJECT/PLAN_IMPLEMENTACION_FASES.md): fases 0–9, subfases, archivos exactos y reparto en 4 tareas.

| Documento | Contenido |
|---|---|
| [`doc/1_PROJECT/PLAN_IMPLEMENTACION_FASES.md`](doc/1_PROJECT/PLAN_IMPLEMENTACION_FASES.md) | Plan normativo: fases, reglas de negocio y reparto |
| [`doc/1_PROJECT/ANALISIS_DE_REQUERIMIENTOS.md`](doc/1_PROJECT/ANALISIS_DE_REQUERIMIENTOS.md) | RF-01…RF-10 y trazabilidad |
| [`doc/3_DATABASE/ESQUEMA_BASE_DATOS.md`](doc/3_DATABASE/ESQUEMA_BASE_DATOS.md) | Esquema real de la base de datos |
| [`doc/2_ARCHITECTURE/ESTRUCTURA_PROYECTO.md`](doc/2_ARCHITECTURE/ESTRUCTURA_PROYECTO.md) | Capas, DI y routing (solo lectura) |
| [`doc/AGENTS.md`](doc/AGENTS.md) | Comandos, estilo y convenciones para agentes |

## 🎯 ESTADO ACTUAL

- **Fase 0.5 — Contratos:** completada. Modo invitado eliminado, `hasRole()` real, rutas con stubs y migración `0006` creada.
- **Fase 1 — Roles y navegación:** base implementada. Falta validar en dispositivo y aplicar `0006` en Supabase.
- **Siguiente:** Fase 2 (panel admin) con A; B, C y D avanzan en paralelo según el cronograma.
- **Sin modo invitado:** solo cliente, vendedor y administrador.
- **Fuera de alcance:** Contabo, Wompi, correo/SMS y reescritura del home 3D.

## 🚀 INICIO RÁPIDO

```bash
flutter pub get
cp .env.example .env   # completar credenciales
flutter run
```

Variables mínimas en `.env`:

```env
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...

FIREBASE_API_KEY=...
FIREBASE_PROJECT_ID=...
FIREBASE_MESSAGING_SENDER_ID=...
FIREBASE_APP_ID=...
GOOGLE_SIGN_IN_ANDROID_CLIENT_ID=...
MICROSOFT_CLIENT_ID=...
MICROSOFT_REDIRECT_URI=...
```

R2 es opcional para imágenes:

```env
CLOUDFLARE_ACCOUNT_ID=...
CLOUDFLARE_R2_ACCESS_KEY_ID=...
CLOUDFLARE_R2_SECRET_ACCESS_KEY=...
CLOUDFLARE_R2_BUCKET_NAME=paseo-comercio-mobile
CLOUDFLARE_R2_PUBLIC_URL=https://pub-....r2.dev
```

## 🏗️ ARQUITECTURA

- Clean Architecture en 4 capas (`core`, `domain`, `data`, `presentation`) + `di`.
- Estado con BLoC; caché local con Hive; navegación con GoRouter; DI con GetIt.
- Autenticación con Firebase Auth (Google y Microsoft).
- Datos con Supabase PostgreSQL; imágenes en Cloudflare R2 con fallback a Supabase Storage.

## 📱 ALCANCE

- Android es el objetivo principal.
- RF-01…RF-10 según [`ANALISIS_DE_REQUERIMIENTOS.md`](doc/1_PROJECT/ANALISIS_DE_REQUERIMIENTOS.md).

---

**Última actualización:** fase 0.5 cerrada, fase 1 base implementada y reparto de 4 tareas rebalanceado.

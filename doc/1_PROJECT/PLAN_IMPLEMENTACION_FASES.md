# Plan de implementación por fases y subfases

**Proyecto:** Paseo del Comercio — App móvil Flutter
**Documento:** Plan técnico de implementación
**Versión:** 1.0
**Fecha:** Octubre 2026
**Alcance:** fases 1 a 9. Pagos Wompi quedan **fuera de alcance**.
**Documentos de referencia (no editar):** `doc/2_ARCHITECTURE/ESTRUCTURA_PROYECTO.md`, `doc/2_ARCHITECTURE/INGENIERIA_Y_ARQUITECTURA_DE_SOFTWARE.md`, `doc/AGENTS.md`.

---

## 0. Cómo usar este documento

Cada subfase indica:

1. **Qué hacer**: la tarea concreta.
2. **Dónde**: archivos o carpetas exactas donde se crea o modifica.
3. **Aceptación**: cómo se comprueba que quedó bien.

Regla de oro: **ninguna subfase se marca como terminada si `flutter analyze` reporta errores** o si no se registró la dependencia en `lib/di/service_locator.dart`.

---

## 1. Reglas del proyecto (obligatorias)

### 1.1 Arquitectura

Clean Architecture con 4 capas y dependencias hacia adentro:

```
presentation  →  domain  ←  data
      ↓             ↑         ↓
      └──────── core ─────────┘
```

| Capa | Responsabilidad | No debe hacer |
|---|---|---|
| `lib/core` | Configuración, utilidades, routing, errores, servicios transversales | Conocer pantallas |
| `lib/domain` | Entidades, interfaces de repositorio, fallas, casos de uso | Importar Flutter, Supabase o `data` |
| `lib/data` | Data sources (Supabase/Hive), implementaciones de repositorio | Importar `presentation` |
| `lib/presentation` | BLoCs, páginas, widgets | Llamar Supabase directamente |

### 1.2 Patrones establecidos

| Patrón | Dónde se aplica |
|---|---|
| **Singleton** | Servicios en `lib/core/utils` y `lib/di/service_locator.dart` |
| **Facade** | `SupabaseClientService` (acceso a tablas), `ImageService` (R2 + Supabase Storage) |
| **Observer** | BLoC (`Stream` de estados), `onAuthStateChanged` |
| **Repository** | Interfaz en `domain/repositories`, implementación en `data/repositories` |
| **Result** | `lib/core/utils/result.dart` (`Success` / `Error`) |
| **Failure** | `lib/domain/failures/failure.dart` |

### 1.3 Convenciones

- Archivos y carpetas: `snake_case`.
- Clases: `PascalCase`. Variables: `camelCase`.
- Entidades con `Equatable`, `fromJson`, `toJson`, `copyWith`, `props`.
- Eventos: `[Feature][Accion]Requested`. Estados: `[Feature][Estado]State`.
- Imports: SDK, paquetes, proyecto, `part` al final.
- No dejar imports sin usar ni código comentado nuevo.
- No agregar comentarios salvo que aporten contexto no obvio.

### 1.4 Dónde va cada cambio (checklist por feature)

Al crear una feature nueva, seguir este orden:

1. `lib/domain/entities/` → entidad (si no existe).
2. `lib/domain/repositories/` → interfaz.
3. `lib/data/datasources/remote/` → data source con Supabase.
4. `lib/data/repositories/` → implementación que usa el data source.
5. `lib/di/service_locator.dart` → registrar data source, repositorio y BLoC.
6. `lib/presentation/blocs/<feature>/` → BLoC, eventos y estados.
7. `lib/presentation/pages/<feature>/` → páginas.
8. `lib/presentation/widgets/<feature>/` → widgets reutilizables.
9. `lib/core/routing/app_router.dart` → ruta y guard.
10. `lib/core/constants/app_constants.dart` → constantes de tabla/ruta si aplica.

### 1.5 Definition of Done

- [ ] `flutter analyze` sin errores.
- [ ] Dependencias registradas en `service_locator.dart`.
- [ ] Ruta agregada y protegida por rol.
- [ ] Estados `loading`, `empty`, `error` implementados.
- [ ] Permisos validados en BLoC **y** repositorio, no solo en la UI.
- [ ] Probado en emulador o dispositivo.
- [ ] Documentación actualizada si cambió una regla o tabla.

---

## 2. Reglas de negocio transversales

Estas reglas aplican a todas las fases y deben validarse en la capa de datos, no solo en la interfaz.

### 2.1 Roles y sesión

| Rol | Acceso |
|---|---|
| Cliente | Catálogo: plazoletas, tiendas, productos, organizaciones, favoritos, perfil |
| Vendedor | Panel de vendedor: sus tiendas, productos, organización e invitaciones |
| Administrador | **Solo** panel `/admin` |
| Invitado | **Eliminado**. No existe acceso sin sesión |

- Toda ruta exige sesión.
- El administrador no accede al catálogo ni al panel de vendedor.
- El vendedor no accede al panel de administración.

### 2.2 Organización

- Un usuario pertenece a **una sola** organización, sea dueño o miembro.
- Un vendedor solo puede ser **dueño de una** organización.
- Solo el **dueño** edita, invita y elimina la organización.
- Al eliminar la organización:
  - Se eliminan sus miembros e imágenes (cascada).
  - El dueño queda libre y puede crear otra.
  - Los antiguos miembros quedan libres y pueden unirse a otra o a la nueva.
  - Si la organización tiene tiendas asociadas, la eliminación se **bloquea** con un mensaje claro.
- El dueño también se registra como miembro `Activo` al crear la organización.

### 2.3 Invitaciones

- La invitación **no envía correos**. El correo es solo la llave de búsqueda.
- Solo se puede invitar a un usuario registrado con rol **vendedor**.
- No se puede invitar a uno mismo.
- Si el usuario ya pertenece a una organización (`Activo`), se muestra:
  **“Este vendedor ya pertenece a una organización.”**
- Si tiene una invitación pendiente en otra organización, se muestra:
  **“Este vendedor ya tiene una invitación pendiente.”**
- Si fue rechazada, se puede volver a invitar.
- Las notificaciones se entregan por el sistema (bandeja in-app) y, opcionalmente, por FCM. No hay email ni SMS.

### 2.4 Notificaciones

- Centro in-app obligatorio.
- Push FCM opcional (fase 7).
- Tipos permitidos por la tabla: `invitacion_organizacion`, `aceptacion_invitacion`, `rechazo_invitacion`, `organizacion_eliminada`, `miembro_expulsado`, `miembro_abandono`, `mensaje_sistema`, `alerta`.
- El remitente también recibe notificación de la respuesta.

### 2.5 Imágenes

- Subida principal a Cloudflare R2.
- Fallback a Supabase Storage.
- Contabo S3 **eliminado**; no reintroducirlo.

---

## 3. Estado de partida

| Elemento | Estado |
|---|---|
| Esquema Supabase (25 tablas, 8 enums, 36 índices) | Completado |
| Seed de demostración | Completado |
| Limpieza Contabo/S3 | Completado |
| `.env` con proyecto nuevo | Completado |
| `flutter analyze` sin errores | Completado |
| Autenticación email/Google/Microsoft | Funcional |
| Roles y redirección por rol | Pendiente |
| Modo invitado | A eliminar |
| CRUD tiendas/productos (eventos) | Definidos, **sin handlers registrados** |
| CRUD plazoletas | **No existe** en repositorio |
| Repositorio de categorías | Interfaz existe, **implementación ausente** |
| Notificaciones | Solo entidad |
| Organización: crear | Implementado pero **roto** (inserta columna `metadata` inexistente) |
| Invitaciones | Eventos definidos, **sin handlers** |
| Valoraciones | Solo crear, inline en la página |
| Favoritos, historial, share, settings | Implementados; requieren validación |

---

## 4. Fases

### Fase 0 — Cierre técnico (completada)

| Subfase | Estado |
|---|---|
| 0.1 Esquema y migraciones | Completado |
| 0.2 Seed | Completado |
| 0.3 Limpieza Contabo | Completado |
| 0.4 `.env` y verificación | Completado |
| 0.5 `flutter analyze` | Completado |

---

### Fase 0.5 — Contratos compartidos (1 día, habilita el paralelismo)

**Estado:** ✅ completada en código (commit `a872933`); 0.5.3 pendiente de ejecutar en Supabase.

**Objetivo:** eliminar los cuellos de botella de archivos compartidos antes de que las 4 personas empiecen.
**Responsable:** A, con revisión de C para la migración.
**Dependencias:** Fase 0.

| Subfase | Qué hacer | Dónde | Aceptación |
|---|---|---|---|
| 0.5.1 | Eliminar el modo invitado y activar `hasRole()` | Ver subfases 1.6 y 1.2 | No queda acceso anónimo |
| 0.5.2 | Dejar todas las rutas con stubs de página, usando los nombres finales de clase | `lib/core/routing/app_router.dart`, `lib/presentation/pages/**` | Cada ruta abre su stub; nadie edita el router después |
| 0.5.3 | Aplicar la migración `0006` | `supabase/migrations/0006_organizacion_invitaciones.sql` | Índices únicos y cascadas activos |
| 0.5.4 | Congelar firmas de interfaces y constantes | `lib/domain/repositories/*`, `lib/core/constants/app_constants.dart` | B, C y D programan contra firmas estables |
| 0.5.5 | Registrar en DI lo que ya existe | `lib/di/service_locator.dart` | La app arranca sin dependencias sin registrar |

---

### Fase 1 — Roles, sesión y navegación (sin invitado)

**Objetivo:** que cada usuario entre a su área y que no exista acceso anónimo.
**Dependencias:** Fase 0.5.
**Esfuerzo:** 5–6 días-dev.

| Subfase | Qué hacer | Dónde | Aceptación |
|---|---|---|---|
| 1.1 | Consultar `usuario.roles_id` y `roles.rol` al iniciar sesión y sincronizar | `lib/data/repositories/auth_repository.dart`, `lib/domain/repositories/auth_repository_interface.dart` | El perfil devuelve el rol (`administrador`, `vendedor`, `cliente`) |
| 1.2 | Implementar `hasRole()` real (hoy retorna `false`) | `lib/data/repositories/auth_repository.dart:205` | `hasRole('vendedor')` responde correctamente |
| 1.3 | Exponer el rol en el estado de autenticación | `lib/presentation/blocs/auth/auth_bloc.dart`, `auth_event.dart`, `auth_state.dart` | La UI puede leer el rol sin consultar la base |
| 1.4 | Redirección por rol al iniciar sesión | `lib/core/routing/app_router.dart` | Cliente → `/plazoletas`; vendedor → `/vendedor`; admin → `/admin` |
| 1.5 | Guard estricto del panel admin | `lib/core/routing/app_router.dart` | Admin no puede abrir rutas fuera de `/admin` |
| 1.6 | Eliminar modo invitado | `lib/core/utils/auth_state.dart`, `auth_service.dart`, `firebase_auth_service.dart`, `lib/core/constants/app_constants.dart:166`, `lib/presentation/widgets/profile/profile_components.dart:106`, `lib/presentation/pages/profile/profile_page.dart:167`, `lib/presentation/blocs/favorito/favorito_bloc.dart:47` | No queda ninguna referencia a `guest`, `isGuest` ni “Continuar como invitado” |
| 1.7 | Eliminar servicio mock sin uso | `lib/core/utils/auth_service_simple.dart` | Archivo eliminado y sin imports |
| 1.8 | Matriz de prueba rol → ruta | Manual | Cada rol solo accede a lo permitido |

**Nota:** el usuario sin sesión siempre termina en `/login`.

---

### Fase 2 — Panel de administración

**Objetivo:** CRUD de plazoletas y categorías; listados simples de usuarios, tiendas y organizaciones.
**Dependencias:** Fase 1.
**Esfuerzo:** 6–7 días-dev.

| Subfase | Qué hacer | Dónde | Aceptación |
|---|---|---|---|
| 2.1 | Shell del panel admin con navegación interna | `lib/presentation/pages/admin/admin_shell_page.dart` | Solo visible para admin |
| 2.2 | Agregar CRUD al repositorio de plazoletas (no existe) | `lib/domain/repositories/plazoleta_repository_interface.dart`, `lib/data/repositories/plazoleta_repository.dart` | `createPlazoleta`, `updatePlazoleta`, `deletePlazoleta` disponibles |
| 2.3 | BLoC de administración | `lib/presentation/blocs/admin/admin_bloc.dart`, `admin_event.dart`, `admin_state.dart` | Eventos por sección y estados de carga/error |
| 2.4 | CRUD plazoletas (lista, formulario, eliminar) | `lib/presentation/pages/admin/admin_plazoletas_page.dart`, `admin_plazoleta_form_page.dart` | Crear, editar y eliminar con confirmación |
| 2.5 | Crear implementación de categorías | `lib/data/repositories/categoria_repository.dart`, registrar en `lib/di/service_locator.dart` | La interfaz existente queda implementada |
| 2.6 | CRUD categorías | `lib/presentation/pages/admin/admin_categorias_page.dart`, `admin_categoria_form_page.dart` | Crear, editar, activar/desactivar, eliminar |
| 2.7 | Listado simple de usuarios (solo lectura) | `lib/presentation/pages/admin/admin_usuarios_page.dart`, nuevo `usuario_repository` | Muestra nombre, correo, rol, estado |
| 2.8 | Listado simple de tiendas (solo lectura) | `lib/presentation/pages/admin/admin_tiendas_page.dart` | Muestra nombre, propietario, organización |
| 2.9 | Listado simple de organizaciones (solo lectura) | `lib/presentation/pages/admin/admin_organizaciones_page.dart` | Muestra nombre, dueño, tipo |
| 2.10 | Rutas del panel | `lib/core/routing/app_router.dart` | `/admin`, `/admin/plazoletas`, `/admin/categorias`, `/admin/usuarios`, `/admin/tiendas`, `/admin/organizaciones` |
| 2.11 | Registro en DI | `lib/di/service_locator.dart` | `AdminBloc`, `CategoriaRepository`, `UsuarioRepository` registrados |
| 2.12 | QA de permisos | Manual | Admin no entra al catálogo; cliente/vendedor no entran a `/admin` |

**Regla:** los listados son tablas/listas simples; no réplicas del home 3D.

---

### Fase 3 — Panel del vendedor: tiendas y productos

**Objetivo:** que el vendedor cree y administre sus tiendas y productos.
**Dependencias:** Fase 1.
**Esfuerzo:** 6–8 días-dev.

| Subfase | Qué hacer | Dónde | Aceptación |
|---|---|---|---|
| 3.1 | Registrar y manejar los eventos CRUD de tienda (hoy existen pero no están en `on<>`) | `lib/presentation/blocs/tienda/tienda_bloc.dart` | `TiendaCreateRequested`, `TiendaUpdateRequested`, `TiendaDeleteRequested` funcionan |
| 3.2 | Implementar “mis tiendas” (evento `TiendaByPropietarioRequested` sin handler) | `lib/presentation/blocs/tienda/tienda_bloc.dart` | Lista solo las tiendas del vendedor |
| 3.3 | Registrar y manejar los eventos CRUD de producto | `lib/presentation/blocs/producto/producto_bloc.dart` | `ProductoCreateRequested`, `ProductoUpdateRequested`, `ProductoDeleteRequested` funcionan |
| 3.4 | Formulario de tienda | `lib/presentation/pages/vendedor/tienda_form_page.dart` | Crear y editar con validación |
| 3.5 | Formulario de producto | `lib/presentation/pages/vendedor/producto_form_page.dart` | Crear y editar con validación |
| 3.6 | Subida de imágenes | `lib/core/utils/image_service.dart:199` | Sube a R2 y guarda URL |
| 3.7 | Eliminar con confirmación | Páginas de “mis tiendas” y “mis productos” | Diálogo, llamada al repositorio, refresco y mensaje |
| 3.8 | Pantallas “Mis tiendas” y “Mis productos” | `lib/presentation/pages/vendedor/mis_tiendas_page.dart`, `mis_productos_page.dart` | Lista con estado vacío y botón crear |
| 3.9 | Guardas de permisos | `lib/data/repositories/tienda_repository.dart`, `producto_repository.dart` y BLoCs | Solo el dueño edita/elimina; error `PermissionFailure` si no |
| 3.10 | Rutas del vendedor | `lib/core/routing/app_router.dart` | `/vendedor`, `/vendedor/tiendas`, `/vendedor/productos`, `/vendedor/tiendas/nueva`, etc. |
| 3.11 | QA CRUD | Manual | Un vendedor no puede tocar tiendas de otro |

**Decisión pendiente:** si una tienda tiene productos, la eliminación se bloquea con mensaje. Para productos, se permite eliminar; si tiene reseñas/favoritos, se eliminan en cascada o se desactivan (usar `estado_producto`).

---

### Fase 4 — Notificaciones in-app

**Objetivo:** bandeja de notificaciones con leídas/no leídas.
**Dependencias:** Fase 1.
**Esfuerzo:** 4 días-dev.

| Subfase | Qué hacer | Dónde | Aceptación |
|---|---|---|---|
| 4.1 | Alinear la entidad con la tabla real | `lib/domain/entities/notificacion.dart` | Mapea `destinatario_id`, `asunto`, `created_at`, `tipo`, `accion_url`, `referencia_id`, `referencia_tipo`, `metadata` |
| 4.2 | Eliminar campos sin soporte en la tabla | `lib/domain/entities/notificacion.dart` | Sin `enviadaEmail`, `enviadaSms` ni programación |
| 4.3 | Interfaz de repositorio | `lib/domain/repositories/notificacion_repository_interface.dart` | Métodos: listar, contar no leídas, marcar leída, marcar todas |
| 4.4 | Data source remoto | `lib/data/datasources/remote/notificacion_remote_datasource.dart` | Usa `SupabaseClientService.notificaciones` |
| 4.5 | Implementación del repositorio | `lib/data/repositories/notificacion_repository_impl.dart` | Envuelve errores en `Failure` |
| 4.6 | BLoC | `lib/presentation/blocs/notificacion/notificacion_bloc.dart`, `notificacion_event.dart`, `notificacion_state.dart` | Estados loading/empty/error |
| 4.7 | Bandeja | `lib/presentation/pages/notificaciones/notificaciones_page.dart`, `lib/presentation/widgets/notificacion/notificacion_tile.dart` | Lista, vacío y error |
| 4.8 | Badge de no leídas | Shell del cliente y del vendedor | Contador visible |
| 4.9 | Deep link interno | `lib/core/routing/app_router.dart` | `accion_url` abre la pantalla correcta |
| 4.10 | Registro en DI y ruta | `lib/di/service_locator.dart`, `lib/core/routing/app_router.dart` | `/notificaciones` protegida |
| 4.11 | QA | Manual | Marcar leída persiste y actualiza el badge |

**No se envía correo ni SMS.** Solo bandeja del sistema.

---

### Fase 5 — Organización e invitaciones

**Objetivo:** una organización por usuario, con invitaciones y respuestas notificadas.
**Dependencias:** Fase 1 y Fase 0.5. La inserción de notificaciones no depende de la UI de la Fase 4.
**Esfuerzo:** 7–8 días-dev.

| Subfase | Qué hacer | Dónde | Aceptación |
|---|---|---|---|
| 5.1 | Migración `0006` (ver sección 5) | `supabase/migrations/0006_organizacion_invitaciones.sql` | Índices y cascadas aplicados; datos existentes limpios |
| 5.2 | Corregir creación de organización (inserta `metadata` inexistente) | `lib/data/repositories/organizacion_repository.dart:871` | Crear organización ya no falla |
| 5.3 | Agregar métodos a la interfaz | `lib/domain/repositories/organizacion_repository_interface.dart` | `getMiOrganizacion`, `inviteVendedor`, `getInvitacionesRecibidas`, `acceptInvitacion`, `rejectInvitacion`, `deleteOrganizacion` |
| 5.4 | Implementar los métodos | `lib/data/repositories/organizacion_repository.dart` | Resuelven `usuario.id` por `firebase_user_id` y validan reglas |
| 5.5 | Registrar y manejar eventos de invitación | `lib/presentation/blocs/organizacion/organizacion_bloc.dart` | `on<InviteToOrganizacion>`, `on<AcceptInvitation>`, `on<RejectInvitation>` |
| 5.6 | Crear organización (una por vendedor) + dueño como miembro activo | `lib/presentation/pages/vendedor/mi_organizacion_page.dart` | Si ya pertenece a una, no muestra “crear” y explica por qué |
| 5.7 | Editar organización (solo dueño) | `lib/presentation/pages/vendedor/mi_organizacion_page.dart` | Solo el dueño ve “editar” |
| 5.8 | Eliminar organización (solo dueño) | `lib/presentation/pages/vendedor/mi_organizacion_page.dart` | Confirmación; bloquea si hay tiendas; cascada de miembros |
| 5.9 | Diálogo de invitación por correo | `lib/presentation/widgets/organizacion/invitar_vendedor_dialog.dart` | Valida existencia, rol vendedor, no a sí mismo, no pertenencia |
| 5.10 | Bandeja de invitaciones recibidas | `lib/presentation/pages/vendedor/invitaciones_page.dart` | Aceptar/rechazar; estado vacío |
| 5.11 | Notificar al invitado | `lib/data/repositories/organizacion_repository.dart` | Inserta `notificacion` tipo `invitacion_organizacion` |
| 5.12 | Notificar al remitente al responder | `lib/data/repositories/organizacion_repository.dart` | Inserta `aceptacion_invitacion` o `rechazo_invitacion` |
| 5.13 | Re-invitación | `lib/data/repositories/organizacion_repository.dart` | Pendiente en la misma org → reenvía; rechazado → vuelve a pendiente |
| 5.14 | Estado de invitaciones enviadas | `lib/presentation/pages/vendedor/mi_organizacion_page.dart` | El dueño ve pendientes/activos/rechazados |
| 5.15 | Rutas | `lib/core/routing/app_router.dart` | `/vendedor/organizacion`, `/vendedor/invitaciones` |
| 5.16 | QA del ciclo completo | Manual | Invitar → notificar → aceptar/rechazar → notificar → re-invitar |

**Mensajes exactos:**

- “Este vendedor ya pertenece a una organización.”
- “Este vendedor ya tiene una invitación pendiente.”
- “No existe un vendedor registrado con ese correo.”
- “No puedes invitarte a ti mismo.”
- “Solo el dueño puede realizar esta acción.”

---

### Fase 6 — Valoraciones

**Objetivo:** que el usuario edite y elimine su reseña, y que el promedio sea real.
**Dependencias:** Fase 1.
**Esfuerzo:** 3–4 días-dev.

| Subfase | Qué hacer | Dónde | Aceptación |
|---|---|---|---|
| 6.1 | Interfaz de repositorio | `lib/domain/repositories/valoracion_repository_interface.dart` | Crear, editar, eliminar, listar por producto, promedio |
| 6.2 | Data source | `lib/data/datasources/remote/valoracion_remote_datasource.dart` | Usa `valoracion_producto` e `imagen_valoracion_producto` |
| 6.3 | Implementación | `lib/data/repositories/valoracion_repository_impl.dart` | 1 reseña por usuario/producto |
| 6.4 | BLoC | `lib/presentation/blocs/valoracion/valoracion_bloc.dart`, `valoracion_event.dart`, `valoracion_state.dart` | Estados y errores |
| 6.5 | Mover la creación inline al repositorio | `lib/presentation/pages/productos/producto_detail_page.dart:518` | La página ya no llama `supabase.valoraciones.insert` |
| 6.6 | Editar y eliminar reseña propia | `lib/presentation/widgets/producto/detail/producto_valoracion_dialog.dart`, `producto_valoraciones_tab.dart` | Solo el autor ve acciones |
| 6.7 | Promedio y conteo | `lib/presentation/widgets/producto/...`, `tienda_card.dart` | Se muestran datos reales |
| 6.8 | Registro en DI | `lib/di/service_locator.dart` | Repositorio y BLoC registrados |
| 6.9 | QA | Manual | No se puede duplicar reseña; editar/eliminar actualiza la lista |

---

### Fase 7 — Push real FCM (condicional)

**Objetivo:** notificaciones del sistema Android para invitaciones y respuestas.
**Dependencias:** Fases 4 y 5.
**Esfuerzo:** 6–8 días-dev.
**Condición:** solo si las fases 1–6 están cerradas.

| Subfase | Qué hacer | Dónde | Aceptación |
|---|---|---|---|
| 7.1 | Migración `0007`: tabla `dispositivo`, `notificacion.enviada_push`, tipos de interacción | `supabase/migrations/0007_push.sql` | Tokens por usuario y dispositivo |
| 7.2 | Dependencias | `pubspec.yaml` | `firebase_messaging`, `flutter_local_notifications` |
| 7.3 | Permiso Android 13+ | `android/app/src/main/AndroidManifest.xml` | `POST_NOTIFICATIONS` declarado |
| 7.4 | Servicio de push en la app | `lib/core/services/push_notification_service.dart` | Registra token, escucha refresh y muestra foreground |
| 7.5 | Guardar token | `lib/data/datasources/remote/notificacion_remote_datasource.dart` | Inserta/actualiza en `dispositivo` |
| 7.6 | Edge Function | `supabase/functions/send-push/index.ts` | Recibe notificación y llama FCM HTTP v1 |
| 7.7 | Secreto de Firebase | Supabase Dashboard → Secrets | Service account configurada |
| 7.8 | Webhook | Supabase Dashboard → Database Webhooks | `INSERT` en `notificacion` dispara la función |
| 7.9 | Tap y deep link | `lib/core/routing/app_router.dart` | Abre `accion_url` |
| 7.10 | QA en dispositivo físico | Manual | Llega con app abierta, en segundo plano y cerrada |

**Sin canales externos.** No se envía correo ni SMS.

---

### Fase 8 — Cierre de RF restantes

**Objetivo:** validar y pulir favoritos, historial, compartir, mapas, ajustes y soporte.
**Dependencias:** Fase 1.
**Esfuerzo:** 5–6 días-dev.

| Subfase | Qué hacer | Dónde | Aceptación |
|---|---|---|---|
| 8.1 | Favoritos: persistencia y reactividad (RF-06) | `lib/presentation/blocs/favorito/*`, `lib/presentation/pages/favoritos/favoritos_page.dart` | Cambia al iniciar/cerrar sesión; estados vacío/error |
| 8.2 | Historial local (RF-08.1) | `lib/presentation/pages/historial/historial_page.dart`, `lib/core/utils/cache_service.dart` | Guarda y limpia visitas |
| 8.3 | Compartir robusto (RF-08.2) | `lib/core/utils/share_service.dart`, `lib/core/utils/app_utils.dart` | Retorna a la app sin quedar cargando |
| 8.4 | Mapa embebido + fallback (RF-08.3) | `lib/core/utils/app_utils.dart:201` | Abre mapa o navegador |
| 8.5 | Ajustes (RF-09.2) | `lib/presentation/pages/settings/settings_page.dart`, `lib/presentation/providers/theme_provider.dart` | Tema persiste; limpiar caché |
| 8.6 | Soporte y legales (RF-09.3) | `lib/presentation/pages/soporte/soporte_page.dart`, `terminos_page.dart`, `privacidad_page.dart` | Enlaces funcionan |
| 8.7 | QA | Manual | Sin regresiones |

---

### Fase 9 — QA y entrega

**Objetivo:** release candidate y documentación.
**Dependencias:** todas.
**Esfuerzo:** 4–5 días-dev.

| Subfase | Qué hacer | Dónde | Aceptación |
|---|---|---|---|
| 9.1 | Pruebas de integración de flujos críticos | `test/` | Login, roles, CRUD, organización, invitaciones, reseñas |
| 9.2 | Actualizar documentación | `doc/1_PROJECT/PROGRESO_Y_PLAN.md`, `FUNCIONALIDADES_PENDIENTES.md`, `doc/AGENTS.md` | Sin referencias a Contabo; BLoCs actualizados |
| 9.3 | APK release | `flutter build apk --release` | Instala y abre |
| 9.4 | Guion de demo | `doc/1_PROJECT/` | Recorrido de 5–8 minutos |

---

## 5. Migraciones SQL

### 5.1 `0006_organizacion_invitaciones.sql` (obligatoria)

Pasos, en este orden:

1. **Limpiar membresías duplicadas** en la base actual. Un usuario no puede quedar en dos organizaciones.
2. **Insertar la membresía del dueño** si no existe:

```sql
INSERT INTO miembros_organizacion
  (organizacion_id, usuario_id, email, nombre, rol_id, estado, fecha_aceptacion)
SELECT o.id, o.anfitrion_id, u.email, u.nombre_completo, 1, 'Activo', now()
FROM organizacion o
JOIN usuario u ON u.id = o.anfitrion_id
WHERE NOT EXISTS (
  SELECT 1 FROM miembros_organizacion m
  WHERE m.usuario_id = o.anfitrion_id
);
```

3. **Una membresía por usuario**:

```sql
ALTER TABLE miembros_organizacion
  DROP CONSTRAINT unique_usuario_organizacion;
CREATE UNIQUE INDEX miembros_organizacion_usuario_unico
  ON miembros_organizacion(usuario_id);
```

4. **Una organización por dueño**:

```sql
CREATE UNIQUE INDEX organizacion_anfitrion_unico
  ON organizacion(anfitrion_id);
```

5. **Búsqueda por correo**:

```sql
CREATE INDEX usuario_email_idx ON usuario(email);
```

6. **Cascadas**:

```sql
ALTER TABLE miembros_organizacion
  DROP CONSTRAINT fk_miembro_organizacion;
ALTER TABLE miembros_organizacion
  ADD CONSTRAINT fk_miembro_organizacion
  FOREIGN KEY (organizacion_id) REFERENCES organizacion(id) ON DELETE CASCADE;

ALTER TABLE imagen_organizacion
  DROP CONSTRAINT imagen_organizacion_organizacion_id_fkey;
ALTER TABLE imagen_organizacion
  ADD CONSTRAINT imagen_organizacion_organizacion_id_fkey
  FOREIGN KEY (organizacion_id) REFERENCES organizacion(id) ON DELETE CASCADE;
```

7. **Actualizar el seed** (`supabase/migrations/0005_seed.sql`) para que ningún usuario quede en dos organizaciones.

**Advertencia:** el seed actual tiene al usuario 3 en las organizaciones 1 y 2. La limpieza del paso 1 debe resolverse **antes** de crear el índice único. Probar la migración en una copia o en un proyecto Supabase de prueba.

### 5.2 `0007_push.sql` (solo fase 7)

- Crear tabla `dispositivo`:

```sql
CREATE TABLE dispositivo (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  usuario_id BIGINT NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL UNIQUE,
  plataforma VARCHAR(20) DEFAULT 'android',
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

- Agregar `notificacion.enviada_push BOOLEAN DEFAULT false`.
- Extender el CHECK de `notificacion.tipo` para interacciones (`nueva_valoracion`, `nuevo_favorito`, `nuevo_miembro`) si se van a usar.

---

## 6. División en 4 personas

### 6.0 Fase 0.5 ya completada (habilita el paralelismo)

La Fase 0.5 se ejecutó en código (commit `a872933`), así que las 4 personas arrancan el día 1 sin esperar:

1. Modo invitado eliminado y `hasRole()` funcionando.
2. `app_router.dart` con todas las rutas y stubs, usando los nombres finales de clase de B, C y D. Nadie vuelve a editar el router.
3. Migración `0006` creada (con revisión de C); **pendiente ejecutarla en Supabase**.
4. Interfaces de repositorio y `service_locator.dart` con los registros base.
5. `app_constants.dart` y firmas de interfaces congeladas.

Los cuellos de botella (`app_router.dart`, `service_locator.dart`, `app_constants.dart`, modo invitado y `0006`) ya están resueltos.

### 6.1 Perfiles

| Persona | Rol | Fases | Carga estimada |
|---|---|---|---|
| **A** | Núcleo, autenticación y administración | 1, 2 | 11–13 días |
| **B** | Comercio: vendedor, tiendas, productos, reseñas | 3, 6 | 9–12 días |
| **C** | Notificaciones, organización e invitaciones, push | 4, 5, 7 | 11–12 días (sin 7); 17–20 con 7 |
| **D** | Calidad, integración, RF restantes y entrega | 8, 9 | 9–11 días |

**Lectura del balance:** las dependencias están bien aisladas (cada persona es dueña de una vertical), pero la carga no es pareja. A y C son la ruta crítica: A queda con poca holgura (11–13 de 15 días) y C es el punto más pesado (Fase 5). La Fase 7 **no cabe** en 3 semanas: es extra, solo si C cierra 4 y 5 antes. D tiene carga adecuada, pero su Fase 9 está al final; debe escribir la matriz de pruebas desde la semana 1 y ejecutar regresión continua, no esperar a la semana 3.

### 6.2 Responsabilidades por persona

**Persona A — Núcleo y administración**

- Implementa roles, `hasRole()`, redirección y eliminación del modo invitado.
- Escribe la migración `0006` (coordinada con C).
- Construye el panel admin: CRUD plazoletas/categorías y listados simples.
- Revisa que ninguna ruta quede sin guard.
- Es el revisor de PRs de arquitectura y DI.

**Persona B — Comercio**

- Registra y maneja los eventos CRUD de tienda y producto.
- Construye formularios, subida de imágenes y “mis tiendas/productos”.
- Implementa guardas de permisos por dueño.
- Implementa el repositorio/BLoC de valoraciones y la edición/eliminación de reseñas.

**Persona C — Notificaciones y organización**

- Alinea la entidad de notificaciones y construye repositorio, BLoC y bandeja.
- Implementa organización: crear (una por vendedor), editar, eliminar.
- Implementa invitaciones: búsqueda por correo, validaciones, aceptar/rechazar, re-invitación.
- Inserta notificaciones en cada transición.
- Si hay tiempo, monta FCM (fase 7).

**Persona D — Calidad e integración**

- Valida favoritos, historial, compartir, mapas, ajustes y soporte.
- Escribe el plan de pruebas y la matriz rol → ruta → acción.
- Ejecuta pruebas de integración y regresión.
- Prepara APK, documentación y guion de demo.
- Apoya a A en los listados simples del panel admin.

### 6.3 Cronograma paralelo (3 semanas)

Las 4 tareas avanzan al mismo tiempo. No hay “turnos”: cada persona es dueña de su track.

| Semana | A (núcleo/admin) | B (comercio) | C (notificaciones/organización) | D (experiencia/QA) |
|---|---|---|---|---|
| 1 | Fase 1 | Fase 3 (handlers + UI) | Fase 4 + inicio Fase 5 (organización) | Fase 8 (favoritos/historial/share) + matriz de pruebas |
| 2 | Cierre Fase 1 + Fase 2 | Cierre Fase 3 + Fase 6 | Fase 5 (invitaciones) | Cierre Fase 8 + regresión |
| 3 | Cierre Fase 2 + apoyo a Fase 5 | Cierre Fase 6 + apoyo QA | Cierre Fase 5 (+ Fase 7 si hay tiempo) | Fase 9 (APK, docs, demo) |

**Hitos**

- **Fin de semana 1:** roles, router, sin invitado, migración `0006`, notificaciones in-app y CRUD de tiendas/productos.
- **Fin de semana 2:** panel admin, organización con invitaciones, valoraciones editables, favoritos/historial validados.
- **Fin de semana 3:** release candidate, APK y documentación.

### 6.4 Reglas de coordinación

- La migración `0006` la escribe **A**, pero **C** define las reglas de invitación. Se revisa entre ambos antes de aplicarla.
- **A es el único mergeador** de `app_router.dart`, `service_locator.dart` y `app_constants.dart`. Los demás no editan esas firmas: usan los stubs creados en la Fase 0.5 y agregan solo su bloque de registro al final.
- Cada persona es dueña de sus archivos de feature y no toca los de otra.
- Cada PR debe pasar `flutter analyze` y ser revisado por otra persona.
- Si alguien termina antes, toma la Fase 7 (push) o apoya QA; no reabre fases ajenas.

---

## 7. Matriz de pruebas

### 7.1 Roles

| Caso | Esperado |
|---|---|
| Sin sesión abre cualquier ruta | Redirige a `/login` |
| Cliente inicia sesión | `/plazoletas` |
| Vendedor inicia sesión | `/vendedor` |
| Admin inicia sesión | `/admin` |
| Admin intenta `/plazoletas` | Redirige a `/admin` |
| Cliente intenta `/admin` | Redirige a `/plazoletas` |
| Vendedor intenta `/admin` | Redirige a `/vendedor` |
| Cualquiera intenta “continuar como invitado” | No existe la opción |

### 7.2 Organización e invitaciones

| Caso | Esperado |
|---|---|
| Vendedor sin organización crea una | Se crea y queda como miembro `Activo` |
| Vendedor que ya pertenece intenta crear | Error: “Ya perteneces a una organización” |
| Dueño edita su organización | Permitido |
| Miembro intenta editar | Error: “Solo el dueño puede realizar esta acción” |
| Dueño elimina su organización sin tiendas | Se elimina; miembros liberados |
| Dueño elimina su organización con tiendas | Bloqueado con mensaje |
| Invitar correo inexistente | “No existe un vendedor registrado con ese correo” |
| Invitar cliente | “El usuario no tiene rol de vendedor” |
| Invitar a sí mismo | “No puedes invitarte a ti mismo” |
| Invitar a alguien de otra organización | “Este vendedor ya pertenece a una organización” |
| Invitar a alguien con invitación pendiente | “Este vendedor ya tiene una invitación pendiente” |
| Invitado acepta | Estado `Activo`; dueño recibe notificación |
| Invitado rechaza | Estado `Rechazado`; dueño recibe notificación |
| Dueño re-invita a rechazado | Vuelve a `Pendiente` y se notifica |
| Después de eliminar la organización, el dueño crea otra | Permitido |
| Después de eliminar, un antiguo miembro es invitado a otra | Permitido |

### 7.3 Notificaciones

| Caso | Esperado |
|---|---|
| Se crea una invitación | Llega a la bandeja del invitado |
| Invitado acepta/rechaza | Llega a la bandeja del dueño |
| Marcar leída | Persiste y baja el badge |
| Marcar todas | Badge en cero |
| `accion_url` inválida | No rompe; muestra la bandeja |

---

## 8. Riesgos y mitigaciones

| Riesgo | Impacto | Mitigación |
|---|---|---|
| La migración `0006` falla por datos duplicados | Alto | Limpiar antes de crear el índice; probar en copia |
| `createOrganizacion` inserta `metadata` inexistente | Alto | Corregir en 5.2 antes de probar |
| Eventos CRUD definidos pero sin `on<>` | Alto | Registrar handlers en 3.1 y 3.3 |
| Falta de dispositivo físico para FCM | Medio | Fase 7 es condicional; la bandeja in-app no depende de FCM |
| Conflictos en archivos compartidos | Medio | Un solo dueño por archivo; PRs pequeños |
| Tiempo insuficiente | Alto | Fase 7 es lo primero que se recorta; Wompi ya está fuera |
| Documentación desactualizada (Contabo en `AGENTS.md`) | Bajo | Actualizar en 9.2 |

---

## 9. Fuera de alcance

- Pagos con Wompi.
- Notificaciones por correo o SMS.
- Modo invitado.
- Web o iOS (el foco es Android).
- Reescritura del home 3D.

---

**Última actualización:** Octubre 2026

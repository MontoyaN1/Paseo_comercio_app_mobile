# Documento de Análisis de Requerimientos
## Paseo del Comercio — Aplicación Móvil (Flutter)
### Centro Comercial Virtual de Santander para compra a nivel nacional

**Asignatura:** Ingeniería de Software — Primer Semestre, Ingeniería de Sistemas
**Proyecto:** `paseo-del-comercio-app-mobile-flutter`
**Versión del documento:** 1.0 — 25/09/2026
**Estado del proyecto analizado:** MVP funcional / Fase 1 ~92% (según `doc/`)

---

## 1. Introducción

### 1.1 Propósito
Este documento define los objetivos, el alcance, los requerimientos funcionales y no funcionales, y la justificación del stack de software seleccionado para la aplicación móvil **Paseo del Comercio**.

### 1.2 Esencia del negocio
> **Permitir que comerciantes de Santander oferten sus productos para compra a nivel nacional.**

La app es la vitrina móvil del centro comercial virtual: el comerciante santandereano publica tienda y productos (con imágenes, horarios, contacto, ubicación/plazoleta y organización), y el comprador de cualquier parte de Colombia los descubre, consulta, guarda en favoritos, valora y contacta — con evolución futura hacia compra en línea con pasarela de pagos.

### 1.3 Fuentes analizadas
- `README.md` (objetivos, arquitectura, estado)
- `pubspec.yaml` (dependencias reales)
- `lib/domain/` (19 entidades: tienda, producto, plazoleta, organización, usuario, valoración, etc.)
- `lib/presentation/pages/` (auth, tiendas, productos, plazoletas, organizaciones, favoritos, historial, profile, settings, soporte, splash)
- `lib/presentation/blocs/` (auth, tienda, producto, plazoleta, organización, favorito, image)
- `doc/1_PROJECT/` (MOVIL_PLAN, PROGRESO_Y_PLAN, FUNCIONALIDADES_PENDIENTES)
- `doc/3_DATABASE/ESQUEMA_BASE_DATOS.md` (22 tablas, 40+ relaciones, 8 enums)
- `.env.example` (Supabase, Firebase, R2/S3)

---

## 2. Objetivos

### 2.1 Objetivo general
Desarrollar una aplicación móvil multiplataforma (Android, iOS, Web) que funcione como **centro comercial virtual**, permitiendo a los comerciantes de Santander (inicialmente Área Metropolitana de Bucaramanga) ofertar sus productos y a compradores de todo el país descubrirlos, consultarlos y gestionarlos para su compra.

### 2.2 Objetivos específicos
1. **Autenticación y cuentas:** permitir registro, login (email, Google, Microsoft) y sesión persistente, con modo invitado para exploración.
2. **Vitrina por plazoletas:** listar todas las plazoletas y ver el detalle de cada una con sus tiendas e imágenes.
3. **Vitrina por tiendas:** listar tiendas, ver su detalle (horarios, contacto, redes, ubicación, imágenes, etiquetas).
4. **Vitrina por productos:** listar productos, ver su detalle (precio, imágenes, etiquetas, características, valoraciones).
5. **Organizaciones:** listar organizaciones que agrupan tiendas y ver su detalle con miembros.
6. **Fidelización:** favoritos por usuario, historial de visitas, valoraciones de productos, compartir contenido y notificaciones.
7. **Experiencia móvil de calidad:** funcionamiento offline-first con caché, carga rápida de imágenes (multi-CDN), navegación fluida con deep links y soporte/ajustes accesibles.
8. **Base para comercio nacional:** dejar el modelo de datos y la arquitectura listos para el módulo futuro de carrito, pedidos y pasarela de pagos a nivel nacional.

---

## 3. Alcance

### 3.1 Alcance incluido (MVP actual)
- Exploración: plazoletas → tiendas → productos; organizaciones.
- Cuentas: registro/login/logout, perfil, persistencia de sesión.
- Favoritos, historial local, valoraciones/ratings, compartir (share_plus), mapas embebidos (WebView), settings, soporte/acerca de.
- Caché offline-first, imágenes resilientes multi-CDN, deep links.
- Sincronización con app web mediante la misma base de datos.

### 3.2 Fuera de alcance (fase actual, previsto a futuro)
- Carrito de compras, checkout y pasarela de pagos (PSE, tarjeta, contraentrega).
- Panel del comerciante (crear/editar tienda y productos) — corresponde a la "otra app (emprendedores)".
- Logística/envíos nacionales, facturación electrónica, devoluciones.
- Chat en tiempo real comprador–vendedor, cupones, programa de puntos.

> Nota: el modelo (`tienda`, `producto`, `usuario`, `valoracion_producto`, `estadisticas_diarias`, `notificacion`, `interaccion`) ya deja trazabilidad para esos módulos sin rediseñar la BD.

### 3.3 Usuarios y stakeholders
| Actor | Descripción | Interés principal |
|---|---|---|
| Comprador nacional | Persona en cualquier ciudad de Colombia | Descubrir y comprar productos santandereanos |
| Comerciante de Santander | Dueño de tienda / organización | Ofertar productos a nivel nacional |
| Organización / agremiación | Agrupa varias tiendas | Visibilidad colectiva |
| Administrador plataforma | Opera el centro comercial virtual | Catálogo, calidad, estadísticas |
| Equipo desarrollo (U.) | 1–2 Flutter + 1 backend/DevOps + QA | Entregar MVP mantenible |

---

## 4. Requerimientos Funcionales (RF)

> Cada RF se traza a entidades, BLoCs y pantallas realmente existentes en el repo.

### RF-01 — Gestión de cuentas y autenticación
- **RF-01.1** Registro con correo/contraseña e inicio de sesión.
- **RF-01.2** Login social con Google y Microsoft (Firebase Auth).
- **RF-01.3** Persistencia de sesión y cierre de sesión completo (incluye `GoogleSignIn.signOut/disconnect`).
- **RF-01.4** Modo invitado (explorar sin cuenta).
- **RF-01.5** Perfil de usuario (ver/editar datos, avatar).
- *Traza:* `usuario` + `roles`, `AuthBloc`, `lib/presentation/pages/auth/`, `profile/`, `firebase_auth_service.dart`.

### RF-02 — Plazoletas
- **RF-02.1** Listar todas las plazoletas con imagen.
- **RF-02.2** Ver detalle de plazoleta: descripción, ubicación/mapa, imágenes, tiendas asociadas.
- *Traza:* `plazoleta` + `imagen_plazoleta`, `PlazoletaBloc`, `pages/plazoletas/`.

### RF-03 — Tiendas
- **RF-03.1** Listar tiendas (con búsqueda/filtro por etiqueta y plazoleta).
- **RF-03.2** Ver detalle de tienda: imágenes, horarios (`horario` + `tipo_horario`), contactos, redes sociales, etiquetas (`etiqueta_tienda`), ubicación.
- **RF-03.3** Marcar tienda como favorita y compartirla.
- *Traza:* `tienda`, `imagen_tienda`, `horario`, `TiendaBloc`, `pages/tiendas/`, `TiendaCard`.

### RF-04 — Productos
- **RF-04.1** Listar productos por tienda / global.
- **RF-04.2** Ver detalle de producto: precio, descripción, imágenes, características (`caracteristica`, `categoria`), etiquetas, estado (`estado_producto`), valoraciones.
- **RF-04.3** Marcar producto como favorito y compartirlo.
- *Traza:* `producto`, `imagen_productos`, `etiqueta_producto`, `valoracion_producto`, `ProductoBloc`, `pages/productos/`, `ProductoCard`.

### RF-05 — Organizaciones
- **RF-05.1** Listar organizaciones con imagen y tipo (`tipo_organizacion`).
- **RF-05.2** Ver detalle: tiendas agrupadas, miembros (`miembros_organizacion`), imágenes.
- *Traza:* `organizacion`, `imagen_organizacion`, `OrganizacionBloc`, `pages/organizaciones/`.

### RF-06 — Favoritos
- **RF-06.1** Guardar/eliminar favoritos de tiendas y productos por usuario (persistidos en Supabase).
- **RF-06.2** Listar "Mis favoritos", con actualización reactiva al cambiar la sesión.
- *Traza:* tablas de favoritos, `FavoritoBloc` (escucha `onAuthStateChanged`, retry 500 ms, evento `ClearFavoritos`), `pages/favoritos/`.

### RF-07 — Valoraciones e interacciones
- **RF-07.1** Valorar/calificar un producto (estado `estado_valoracion`).
- **RF-07.2** Registrar interacciones (vistas, clics) y agregar `estadisticas_diarias` para el comerciante.
- *Traza:* `valoracion_producto`, `interaccion`, `estadisticas_diarias`.

### RF-08 — Historial, compartir y descubrimiento
- **RF-08.1** Historial local de visitas (Hive) y página de historial.
- **RF-08.2** Compartir tienda/producto/plazoleta/organización (retorno a la app sin quedarse en "cargando" — `WidgetsBindingObserver` + `resumed`).
- **RF-08.3** Mapa/ubicación embebida (WebView + Google Maps Embed; migración futura a SDK nativo).
- *Traza:* `pages/historial/`, `ShareService`, detail pages con observer.

### RF-09 — Notificaciones, ajustes y soporte
- **RF-09.1** Notificaciones (tabla `notificacion`; push vía Firebase Messaging).
- **RF-09.2** Ajustes: tema (claro/oscuro dorado), idioma base ES, caché, cerrar sesión.
- **RF-09.3** Soporte/Acerca de: WhatsApp, Instagram/TikTok/YouTube, términos legales (`assets/legal/`).
- *Traza:* `pages/settings/`, `pages/soporte/`, `.env` (URLs de soporte y redes).

### RF-10 — Sincronización con la app web
- **RF-10.1** Misma base de datos Supabase → catálogo consistente web/móvil.
- **RF-10.2** Imágenes compartidas vía estrategia multi-CDN.
- *Traza:* triggers/constraints en BD, `ImageService` multi-CDN.

**Matriz de trazabilidad resumida:**
| RF | Entidades/Tablas | BLoC | Páginas |
|---|---|---|---|
| RF-01 | usuario, roles | AuthBloc | auth/, profile/ |
| RF-02 | plazoleta, imagen_plazoleta | PlazoletaBloc | plazoletas/ |
| RF-03 | tienda, imagen_tienda, horario, etiqueta_tienda | TiendaBloc | tiendas/ |
| RF-04 | producto, imagen_productos, etiqueta_producto, caracteristica, categoria | ProductoBloc | productos/ |
| RF-05 | organizacion, miembros_organizacion, imagen_organizacion | OrganizacionBloc | organizaciones/ |
| RF-06 | favoritos | FavoritoBloc | favoritos/ |
| RF-07 | valoracion_producto, interaccion, estadisticas_diarias | — (servicios) | detalle producto |
| RF-08 | caché Hive | — | historial/, share |
| RF-09 | notificacion | — | settings/, soporte/ |

---

## 5. Requerimientos No Funcionales (RNF)

| ID | Categoría | Requerimiento | Meta / verificación |
|---|---|---|---|
| RNF-01 | Portabilidad | Una sola base de código para Android, iOS y Web | `flutter build` en 3 targets |
| RNF-02 | Desempeño | Arranque en frío rápido; imágenes con fallback | < 2 s cold start; < 500 ms imagen (objetivos README) |
| RNF-03 | Disponibilidad offline | Caché offline-first + sincronización | Hive + `connectivity_plus`; TTL 1 h, 100 MB |
| RNF-04 | Escalabilidad | Backend serverless que escale con el catálogo nacional | Supabase Postgres + RLS; índices/triggers documentados |
| RNF-05 | Seguridad | Auth delegada, secretos fuera del código, RLS, storage seguro | Firebase Auth + Supabase RLS + `flutter_secure_storage` + `.env` |
| RNF-06 | Usabilidad | Navegación declarativa, deep links, tema oscuro dorado, ES-CO | GoRouter 15+ rutas; `flutter_localizations` + `intl` |
| RNF-07 | Mantenibilidad | Clean Architecture 4 capas + DI + estado predecible | `core/domain/data/presentation/di`, GetIt, BLoC, `flutter_lints` |
| RNF-08 | Confiabilidad | Cero caídas en flujos principales; imágenes siempre resuelven algo | RNF objetivo "0 crashes"; `ResilientImage` con 4 niveles de fallback |
| RNF-09 | Observabilidad | Logs de errores y de triggers para depuración | `logger`, `trigger_logs`, analítica opcional |
| RNF-10 | Legal/privacidad | Términos y tratamiento de datos incluidos en la app | `assets/legal/` + página Soporte |

---

## 6. Justificación del software seleccionado

Criterios de selección: (a) esencia del negocio (vitrina nacional con catálogo e imágenes), (b) equipo universitario pequeño, (c) un solo código multiplataforma, (d) costo inicial ~cero, (e) sincronización con app web, (f) camino claro hacia pagos/envíos.

### 6.1 Tabla de decisión por componente

| Componente | Selección en el proyecto | Alternativas descartadas | Justificación |
|---|---|---|---|
| Framework móvil | **Flutter 3.7+ (Dart)** | React Native; nativo Kotlin+Swift; PWA | Un código → Android/iOS/Web; rendimiento nativo compilado; ideal para catálogo con imágenes y animaciones; equipo ya lo usa. Costo: mantener 1 base vs 2 nativas. |
| Lenguaje de UI/estado | **BLoC (`flutter_bloc`) + `equatable` + `dartz`** | Provider solo; Riverpod; GetX | Estado predecible por eventos/estados, testeable — crítico para auth, favoritos y catálogo. `dartz` modela errores (Either) en capa dominio (Clean). |
| Navegación | **GoRouter** | Navigator 1.0 imperativo | Rutas declarativas + deep linking (compartir un producto por link) → clave para "compra a nivel nacional" por difusión. 15+ rutas ya configuradas. |
| Backend / BD | **Supabase (Postgres + Auth + Storage + Realtime)** | Firebase Firestore; backend propio (Django/Node); Airtable | Postgres relacional modela bien `tienda–producto–plazoleta–organizacion` (22 tablas, 40+ relaciones, 8 enums, triggers); misma BD que la app web = consistencia; Realtime para notificaciones/estadísticas; costo inicial nulo y RLS. |
| Autenticación | **Firebase Auth (+ Google y Microsoft) / Clerk como SSO en plan** | Solo Supabase Auth; Auth0 (pago); login propio | Login social reduce fricción de registro nacional; Firebase ya integra Google/Microsoft y está en `pubspec` + `firebase_options.dart`; Clerk se contempla como SSO unificado con la web. |
| Imágenes | **Cloudflare R2 (principal) → Contabo S3 → Supabase Storage → asset local** | Solo Supabase Storage; solo S3 | El catálogo nacional = miles de fotos. R2 abarata ancho de banda; la cadena multi-CDN (`ImageService` + `ResilientImage` + `cached_network_image`) garantiza que una foto nunca rompa la vitrina. |
| Caché offline | **Hive + `connectivity_plus` + `flutter_secure_storage`** | SQLite puro; SharedPreferences solo | Hive es local NoSQL rápido sin SQL boilerplate → historial y catálogo offline-first; tokens en storage seguro. Necesario porque compradores fuera de Bucaramanga pueden tener conectividad intermitente. |
| Red | **Dio + http + `path` + `crypto`** | Solo http | Dio aporta interceptores, reintentos y timeouts para Supabase/R2; `crypto` para firmas S3. |
| DI | **GetIt** | GetX / manual | Service locator simple que sostiene las 4 capas Clean sin acoplar UI a datos. |
| Formularios/media | **image_picker + image, `country_code_picker`, `share_plus`, `url_launcher`** | Plugins nativos propios | Subir fotos de productos, códigos de país (+57), compartir por WhatsApp/redes y abrir mapas/contactos sin código nativo. |
| Calidad | **flutter_lints, build_runner + hive_generator, flutter_test** | Sin lints/tests | Base testeable exigida por RNF-07; plan contempla 70% coverage. |
| Configuración | **flutter_dotenv (.env)** | Hardcodear claves | Separa secretos por ambiente (Supabase, Firebase, R2, S3, URLs de soporte). |

### 6.2 Por qué este stack sirve a la esencia
1. **Ofertar desde Santander:** el modelo relacional (tienda, producto, horarios, imágenes, etiquetas) + Storage multi-CDN permite a un comerciante publicar una vez y que se vea igual en web y móvil.
2. **Comprar a nivel nacional:** Flutter Web + Android + iOS con un solo equipo; deep links para compartir productos por WhatsApp/redes; offline-first para zonas con mala red; base lista para sumar pasarela de pagos sin cambiar el catálogo.
3. **Costo y velocidad académica:** Supabase + Firebase + R2 tienen capa gratuita; Clean Architecture + BLoC permiten que 1–2 devs Flutter avancen por fases (ver `PROGRESO_Y_PLAN.md`, plan 12 semanas).

### 6.3 Riesgos y mitigación
| Riesgo | Mitigación en el diseño actual |
|---|---|
| Costo de imágenes al escalar | R2 como primario + caché agresiva (`cached_network_image`, TTL, 100 MB) |
| Sesiones sociales inconsistentes | `signOut` + `disconnect` de Google; manejo de errores MSAL documentado |
| Divergencia web/móvil | Misma BD Supabase + triggers/constraints; auth unificada |
| Deuda de testing | Plan de tests unitarios/widget (AuthBloc, FavoritoBloc, TiendaBloc) y testing en dispositivo listado en `FUNCIONALIDADES_PENDIENTES.md` |

---

## 7. Restricciones y supuestos
- **R-1** La compra transaccional (pago/envío) es fase 2; el MVP es vitrina + contacto + favoritos.
- **R-2** Se requiere conectividad inicial para sincronizar; luego opera con caché.
- **R-3** Los secretos (Supabase, Firebase, R2/S3) se inyectan por `.env`, nunca en el repo.
- **S-1** Se supone catálogo inicial del AMB (Bucaramanga) con expansión nacional.
- **S-2** Idioma inicial español (Colombia); moneda COP en fase de pagos.

---

## 8. Conclusión
El análisis muestra que los objetivos (cuentas, plazoletas, tiendas, productos, organizaciones, fidelización) están cubiertos por RF-01…RF-10 y son trazables a las 22 tablas, 19 entidades, 7 BLoCs y páginas existentes. El stack **Flutter + Supabase + Firebase Auth + Hive + BLoC + R2/S3 multi-CDN** es el adecuado porque maximiza alcance nacional con mínimo costo y equipo, mantiene consistencia con la app web y deja abierta la evolución hacia pagos y envíos, que es donde la esencia —comerciantes de Santander vendiendo a todo el país— se completa.

---

## 9. Glosario
Plazoleta (zona del centro comercial), Tienda (comercio), Organización (agrupación de tiendas), Multi-CDN (cadena de respaldo de imágenes), Offline-first (la app prioriza caché local), RLS (seguridad a nivel de fila en Postgres), Deep link (enlace que abre una pantalla concreta de la app).

*Fin del documento.*

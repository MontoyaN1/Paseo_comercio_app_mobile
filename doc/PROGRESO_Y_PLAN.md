# PROGRESO Y PLAN - App Móvil Paseo del Comercio

**Fecha:** Marzo 2026  
**Estado:** 🚧 EN DESARROLLO - Preparación para testing profesional  
**Próximo Hito:** Testing MVP Android

---

## 📊 ESTADO ACTUAL DEL PROYECTO

**Fecha:** Marzo 2026  
**Estado:** ✅ **FUNDACIÓN COMPLETA** - En fase de features y polish  
**Objetivo:** App funcional para testing profesional (Android inicialmente)

---

## ✅ COMPLETADO

### 🏗️ ESTRUCTURA CLEAN ARCHITECTURE (100%)
- **Capa Domain:** Entidades completas con interfaces de repositorio
- **Capa Data:** Repositorios implementados con cache-first strategy
- **Capa Presentation:** BLoCs completos con estados y eventos
- **Capa Infrastructure:** Servicios core configurados y funcionando

### 🔧 SERVICIOS CORE IMPLEMENTADOS
1. ✅ **CacheService** - Caché local con Hive (TTL, estadísticas)
2. ✅ **ConnectivityService** - Monitoreo de estado de red
3. ✅ **ImageService** - Multi-CDN (Cloudflare R2 → S3 → Supabase Storage)
4. ✅ **AuthService** - Autenticación Firebase Auth + Google Sign In
5. ✅ **AppConfig** - Gestión centralizada de variables de entorno

### 📱 PANTALLAS PRINCIPALES (100%)
- ✅ **SplashPage** - Pantalla de carga inicial
- ✅ **LoginPage** - Autenticación con Firebase + Google Sign In
- ✅ **ProfilePage** - Perfil de usuario completo
- ✅ **TiendaDetailPage** - Detalle de tienda con productos, galería, horarios
- ✅ **ProductoDetailPage** - Detalle de producto con imágenes, precio, valoraciones
- ✅ **PlazoletaListPage** - Vista isométrica 3D interactiva
- ✅ **PlazoletaDetailPage** - Detalle de plazoleta con tabs Info/Productos/Tiendas
- ✅ **OrganizacionListPage** - Lista de organizaciones
- ✅ **OrganizacionDetailPage** - Detalle de organización con miembros y tiendas

### ❤️ SISTEMA DE FAVORITOS (100%)
- ✅ **FavoritoBloc** - BLoC para gestionar favoritos
- ✅ **FavoritosPage** - Página con tabs Tiendas/Productos y contadores
- ✅ **Toggle favorito** - Botón con animaciones en TiendaCard y ProductoCard
- ✅ **UI con feedback instantáneo** - Estado local para respuesta inmediata
- ✅ **Persistencia en Supabase** - Tablas `tienda_favorito` y `producto_favorito`
- ✅ **Integración con BLoC** - BlocBuilder en cards para estado reactivo
- ✅ **Optimización de carga** - Future.wait() para carga paralela

### 🎨 WIDGETS REUTILIZABLES
- ✅ **TiendaCard** - Tarjeta profesional con botón favorito animado
- ✅ **ProductoCard** - Tarjeta profesional con botón favorito animado
- ✅ **ProfileFloatingButton** - FAB con logout funcional y glassmorphism
- ✅ **CustomAppBar** - AppBar con menú de perfil
- ✅ **GlassContainer** - Widgets con glassmorphism

### 🎮 BLOCS IMPLEMENTADOS
- ✅ **AuthBloc** - Autenticación completa (login, logout, sync usuario)
- ✅ **FavoritoBloc** - Gestión de favoritos (carga, toggle)
- ✅ **TiendaBloc** - Tiendas con paginación y búsqueda
- ✅ **ProductoBloc** - Productos con filtros
- ✅ **PlazoletaBloc** - Plazoletas con categorías
- ✅ **OrganizacionBloc** - Organizaciones
- ✅ **ImageBloc** - Manejo de imágenes

### 🔗 INTEGRACIÓN SUPABASE (100%)
- ✅ Cliente configurado con 19+ tablas
- ✅ Paginación y filtros funcionales
- ✅ Cache local con sincronización
- ✅ Fallback multi-CDN para imágenes

### 🗺️ NAVEGACIÓN (100%)
- ✅ GoRouter con 15+ rutas
- ✅ Auth guards para rutas protegidas
- ✅ Deep linking preparado
- ✅ Navegación con go_router y context.push/go

### 📦 DEPENDENCY INJECTION (100%)
- ✅ GetIt configurado
- ✅ Servicio locator funcional
- ✅ Todos los servicios registrados

---

## 🚧 CRÍTICOS - Problemas que impiden testing

Estos problemas deben resolverse ANTES de testing profesional.

### C1: Unificar lógica de logout ✅ COMPLETADO
**Problema:** El logout en `ProfilePage` y el de `ProfileFloatingButton` usaban la misma lógica pero el Google sign-out no era robusto.

**Solución:** Mejorar `FirebaseAuthService.signOut()` para siempre intentar `GoogleSignIn.signOut()` y `GoogleSignIn.disconnect()` sin depender de `currentUser`.

**Cambio realizado:**
- `lib/core/utils/firebase_auth_service.dart` - Método `signOut()` ahora siempre intenta ambos métodos de Google, sin depender de `currentUser`.

### C2: Verificar persistencia sesión Google ✅ COMPLETADO
**Problema:** Cuando logout no completaba correctamente, Google mantenía sesión. "Google Sign In" entraba directo sin pedir cuenta.

**Solución:** El mismo cambio en `FirebaseAuthService.signOut()` - ahora siempre intenta `signOut()` y `disconnect()` de Google.

**Cambio realizado:**
- Ambos métodos están envueltos en try-catch individuales para que si uno falla, el otro se ejecute.
- Ya no se depende de `_googleSignIn.currentUser` que podía ser null aunque el usuario estuviera logueado.

---

## 🟡 CONFIGURACIÓN Y SOPORTE

### S1: Variables .env para soporte/redes ✅ COMPLETADO
**Objetivo:** Variables configurables para WhatsApp, redes sociales, empresa.

**Variables creadas:**
```env
WHATSAPP_SOPORTE_URL=https://wa.me/573057806877?text=Hola%20necesito%20soporte%20para%20el%20Paseo%20del%20Comercio
INSTAGRAM_URL=https://instagram.com/paseodelcomercio.ccv
TIKTOK_URL=https://tiktok.com/@paseodelcomercio.ccv
YOUTUBE_URL=https://youtube.com/@PaseodelComercio
COMPANY_NAME=Paseo del Comercio
COMPANY_URL=https://paseodelcomercio.com
APP_VERSION=1.0.0
```

**Archivos modificados:**
- `.env` - Variables ya existentes
- `lib/core/app/app_config.dart` - Nuevas propiedades: `whatsappSoporteUrl`, `instagramUrl`, `tiktokUrl`, `youtubeUrl`, `companyName`, `companyUrl`

### S2: Página Settings ✅ COMPLETADO
**Objetivo:** Página de configuración con estética glassmorphism.

**Contenido implementado:**
- ~~Toggle tema (oscuro/claro)~~ → **POSTERGADO** - Colores hardcodeados en vistas requieren refactorización completa
- ~~Notificaciones~~ → **POSTERGADO** - Sección completa comentada
- Botón "Acerca de" → navega a `/soporte`
- Botón cerrar sesión con logout funcional

**Ruta:** `/settings`

**Archivos creados:**
- `lib/presentation/pages/settings/settings_page.dart`
- `lib/presentation/providers/theme_provider.dart` (creado, no usado actualmente)

**Widgets:**
- `_GlassSection` - Sección con glassmorphism
- `_SettingsTile` - Tile con animación de press
- `_GoldIconButton` - Botón icono dorado
- `_LogoutDialog` - Diálogo de confirmación logout

**Notas:**
- El toggle de tema oscuro/claro fue removido porque el app tiene colores hardcodeados en cada widget. Para implementar tema claro en el futuro, se requeriría refactorizar ~20+ archivos para usar `Theme.of(context)`. Marcado como **POSTERGADO**.
- La sección de "Notificaciones" está comentada y no se muestra. Será implementada cuando se configure Firebase Cloud Messaging (FCM).

### S3: Página Soporte/Acerca ✅ COMPLETADO
**Objetivo:** Información de soporte y empresa.

**Contenido implementado:**
- Header con logo e iconografía dorada
- Botón WhatsApp (abre URL de .env con url_launcher)
- Enlaces a Instagram, TikTok, YouTube
- Información de versión y sitio web

**Ruta:** `/soporte`

**Archivos creados:**
- `lib/presentation/pages/soporte/soporte_page.dart`

**Widgets:**
- `_SocialTile` - Tile para redes sociales con colores de marca

---

## 🟢 HISTORIAL DE VISITAS

### H1: Cache HistorialLocal ✅ CÓDIGO PREPARADO
**Objetivo:** Guardar localmente tiendas/productos visitados.

**Estructura:**
```dart
// Historial guardado en Hive box 'historial_visitas'
// Métodos agregados a LocalCacheService:
- guardarVisita(id, tipo, datos)
- obtenerHistorialTiendas()
- obtenerHistorialProductos()
- limpiarHistorial()
- limpiarHistorialPorTipo(tipo)
```

**Archivos modificados:**
- `lib/data/datasources/local/local_database.dart` - Añadida caja `historialBox` y métodos de historial

### H2: Guardar visita en DetailPages ⚠️ POSTERGADO
**Implementación en pausa:**
- ~~En TiendaDetailPage, `_registrarVisitaTienda()` ahora también guarda en historial local~~
- ~~En ProductoDetailPage, añadido `_guardarEnHistorial()` llamado en el listener del BlocConsumer~~
- Límite de 50 elementos por tipo implementado pero no activo

**Nota:** Código preparado pero no activo. Las llamadas a guardar historial fueron removidas de TiendaDetailPage y ProductoDetailPage para no afectar el flujo normal de la app.

### H3: Página Historial ✅ CÓDIGO PREPARADO
**Objetivo:** Mostrar historial de visitas recientes.

**Ruta:** `/historial`

**Contenido:**
- Tabs: Tiendas | Productos (con contadores)
- Lista de visitados (más reciente primero)
- Tap → navegar al detalle
- Botón limpiar historial con confirmación

**Archivos creados:**
- `lib/presentation/pages/historial/historial_page.dart`

**Widgets:**
- `_HistorialTile` - Tile con imagen, nombre, tipo y timestamp
- `_GoldIconButton` - Botón icono dorado para AppBar

**Estado:** ⚠️ POSTERGADO - Código listo pero no integrado al flujo. El botón "Historial" fue removido de ProfilePage. Se reactivará cuando el sistema de historial esté completo y funcional.

---

## 🔵 COMPARTIR (SHARE)

### SH1: ShareService ⚠️ PENDIENTE
**Objetivo:** Compartir tiendas, productos, plazoletas, organizaciones.

**URLs web:**
```
https://paseodelcomercio.com/plazoleta/{slug}
https://paseodelcomercio.com/store/{id}
https://paseodelcomercio.com/producto/{id}
https://paseodelcomercio.com/organizacion/{id}
```

**Pasos:**
- [ ] Crear ShareService
- [ ] Métodos: compartirTienda, compartirProducto, compartirPlazoleta, compartirOrganizacion
- [ ] Registrar en service_locator

### SH2: Botones compartir ⚠️ PENDIENTE
**Pasos:**
- [ ] Crear ShareButton reutilizable
- [ ] Botón en TiendaDetailPage, ProductoDetailPage, PlazoletaDetailPage, OrganizacionDetailPage

---

## 🔵 GOOGLE MAPS (WebView + Embed)

### M1: WebView + Google Maps Embed ✅ DECISIÓN TOMADA
**Solución inicial** - WebView con Google Maps Embed (gratuito).

**Futuro:** Migrar a Google Maps SDK cuando sea necesario.

**Pasos:**
- [ ] Agregar webview_flutter o usar UrlLauncher
- [ ] Crear TiendaMapaWidget con WebView
- [ ] Integrar en TiendaDetailPage
- [ ] Manejar dirección no encontrable

### M2: Preparar migración futura ⚠️ PENDIENTE
**Para cuando sea necesario migrar a Google Maps SDK:**
- [ ] Obtener Google Maps API Key
- [ ] Configurar billing en Google Cloud
- [ ] Reemplazar WebView por google_maps_flutter

---

## 🟣 TESTS

### T1: Tests AuthBloc ⚠️ PENDIENTE
**Cobertura:** Login, logout, estados, errores

### T2: Tests FavoritoBloc ⚠️ PENDIENTE
**Cobertura:** Carga favoritos, toggle tienda, toggle producto

### T3: Tests TiendaBloc ⚠️ PENDIENTE
**Cobertura:** Carga tiendas, tienda por ID, búsqueda

### T4: Widget Tests ⚠️ PENDIENTE
**Cobertura:** TiendaCard, ProductoCard, FavoriteButton

---

## ⏸️ POSTERGADOS (Post-Launch)

| Feature | Prioridad | Notas |
|---------|-----------|-------|
| Tema oscuro/claro | ~~Media~~ | **POSTERGADO** - Requiere refactorización de colores hardcodeados en 20+ archivos |
| Historial de visitas | ~~Media~~ | **POSTERGADO** - Código preparado pero botón removido de ProfilePage |
| Notificaciones (Push) | ~~Media~~ | **POSTERGADO** - Sección completa comentada en Settings; requiere FCM |
| Push notifications | Baja | Firebase Cloud Messaging (depende de implementación completa) |
| Geolocator | Baja | Tiendas cercanas, costos envío |
| Pasarela de pagos | **Alta** | **Futuro app emprendedores** |
| Eliminar cuenta | Baja | Requiere flujo especial |
| Multi-idioma | Baja | i18n |
| Coordenadas exactas | Media | Por ahora funciona con dirección texto |
| Deep links | Media | Firebase Dynamic Links o App Links |
| Google Maps SDK | Media | **Futuro: migrar de WebView a SDK** |

---

## 📊 ESTADÍSTICAS

### Estructura
- **Total archivos:** 150+
- **Líneas de código:** 20,000+
- **BLoCs:** 7 implementados
- **Pages:** 10+ pantallas

### Cobertura Funcional
- **Autenticación:** 95% (faltan tests)
- **Tiendas:** 95%
- **Productos:** 95%
- **Favoritos:** 100% ✅
- **Imágenes:** 90%
- **Navegación:** 100%
- **Historial:** ⚠️ POSTERGADO (código listo pero no activo)
- **Settings/Soporte:** 100% ✅
- **Share:** 0% (pendiente)
- **Google Maps:** 0% (en desarrollo - WebView + Embed)

---

## 🛠️ VERIFICACIONES TÉCNICAS

### ✅ VERIFICADO
- [x] Estructura Clean Architecture
- [x] Conexión Supabase
- [x] Servicios core
- [x] Navegación GoRouter
- [x] Dependency injection
- [x] Widgets reutilizables
- [x] Sistema favoritos completo
- [x] Logout en ProfileFloatingButton funciona

### ⚠️ PENDIENTE DE VERIFICACIÓN
- [ ] Logout funcional (C1, C2 - código corregido, pendiente probar en dispositivo)
- [ ] Múltiples cuentas Google en logout (probar después de fix)
- [x] Settings funcional (S2 - implementado)
- [x] Soporte WhatsApp (S3 - implementado)
- [ ] Compartir funcional
- [ ] Mapa en tiendas (WebView + Embed)
- [ ] Tests pasando

### ⚠️ POSTERGADO
- [ ] Historial de visitas - Código preparado pero no activo (postpriorizado por ahora)

---

## 🎯 PRÓXIMOS PASOS INMEDIATOS

```
1. C1 + C2 → 2. S1 → 3. S2 + S3 → 4. H1 + H2 + H3 → 5. SH1 + SH2 → 6. M1 + M2 → 7. T1-T4 → 8. Testing
```

### Fase 1: Críticos (C1, C2) ✅
- [x] Unificar logout - FirebaseAuthService.signOut() mejorado
- [x] Verificar sesión Google - signOut() y disconnect() siempre se llaman

### Fase 2: Configuración (S1, S2, S3) ✅
- [x] Variables .env - AppConfig actualizado
- [x] Settings - Página completa (tema oscuro/claro removido - postergado)
- [x] Soporte/Acerca - Página con WhatsApp y redes sociales

### Fase 3: Historial (H1, H2, H3) ⚠️ POSTERGADO
- [x] Cache historial - Métodos en LocalCacheService (código listo)
- [x] Guardar visitas - TiendaDetailPage y ProductoDetailPage (código preparado pero removido temporalmente)
- [x] Página historial - HistorialPage con tabs y navegación (código listo pero no integrado)

### Fase 4: Compartir (SH1, SH2)
- [ ] ShareService
- [ ] Botones compartir

### Fase 5: Google Maps (M1, M2) - WebView + Embed
- [ ] WebView con Google Maps Embed
- [ ] Integrar en TiendaDetailPage

### Fase 6: Tests (T1-T4)
- [ ] AuthBloc tests
- [ ] FavoritoBloc tests
- [ ] TiendaBloc tests
- [ ] Widget tests

### Fase 7: Testing profesional
- [ ] Build APK
- [ ] Testing en dispositivo
- [ ] Validar flujos completos

---

## 📁 DOCUMENTACIÓN RELACIONADA

- `doc/MOVIL_PLAN.md` - Plan detallado con procedimientos y comparativa de mapas
- `doc/ESQUEMA_FAVORITOS.md` - Documentación del sistema de favoritos
- `doc/AGENTS.md` - Guía para agentes de desarrollo
- `doc/PROGRESO_Y_PLAN.md` - Este documento - resumen de progreso

---

**Última actualización:** Marzo 2026  
**Siguiente revisión:** Al completar Fase 1 (C1, C2)  
**Responsable:** Equipo de desarrollo  
**Estado:** 🚧 EN DESARROLLO - Preparación para testing

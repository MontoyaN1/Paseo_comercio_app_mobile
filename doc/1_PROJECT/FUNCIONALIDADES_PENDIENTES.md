# FUNCIONALIDADES PENDIENTES

**Fecha:** Marzo 2026  
**Estado del proyecto:** MVP Funcional - En fase de refinamiento  
**Documento:** Catálogo de funcionalidades pendientes y postergadas  

---

## 📋 RESUMEN EJECUTIVO

La app Paseo del Comercio tiene un MVP funcional con las features core implementadas. Este documento cataloga las funcionalidades que quedan pendientes de implementar, divididas en:

1. **🟡 PENDIENTES DE TESTING** - Funcionalidades implementadas pero no probadas en dispositivo
2. **🔴 PENDIENTES DE IMPLEMENTAR** - Funcionalidades planificadas pero no iniciadas
3. **⏸️ POSTERGADAS** - Funcionalidades deliberadamente postergadas para post-launch

---

## 🟡 1. PENDIENTES DE TESTING

Estas funcionalidades están **implementadas en código** pero requieren **testing en dispositivo** para validar su correcto funcionamiento.

### 1.1 Logout y Sesión Google
**Estado:** ✅ Implementado | ⚠️ Pendiente testing

**Problema original:** El logout no cerraba correctamente la sesión de Google, permitiendo reingreso sin pedir cuenta.

**Solución implementada:**
- `FirebaseAuthService.signOut()` ahora siempre intenta `GoogleSignIn.signOut()` y `GoogleSignIn.disconnect()`
- Ambos métodos en try-catch individuales para no depender de `currentUser`

**Archivos:**
- `lib/core/utils/firebase_auth_service.dart`

**Validación requerida:**
- [ ] Hacer logout desde Settings
- [ ] Verificar que Google Sign In pide cuenta nuevamente
- [ ] Probar con múltiples cuentas Google

---

### 1.2 Sistema de Favoritos
**Estado:** ✅ Implementado | ⚠️ Pendiente testing

**Problema reportado (19/mar/2026):** Los favoritos no se mostraban al renderizar en PlazoletaDetailPage hasta navegar a otro lado y volver.

**Solución implementada:**
- `FavoritoBloc` ahora escucha cambios de autenticación (`onAuthStateChanged`)
- Retry de 500ms si `currentUser` es null al inicio
- Nuevo evento `ClearFavoritos` para limpiar estado al desautenticar

**Archivos:**
- `lib/presentation/blocs/favorito/favorito_bloc.dart`
- `lib/presentation/blocs/favorito/favorito_event.dart`

**Validación requerida:**
- [ ] Abrir PlazoletaDetailPage - verificar que favoritos aparecen inmediatamente
- [ ] Marcar favorito en tienda/producto - verificar que se guarda en Supabase
- [ ] Navegar a otra página y volver - verificar que estado persiste
- [ ] Hacer logout y login - verificar que favoritos del usuario se cargan

---

### 1.3 Compartir y Retorno de App
**Estado:** ✅ Implementado | ⚠️ Pendiente testing

**Problema reportado (19/mar/2026):** Al compartir una vista y volver a la app, se quedaba en "cargando" hasta presionar back de Android.

**Solución implementada:**
- `WidgetsBindingObserver` agregado a `TiendaDetailPage`, `PlazoletaDetailPage`, `OrganizacionDetailPage`
- `didChangeAppLifecycleState` recarga datos al detectar `AppLifecycleState.resumed`

**Archivos:**
- `lib/presentation/pages/tiendas/tienda_detail_page.dart`
- `lib/presentation/pages/plazoletas/plazoleta_detail_page.dart`
- `lib/presentation/pages/organizaciones/organizacion_detail_page.dart`

**Validación requerida:**
- [ ] Abrir TiendaDetailPage → Compartir → Volver - verificar que datos persisten
- [ ] Mismo flujo en PlazoletaDetailPage
- [ ] Mismo flujo en OrganizacionDetailPage
- [ ] Mismo flujo en ProductoDetailPage (ya tenía observer)

---

### 1.4 Microsoft Sign In
**Estado:** ✅ Implementado | ⚠️ Pendiente testing

**Fecha de implementación:** Marzo 2026

**Funcionalidad:** Login con cuenta Microsoft usando Firebase MicrosoftAuthProvider.

**Implementación:**
- `FirebaseAuthService.signInWithMicrosoft()` usa `MicrosoftAuthProvider` de `firebase_auth`
- Scopes: `email`, `profile`, `openid`
- Flag `_isSigningInWithMicrosoft` para evitar múltiples intentos simultáneos
- Manejo de errores: `web-context-canceled`, `web-context-already-presented`, `cancelled`, `user-cancelled`
- Mensaje amigable: "Proceso cancelado por el usuario" (snackbar informativo, no error)

**Cambios en archivos:**
- `lib/core/utils/firebase_auth_service.dart` - Método `signInWithMicrosoft()` y manejo de errores
- `lib/presentation/pages/auth/login_page.dart` - Botón Microsoft y método `_microsoftSignIn()`
- `android/app/src/main/res/raw/msal_config.json` - Configuración Azure AD
- `android/app/src/main/AndroidManifest.xml` - BrowserTabActivity para MSAL

**Configuración Azure:**
- Client ID: `39c6ba8e-6b2d-4d69-847a-66d8fa5e5fff`
- Redirect URI: `msauth://com.example.paseo_del_comercio/rdlatGzYybgBxHGQRFSkXK8kC58%3D`

**Variables de entorno (.env):**
```env
MICROSOFT_CLIENT_ID=39c6ba8e-6b2d-4d69-847a-66d8fa5e5fff
MICROSOFT_REDIRECT_URI=msauth://com.example.paseo_del_comercio/rdlatGzYybgBxHGQRFSkXK8kC58%3D
```

**Nota técnica:**
- Microsoft Sign In usa Chrome Custom Tabs (webview) - no tiene SDK nativo como Google
- El avatar de perfil de Microsoft puede no tomarse en el primer login
- El logout de Microsoft funciona automáticamente al cerrar sesión de Firebase

**Validación requerida:**
- [ ] Login exitoso con cuenta Microsoft
- [ ] Cancelar login - verificar mensaje amigable
- [ ] Volver sin completar - verificar mensaje amigable
- [ ] Avatar de perfil se muestra correctamente
- [ ] Logout cierra sesión de Microsoft

---

### 1.6 Botón de Favorito en Detalles de Tienda y Producto
**Estado:** ✅ Implementado | ⚠️ Pendiente testing

**Fecha de implementación:** Marzo 2026

**Funcionalidad:** Botón de favorito en las vistas de detalle de tienda y producto, junto al botón de compartir.

**Problema resuelto:**
- En `TiendaDetailPage` no había botón de favorito en el AppBar
- En `ProductoDetailPage` no había botón de favorito en el AppBar
- La `TiendaCard` dentro de `ProductoDetailPage` tenía `showFavoriteButton: false`

**Implementación:**
- Widget reutilizable `FavoriteButton` creado en `lib/presentation/widgets/favorite_button.dart`
- Diseño glassmorphism con animaciones (mismo estilo que `_FavButton` en cards)
- `BlocBuilder<FavoritoBloc, FavoritoState>` para obtener estado actual
- `ToggleTiendaFavorito` y `ToggleProductoFavorito` para manejar toggles

**Cambios en archivos:**
- `lib/presentation/widgets/favorite_button.dart` - **NUEVO** widget reutilizable
- `lib/presentation/pages/tiendas/tienda_detail_page.dart` - Botón favorito en AppBar
- `lib/presentation/pages/productos/producto_detail_page.dart` - Botón favorito en AppBar + TiendaCard habilitada

**Validación requerida:**
- [ ] TiendaDetailPage: tocar botón de favorito y verificar que se guarda
- [ ] TiendaDetailPage: verificar que el estado se refleja inmediatamente
- [ ] ProductoDetailPage: tocar botón de favorito del producto
- [ ] ProductoDetailPage: verificar que la TiendaCard muestra el botón de favorito
- [ ] Navegar entre páginas y volver - verificar que estado persiste

---

### 1.5 Botón "Ver Mapa" en Tiendas
**Estado:** ✅ Implementado | ⚠️ Pendiente testing

**Funcionalidad:** Botón "Ver mapa" junto a la dirección que abre Google Maps en navegador externo.

**Implementación:**
- Usa `url_launcher` con URL `https://www.google.com/maps/search/?api=1&query={direccion}`
- Fallback a esquema `geo:` si falla

**Archivos:**
- `lib/presentation/pages/tiendas/tienda_detail_page.dart` - método `_openInMaps()`

**Validación requerida:**
- [ ] Abrir TiendaDetailPage con dirección
- [ ] Tocar botón "Ver mapa"
- [ ] Verificar que abre Google Maps correctamente
- [ ] Verificar con diferentes direcciones

---

## 🔴 2. PENDIENTES DE IMPLEMENTAR

Funcionalidades planificadas que **aún no tienen código activo**.

### 2.1 Phase 6: Tests (T1-T4)

**Descripción:** Suite de tests unitarios y de widget para validar el código.

| Test | Cobertura | Archivo destino |
|------|-----------|-----------------|
| **T1: AuthBloc** | Login, logout, estados, errores | `test/presentation/blocs/auth_bloc_test.dart` |
| **T2: FavoritoBloc** | Carga favoritos, toggle tienda, toggle producto | `test/presentation/blocs/favorito_bloc_test.dart` |
| **T3: TiendaBloc** | Carga tiendas, tienda por ID, búsqueda | `test/presentation/blocs/tienda_bloc_test.dart` |
| **T4: Widget Tests** | TiendaCard, ProductoCard, FavoriteButton | `test/presentation/widgets/` |

**Pasos:**
1. [ ] Crear mocks para repositories y datasources
2. [ ] Implementar tests para AuthBloc
3. [ ] Implementar tests para FavoritoBloc
4. [ ] Implementar tests para TiendaBloc
5. [ ] Implementar widget tests
6. [ ] Configurar CI/CD para run tests en cada push

---

### 2.2 Deep Links (Firebase Dynamic Links / App Links)

**Descripción:** Permitir que links compartidos abran directamente la app.

**Estado:** ✅ **IMPLEMENTADO** - Pendiente Testing

**Documentación completa:** `doc/DEEP_LINKS_IMPLEMENTATION.md`

**Opciones técnicas:**
| Opción | Plataforma | Costo | Complejidad | Estado |
|--------|-----------|-------|-------------|--------|
| Firebase Dynamic Links | iOS + Android | ~~Gratis~~ | ~~Media~~ | ⚠️ **DEPRECATED (cerró 2025)** |
| App Links (Android) | Solo Android | Gratis | Baja | ✅ Implementado |
| Universal Links (iOS) | Solo iOS | Gratis | Baja | ❌ Pendiente |

**Implementación Android:**
1. Configurar Android App Links en `AndroidManifest.xml`
2. Crear keystore dedicado para same SHA256 en debug y release
3. Subir `assetlinks.json` al servidor
4. GoRouter maneja routing automáticamente

**Rutas implementadas:**
- `/store/:id` → TiendaDetailPage
- `/producto/:id` → ProductoDetailPage
- `/plazoleta/:slug` → PlazoletaDetailPage
- `/organizacion/:id` → OrganizacionDetailPage

**Pendiente:**
- [ ] Testing en producción (Play Store con App Signing)
- [ ] iOS Universal Links

---

## ⏸️ 3. POSTERGADAS (Post-Launch)

Funcionalidades **deliberadamente postergadas** para después del launch inicial.

### 3.1 Tema Oscuro/Claro

**Prioridad:** ~~Media~~ → ✅ **EN IMPLEMENTACIÓN**  
**Estado:** Planificado - Ver [TEMA_Y_FRAGMENTACION.md](../4_IMPLEMENTATION/TEMA_Y_FRAGMENTACION.md)

**Decisión de diseño:**
- Se implementará solo en UI genérica (colores de superficie, texto, bordes)
- Los painters isométricos (mall, login, etc.) permanecen como branding oscuro
- Detección automática del tema del sistema + toggle manual en Settings

**Estado actual:**
- App usa tema oscuro hardcodeado
- Toggle de tema fue removido de Settings
- Código preparado en `lib/presentation/providers/theme_provider.dart` (no usado)
- Plan completo documentado en `doc/4_IMPLEMENTATION/TEMA_Y_FRAGMENTACION.md`

**Cambios planificados:**
- Crear `lib/core/theme/app_colors.dart` - Colores para light/dark
- Crear `lib/core/theme/app_theme.dart` - ThemeData.light/dark
- Integrar en `main.dart` con `themeMode: ThemeMode.system`
- Agregar toggle en Settings
- Refactorizar ~17 archivos para usar `Theme.of(context)`

**Esfuerzo estimado:** 6-8 sprints (incluye fragmentación de archivos)

---

### 3.2 Historial de Visitas

**Prioridad:** ~~Media~~ → Baja (postergado)  
**Razón:** Código preparado pero no integrado al flujo

**Estado actual:**
- ✅ Cache historial en Hive (`LocalCacheService`)
- ✅ Métodos: `guardarVisita`, `obtenerHistorialTiendas`, `obtenerHistorialProductos`
- ✅ Página `HistorialPage` creada (`lib/presentation/pages/historial/historial_page.dart`)
- ❌ Botón "Historial" removido de ProfilePage
- ❌ Llamadas a guardar historial comentadas en detail pages

**Para activar:**
1. Descomentar `guardarEnHistorial()` en `TiendaDetailPage` y `ProductoDetailPage`
2. Agregar botón "Historial" en `ProfilePage`
3. Descomentar ruta `/historial` en `AppRouter`

---

### 3.3 Notificaciones Push (FCM)

**Prioridad:** ~~Media~~ → Baja  
**Razón:** Requiere configuración de Firebase Cloud Messaging

**Estado actual:**
- Sección de notificaciones comentada en Settings
- Infraestructura preparada para recibir push

**Para implementar:**
1. [ ] Configurar Firebase Cloud Messaging (FCM)
2. [ ] Crear `NotificationService`
3. [ ] Implementar `FirebaseMessaging` listener
4. [ ] Mostrar notificaciones locales o remotas
5. [ ] Descomentar UI en Settings

---

### 3.4 Google Maps SDK (Mapa Embebido)

**Prioridad:** Media  
**Razón:** Solución actual con url_launcher funciona, SDK requiere API key + billing

**Error encontrado (19/mar/2026):**
```
PlatformException: flutter_inappwebview - unregistered platform view type
```

**Solución actual (funcionando):**
- Botón "Ver mapa" abre Google Maps en navegador externo
- URL: `https://www.google.com/maps/search/?api=1&query={direccion}`

**Para migrar a SDK:**
1. [ ] Obtener Google Maps API Key de Google Cloud Console
2. [ ] Configurar billing (>$200/mes gratis)
3. [ ] Instalar `google_maps_flutter`
4. [ ] Reemplazar botón con widget `GoogleMap()`
5. [ ] Mostrar marcador en ubicación de tienda

**Costos:**
| Producto | Precio por 1,000 cargas |
|----------|------------------------|
| Dynamic Maps | $7.00 |
| Maps SDK (Android) | $0 - $7 |
| Geocoding | $5.00 |

---

### 3.5 Geolocator (Tiendas Cercanas)

**Prioridad:** Baja  
**Razón:** Feature nice-to-have para versión future

**Funcionalidad planeada:**
- Mostrar tiendas cercanas al usuario
- Calcular distancia
- Filtrar por radio
- Costos de envío según distancia

**Requiere:**
- `geolocator` package (ya en pubspec.yaml pero no usado)
- Permisos de ubicación
- Latitud/longitud de tiendas (actualmente solo dirección texto)

---

### 3.6 Pasarela de Pagos

**Prioridad:** Alta (para app emprendedores)  
**Razón:** Feature de monetización, no para MVP cliente

**Nota:** Especificar en el roadmap de la app de emprendedores, no en la app cliente.

---

### 3.7 Eliminar Cuenta

**Prioridad:** Baja  
**Razón:** Requiere flujo legal de eliminación de datos personales

**Consideraciones:**
- RGPD / Ley de datos personales Colombia
- Eliminar datos de Firebase Auth
- Eliminar datos de Supabase
- Eliminar favoritos, historial, etc.

---

### 3.8 Multi-idioma (i18n)

**Prioridad:** Baja  
**Razón:** App inicialmente en español

**Para implementar:**
- `flutter_localizations`
- `intl` package
- Archivos `lib/l10n/` con traducciones
- ArbGenerator para generar código

---

## 📊 RESUMEN DE PRIORIDADES

### Inmediato (Para Testing MVP)
| Feature | Estado | Testing requerido |
|---------|--------|-------------------|
| Logout + Google Sign Out | ✅ Implementado | ✅ Sí |
| Favoritos (timing fix) | ✅ Implementado | ✅ Sí |
| Share → Return lifecycle | ✅ Implementado | ✅ Sí |
| Botón "Ver mapa" | ✅ Implementado | ✅ Sí |
| Tests T1-T4 | ❌ Pendiente | N/A |

### Corto Plazo (Post-MVP)
| Feature | Prioridad | Esfuerzo |
|---------|-----------|----------|
| Deep Links | ~~Media~~ | ~~Medio~~ | ✅ Implementado (pendiente testing) |
| **Tema claro/oscuro** | Media | **Alto** (ver doc) |
| Google Maps SDK | Media | Medio |
| Historial de Visitas | Baja | Bajo (ya está listo) |
| Notificaciones Push | Baja | Medio |

### Largo Plazo (Post-Launch)
| Feature | Prioridad | Esfuerzo |
|---------|-----------|----------|
| Geolocator | Baja | Medio |
| Eliminar cuenta | Baja | Medio |
| Multi-idioma | Baja | Medio |
| Pasarela de pagos | Alta | Alto |

---

## 📁 ARCHIVOS RELACIONADOS

- `doc/PROGRESO_Y_PLAN.md` - Progreso general del proyecto
- `doc/MOVIL_PLAN.md` - Plan de implementación móvil
- `doc/4_IMPLEMENTATION/TEMA_Y_FRAGMENTACION.md` - Plan de tema + fragmentación
- `doc/4_IMPLEMENTATION/DEEP_LINKS_IMPLEMENTATION.md` - Guía de deep links
- `doc/AGENTS.md` - Guía para desarrolladores

---

**Última actualización:** Marzo 2026  
**Próxima revisión:** Al completar testing MVP  
**Responsable:** Equipo de desarrollo

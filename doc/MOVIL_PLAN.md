# PLAN MÓVIL - App Cliente Paseo del Comercio

**Fecha:** Marzo 2026  
**Estado:** Plan para implementación  
**Objetivo:** App funcional para testing profesional (Android)

---

## CONTEXTO

### Visión del Proyecto
Esta es la **app cliente** de Paseo del Comercio - un centro comercial virtual para el AMB (Área Metropolitana de Bucaramanga), Colombia.

Los clientes podrán:
- Navegar plazoletas, tiendas y productos
- Marcar favoritos
- Ver historial de visitas
- **Futuro:** Comprar productos con pasarela de pagos

La otra app (para emprendedores) permitirá crear tiendas, administrar productos y gestionar pagos.

### Estado Actual
- ✅ Navegación completa (Plazoletas → Tiendas → Productos)
- ✅ Sistema de favoritos implementado
- ✅ Autenticación Firebase + Google Sign In
- ✅ Perfil de usuario
- ✅ Tema oscuro con acentos dorados
- ⚠️ Logout tiene problemas (sesión no se cierra correctamente)
- ⚠️ Faltan Settings, Soporte, Historial de visitas
- ⚠️ No hay tests
- ❌ Google Maps no integrado
- ❌ Compartir no implementado

---

## ESTRUCTURA DEL PLAN

```
FASE 1: Críticas (problemas que impiden testing)
├── C1: Unificar lógica de logout
├── C2: Verificar persistencia sesión Google

FASE 2: Configuración y Soporte
├── S1: Variables .env para soporte/redes
├── S2: Página Settings
├── S3: Página Soporte/Acerca

FASE 3: Historial de Visitas
├── H1: Cache historial local (Hive)
├── H2: Guardar visita en detail pages
├── H3: Página historial

FASE 4: Compartir (Share)
├── SH1: Crear ShareService
├── SH2: Botones compartir en detail pages

FASE 5: Google Maps (WebView + Embed)
├── M1: WebView + Google Maps Embed
├── M2: Preparar migración futura a SDK

FASE 6: Tests
├── T1: Tests AuthBloc
├── T2: Tests FavoritoBloc
├── T3: Tests TiendaBloc
├── T4: Widget tests

FASE 7: Testing profesional
└── Validación completa de flujos
```

---

## 🔴 FASE 1: CRÍTICAS

### C1: Unificar lógica de logout ✅ COMPLETADO

**Problema:**
- El logout no cerraba correctamente la sesión de Google
- A veces la sesión seguía activa después de cerrar

**Solución aplicada:**
- Modificado `FirebaseAuthService.signOut()` en `lib/core/utils/firebase_auth_service.dart`
- Ahora siempre intenta `GoogleSignIn.signOut()` y `GoogleSignIn.disconnect()` sin depender de `currentUser`
- Ambos métodos están en try-catch individuales

**Cambio realizado:**
```dart
// Antes (problemático):
if (_googleSignIn.currentUser != null) {
  await _googleSignIn.disconnect();
}

// Después (robusto):
try {
  await _googleSignIn.signOut();
} catch (_) {}
try {
  await _googleSignIn.disconnect();
} catch (_) {}
```

---

### C2: Verificar persistencia de sesión Google ✅ COMPLETADO

**Problema:**
- Cuando logout no completaba correctamente, Google mantenía sesión
- "Google Sign In" entraba directo sin pedir cuenta

**Solución aplicada:**
- El mismo cambio en `FirebaseAuthService.signOut()` asegura que ambos `signOut()` y `disconnect()` siempre se intenten
- Ya no se depende de `_googleSignIn.currentUser` que podía ser null aunque el usuario estuviera logueado

---

## 🟡 FASE 2: CONFIGURACIÓN Y SOPORTE

### S1: Crear variables .env ✅ COMPLETADO

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
- `lib/core/app/app_config.dart` - Nuevas propiedades

---

### S2: Crear página Settings ✅ COMPLETADO

**Contenido implementado:**
- Toggle tema (oscuro/claro) con ThemeProvider
- Toggle notificaciones (UI placeholder)
- Botón "Acerca de" → navega a `/soporte`
- Botón cerrar sesión

**Ruta:** `/settings`

**Archivos creados:**
- `lib/presentation/pages/settings/settings_page.dart`
- `lib/presentation/providers/theme_provider.dart`

---

### S3: Crear página Soporte/Acerca ✅ COMPLETADO

**Contenido implementado:**
- Header con logo e iconografía dorada
- Botón WhatsApp (abre URL de .env)
- Enlaces a Instagram, TikTok, YouTube
- Información de versión y sitio web

**Ruta:** `/soporte`

**Archivos creados:**
- `lib/presentation/pages/soporte/soporte_page.dart`

---

## 🟢 FASE 3: HISTORIAL DE VISITAS

### H1: Crear cache HistorialVisitados

**Objetivo:**
Guardar localmente (Hive) los productos y tiendas que el usuario ha visitado.

**Estructura de datos:**
```dart
class HistorialVisita {
  final int id;
  final String tipo; // 'tienda' o 'producto'
  final DateTime timestamp;
}
```

**Ubicación:**
```
lib/data/datasources/local/hive_historial.dart
```

**Pasos:**
1. [ ] Crear adapter Hive para `HistorialVisita`
2. [ ] Crear `HistorialLocalDataSource` con métodos:
   - `guardarVisita(int id, String tipo)`
   - `obtenerHistorialTiendas()`
   - `obtenerHistorialProductos()`
   - `limpiarHistorial()`
3. [ ] Registrar en `service_locator.dart`

---

### H2: Guardar visita en detail pages

**Objetivo:**
Cuando el usuario entra a TiendaDetail o ProductoDetail, guardar en el historial.

**Pasos:**
1. [ ] En `TiendaDetailPage.initState()` o `build()`, llamar a `historialDataSource.guardarVisita(tiendaId, 'tienda')`
2. [ ] En `ProductoDetailPage.initState()` o `build()`, llamar a `historialDataSource.guardarVisita(productoId, 'producto')`
3. [ ] Limitar a últimos 50 elementos por tipo

---

### H3: Crear página Historial

**Objetivo:**
Mostrar al usuario su historial de visitas recientes.

**Ruta nueva:**
```
/historial → lib/presentation/pages/historial/historial_page.dart
```

**Contenido:**
- Tabs: "Tiendas" | "Productos"
- Lista de items visitados recientemente (más reciente primero)
- Mostrar: imagen, nombre, fecha de visita
- Tap → navegar al detalle
- Pull to refresh

**Pasos:**
1. [ ] Crear `lib/presentation/pages/historial/historial_page.dart`
2. [ ] Crear widgets para mostrar items del historial
3. [ ] Conectar con `HistorialLocalDataSource`
4. [ ] Cargar datos de tiendas y productos desde cache
5. [ ] Agregar ruta en `app_router.dart`
6. [ ] Actualizar `_buildActionsSection` en `profile_page.dart` para navegar a historial

---

## 🔵 FASE 4: COMPARTIR (SHARE)

### SH1: Crear ShareService

**Objetivo:**
Permitir compartir tiendas, productos, plazoletas y organizaciones.

**URLs de la web:**
```
https://paseodelcomercio.com/plazoleta/{slug}
https://paseodelcomercio.com/store/{id}
https://paseodelcomercio.com/producto/{id}
https://paseodelcomercio.com/organizacion/{id}
```

**Package:**
Usar `share_plus` que ya está en `pubspec.yaml` pero no se usa.

**Implementación:**
```dart
Future<void> compartirTienda(Tienda tienda) async {
  final url = 'https://paseodelcomercio.com/store/${tienda.id}';
  await Share.share(
    'Mira esta tienda: ${tienda.nombre}\n$url',
    subject: tienda.nombre,
  );
}
```

**Pasos:**
1. [ ] Crear `ShareService` en `lib/core/utils/share_service.dart`
2. [ ] Métodos: `compartirTienda()`, `compartirProducto()`, `compartirPlazoleta()`, `compartirOrganizacion()`
3. [ ] Registrar en service_locator

---

### SH2: Botones compartir en detail pages

**Objetivo:**
Agregar botón compartir en las páginas de detalle.

**Pasos:**
1. [ ] Crear widget `ShareButton` reutilizable
2. [ ] Agregar en `TiendaDetailPage` (app bar actions)
3. [ ] Agregar en `ProductoDetailPage` (app bar actions)
4. [ ] Agregar en `PlazoletaDetailPage` (app bar actions)
5. [ ] Agregar en `OrganizacionDetailPage` (app bar actions)

---

## 🔵 FASE 5: GOOGLE MAPS (WebView + Embed - Solución Inicial)

### M1: WebView + Google Maps Embed

**Objetivo:**
Mostrar mapa en TiendaDetail usando Google Maps Embed (gratuito).

**Decisión del equipo:**
- Usar **WebView + Google Maps Embed** como solución inicial
- **Futuro:** Migrar a Google Maps SDK cuando sea necesario

**Cómo funciona:**
- URL tipo: `https://www.google.com/maps?q=DIRECCION&output=embed`
- No requiere API key
- Sin costos
- Similar a como funciona en la web actual

**Widget:**
```dart
class TiendaMapaWidget extends StatelessWidget {
  final String direccion;
  // WebView con Google Maps Embed
}
```

**Pasos:**
1. [ ] Agregar `webview_flutter` a pubspec.yaml (o usar UrlLauncher para abrir en app)
2. [ ] Crear widget TiendaMapaWidget con WebView
3. [ ] Integrar en TiendaDetailPage
4. [ ] Manejar caso de dirección no encontrable

---

### M2: Preparar migración futura a Google Maps SDK

**Objetivo:**
Documentar lo necesario para migrar a Google Maps SDK en el futuro.

**Para cuando sea necesario:**
1. [ ] Obtener Google Maps API Key de Google Cloud Console
2. [ ] Configurar billing en Google Cloud
3. [ ] Agregar `google_maps_flutter` package
4. [ ] Reemplazar WebView por GoogleMap widget
5. [ ] Optimizar paraSDK nativo (markers, cámara, etc.)

**Costos futuros a considerar:**
- Dynamic Maps: $7/1,000 cargas
- $200/mes gratis con billing configurado

---

## 🟣 FASE 5: TESTS

### T1: Tests AuthBloc

**Cobertura:**
- Login con email/password
- Login con Google
- Logout
- Estado de sesión (authenticated/unauthenticated)
- Manejo de errores

**Ubicación:**
```
test/presentation/blocs/auth_bloc_test.dart
```

**Pasos:**
1. [ ] Crear `MockAuthRepository`
2. [ ] Crear `AuthBloc` con dependencias mockeadas
3. [ ] Tests para cada evento: `AuthSignInRequested`, `AuthSignOutRequested`, etc.
4. [ ] Tests para cada estado

---

### T2: Tests FavoritoBloc

**Cobertura:**
- Carga de favoritos
- Toggle tienda favorita
- Toggle producto favorita
- Manejo de errores

**Ubicación:**
```
test/presentation/blocs/favorito_bloc_test.dart
```

**Pasos:**
1. [ ] Crear `MockFavoritoRepository`
2. [ ] Tests para `LoadFavoritos`
3. [ ] Tests para `ToggleTiendaFavorito`
4. [ ] Tests para `ToggleProductoFavorito`

---

### T3: Tests TiendaBloc

**Cobertura:**
- Carga de tiendas
- Carga de tienda por ID
- Búsqueda de tiendas

**Ubicación:**
```
test/presentation/blocs/tienda_bloc_test.dart
```

---

### T4: Widget Tests

**Cobertura:**
- TiendaCard
- ProductoCard
- FavoriteButton (animaciones)

**Ubicación:**
```
test/presentation/widgets/tienda_card_test.dart
test/presentation/widgets/producto_card_test.dart
test/presentation/widgets/favorite_button_test.dart
```

---

## ⏸️ POSTERGADOS (Post-Launch)

| Feature | Prioridad | Notas |
|---------|-----------|-------|
| Push notifications | Baja | Firebase Cloud Messaging |
| Geolocator | Baja | Tiendas cercanas, costos envío |
| Pasarela de pagos | Alta | **Futuro app emprendedores** |
| Eliminar cuenta | Baja | Requiere flujo especial |
| Multi-idioma | Baja | i18n |
| Coordenadas exactas | Media | Por ahora funciona con dirección texto |

---

## DEEP LINKS

### URLs de la web
```
https://paseodelcomercio.com/plazoleta/{slug}
https://paseodelcomercio.com/store/{id}
https://paseodelcomercio.com/producto/{id}
https://paseodelcomercio.com/organizacion/{id}
```

### Para app móvil
Cuando alguien comparte desde el celular, la app debe:
1. Abrir la app si está instalada
2. Ir directamente al detalle correspondiente

**Implementación futura (post-launch):**
- Firebase Dynamic Links, o
- App Links (Android), Universal Links (iOS)

**Por ahora:**
- Compartir genera URL web
- Si la app está abierta, funciona con la URL
- Si no, el usuario abre la web

---

## ORDEN DE IMPLEMENTACIÓN

```
1. C1 → C2          (Critical: logout funciona)
2. S1               (Variables .env)
3. S2 → S3          (Settings y Soporte)
4. H1 → H2 → H3     (Historial de visitas)
5. SH1 → SH2        (Compartir - Share)
6. M1 → M2          (Google Maps - PENDIENTE DECISIÓN)
7. T1 → T2 → T3 → T4 (Tests)
8. Testing          (Validación completa)
```

---

## MÉTRICAS DE ÉXITO

- ✅ Logout funciona 100% (múltiples cuentas Google)
- ✅ Settings accesible y funcional
- ✅ Soporte abre WhatsApp correctamente
- ✅ Historial guarda y muestra visitas
- ✅ Mapa muestra dirección de tiendas
- ✅ Compartir genera links correctos
- ✅ Tests pasando con >70% cobertura

---

## NOTAS

### Sobre direcciones en Google Maps
- BD solo tiene dirección texto, no lat/lon
- Google Maps busca por dirección y marca la ubicación
- Funciona bien en la app web actual
- Centrar por defecto en AMB de Bucaramanga

---

## 📊 COMPARATIVA: GOOGLE MAPS vs ALTERNATIVAS

### Decisión tomada ✅
> **WebView + Google Maps Embed** como solución inicial, con intención de migrar a Google Maps SDK en el futuro.

### Opciones disponibles

| Opción | Costo Mensual | API Key Requerida | Calidad Mapa | Esfuerzo |
|--------|--------------|-------------------|--------------|----------|
| **WebView + Embed** ✅ | Gratis | No | ⭐⭐⭐ | Bajo |
| **Google Maps SDK** | ~$7/1K cargas | Sí (con billing) | ⭐⭐⭐⭐⭐ | Bajo |
| **OpenStreetMap** | Gratis | No | ⭐⭐⭐⭐ | Alto |
| **Mapbox** | 50K gratis/mes | Sí | ⭐⭐⭐⭐⭐ | Bajo |

### Detalle de costos (Google Maps SDK - futuro)

| Producto | Precio por 1,000 cargas |
|---------|------------------------|
| Dynamic Maps | $7.00 |
| Maps SDK (Android) | $0 - $7 depende uso |
| Geocoding | $5.00 |
| Places API | $17 - $32 |

**$200/mes gratis** con billing configurado.

### Cómo funciona la solución actual (WebView + Embed)

- URL tipo: `https://www.google.com/maps?q=DIRECCION&output=embed`
- No requiere API key
- Sin costos
- Similar a como funciona en la web actual
- Requiere conexión a internet

### Plan de migración futura

Cuando el volumen de usuarios lo justifique:
1. Obtener Google Maps API Key de Google Cloud Console
2. Configurar billing en Google Cloud
3. Reemplazar WebView por `google_maps_flutter` SDK
4. Beneficios: mejor UX, offline maps, markers personalizados

---

**Documento creado:** Marzo 2026  
**Última actualización:** Marzo 2026  
**Estado:** Listo para implementación  

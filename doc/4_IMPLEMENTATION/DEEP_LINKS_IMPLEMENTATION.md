# Deep Links Implementation Guide

**Fecha:** Marzo 2026
**Estado:** ✅ COMPLETADO - Pendiente Testing en producción
**Última actualización:** Marzo 2026

---

## RESUMEN EJECUTIVO

Deep Links implementados para Android usando **App Links** (`paseodelcomercio.com`) y custom scheme (`paseodelcomercio://`).

### Enlaces soportados:

| Enlace | Ruta | Página |
|--------|------|--------|
| `https://paseodelcomercio.com/store/74` | Legacy | TiendaDetailPage |
| `https://paseodelcomercio.com/producto/258` | Legacy | ProductoDetailPage |
| `https://paseodelcomercio.com/plazoleta/artesanias` | Legacy | PlazoletaDetailPage (por slug) |
| `https://paseodelcomercio.com/organizacion/43` | Legacy | OrganizacionDetailPage |
| `paseodelcomercio://app/store/74` | Custom | TiendaDetailPage |
| `paseodelcomercio://app/producto/258` | Custom | ProductoDetailPage |

**Nota:** Las rutas legacy de ShareService (`/store/:id`, `/producto/:id`, etc.) fueron agregadas a GoRouter para mantener compatibilidad con enlaces compartidos previamente.

---

## CONFIGURACIÓN IMPLEMENTADA

### 1. AndroidManifest.xml

**Ubicación:** `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Custom Scheme (funciona inmediatamente, sin verificación) -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="paseodelcomercio" android:host="app" />
</intent-filter>

<!-- App Links - Android (paseodelcomercio.com) -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="paseodelcomercio.com" />
</intent-filter>
```

### 2. assetlinks.json (Servidor)

**Ubicación:** `https://paseodelcomercio.com/.well-known/assetlinks.json`

```json
[
  {
    "relation": ["delegate_permission_common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.paseodelcomercio.app",
      "sha256_cert_fingerprints": [
        "21:57:21:64:E3:3F:9F:44:97:74:7A:DF:96:16:65:12:AA:07:B8:4F:D0:D6:82:B3:45:B8:A8:7A:B2:DA:2D:ED"
      ]
    }
  }
]
```

### 3. Keystore Configuration

**Archivo:** `android/app/build.gradle.kts`

```kotlin
// Credenciales desde android/key.properties (archivo local, NO commitear)
val keystoreProperties = java.util.Properties().apply {
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}

signingConfigs {
    create("release") {
        storeFile = file("debug_release.keystore")
        storePassword = keystoreProperties.getProperty("storePassword")
        keyAlias = keystoreProperties.getProperty("keyAlias")
        keyPassword = keystoreProperties.getProperty("keyPassword")
    }
}

buildTypes {
    debug {
        signingConfig = signingConfigs.getByName("release")  // Usa el mismo keystore
    }
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

**Propiedades:** `android/key.properties` (archivo local, NO se commitea)

```
storePassword=<TU_NUEVA_CONTRASEÑA>
keyPassword=<TU_NUEVA_CONTRASEÑA>
keyAlias=my_key
storeFile=debug_release.keystore
```

---

## ARCHIVOS MODIFICADOS

| Archivo | Cambio |
|---------|--------|
| `android/app/src/main/AndroidManifest.xml` | Agregado intent-filter App Links + Custom Scheme, removido Dynamic Links legacy |
| `android/app/build.gradle.kts` | Configurado signing con keystore dedicado para debug y release |
| `android/key.properties` | Variables de keystore (archivo local, NO commit) |
| `android/debug_release.keystore` | Keystore creado (NO commit) |
| `lib/core/routing/app_router.dart` | Agregadas rutas legacy (`/store/:id`, `/producto/:id`, `/plazoleta/:slug`, `/organizacion/:id`) |
| `lib/presentation/pages/plazoletas/plazoleta_detail_page.dart` | Soporte para slug en deep links, `didUpdateWidget` para recarga |
| `lib/presentation/pages/tiendas/tienda_detail_page.dart` | `didUpdateWidget` para recarga en deep links |
| `lib/presentation/pages/productos/producto_detail_page.dart` | `didUpdateWidget` para recarga en deep links |
| `lib/presentation/pages/organizaciones/organizacion_detail_page.dart` | `didUpdateWidget` para recarga en deep links |
| `lib/presentation/blocs/plazoleta/plazoleta_bloc.dart` | Evento `LoadPlazoletaBySlug`, guards para cancelar eventos pendientes |
| `lib/presentation/blocs/plazoleta/plazoleta_event.dart` | Evento `LoadPlazoletaBySlug` |
| `lib/domain/repositories/plazoleta_repository_interface.dart` | Interface `getPlazoletaBySlug` |
| `lib/data/repositories/plazoleta_repository.dart` | Implementación `getPlazoletaBySlug`, guards en queries |

---

## FUNCIONALIDAD IMPLEMENTADA

### Rutas Legacy en GoRouter

```dart
// Legacy: /store/:id -> misma página que /tiendas/:id
GoRoute(
  path: '/store/:id',
  name: 'tienda_detail_legacy',
  pageBuilder: (context, state) {
    final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
    return MaterialPage<void>(
      key: ValueKey('tienda_detail_$id'),
      child: TiendaDetailPage(tiendaId: id),
    );
  },
),

// Legacy: /plazoleta/:slug -> misma página que /plazoletas/:id
GoRoute(
  path: '/plazoleta/:slug',
  name: 'plazoleta_detail_legacy',
  pageBuilder: (context, state) {
    final slug = state.pathParameters['slug'] ?? '';
    return MaterialPage<void>(
      key: ValueKey('plazoleta_detail_slug_$slug'),
      child: PlazoletaDetailPage(plazoletaId: 0, slug: slug),
    );
  },
),
```

### Cancelación de Eventos Pendientes

Para evitar que al navegar rápidamente entre deep links se muestre información incorrecta, se implementó un contador de requests en el BLoC:

```dart
int _loadRequestId = 0;

Future<void> _onLoadPlazoletaBySlug(...) async {
  final requestId = ++_loadRequestId;
  // ... después de cada operación async:
  if (requestId != _loadRequestId) {
    _logger.w('Request cancelled - newer request pending');
    return;
  }
}
```

### didUpdateWidget para Recarga

Las páginas de detalle detectan cambios en parámetros y recargan:

```dart
@override
void didUpdateWidget(TiendaDetailPage oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.tiendaId != widget.tiendaId) {
    _hasLoaded = false;
    _tiendaData = null;
    _productos = [];
    _horarios = [];
    setState(() {});
    _loadTienda();
  }
}
```

---

## NOTAS IMPORTANTES

### Desarrollo vs Producción

| Escenario | Comportamiento |
|-----------|----------------|
| `flutter run` | Requiere agregar manualmente el dominio en "Open by Default" en Settings del dispositivo |
| Play Store (App Signing) | Google habilita App Links automáticamente |

### Limitación Durante Desarrollo

- Al instalar con `flutter run`, Android no auto-verifica App Links
- Se requiere configuración manual una vez por instalación
- Es una limitación de seguridad de Android, no hay manera de evitarla

### Keystore

- El keystore `debug_release.keystore` se usa para **debug** y **release**
- Permite que `flutter run` tenga el mismo SHA256 que release
- **NO commitear** el keystore ni `key.properties` al repositorio

### Firebase Dynamic Links

- Firebase Dynamic Links está **DEPRECATED** (cerró en 2025)
- Se removió el intent-filter de `paseodelcomercio.page.link`
- Solo se usa App Links (`paseodelcomercio.com`)

---

## TESTING

### Testing Manual - Desarrollo

1. `flutter run` para instalar la app
2. Abrir Settings > Apps > Paseo del Comercio > Open by default
3. Agregar `paseodelcomercio.com` si no aparece
4. Probar enlaces:
   - `https://paseodelcomercio.com/plazoleta/organicos`
   - `https://paseodelcomercio.com/store/74`
   - `https://paseodelcomercio.com/producto/258`

### Testing Manual - Producción

1. Subir a Play Store con App Signing
2. Google verificará automáticamente el dominio
3. Usuarios NO necesitan configuración manual

### Verificar assetlinks.json

```bash
curl https://paseodelcomercio.com/.well-known/assetlinks.json
```

### Simular Deep Link (Android)

```bash
adb shell am start -W -a android.intent.action.VIEW \
  -d "https://paseodelcomercio.com/plazoleta/organicos" com.paseodelcomercio.app
```

---

## COMANDOS ÚTILES

```bash
# Obtener SHA256 del keystore (la contraseña NO va en el repo, va en android/key.properties)
keytool -list -v -keystore android/app/debug_release.keystore -alias my_key

# Verificar assetlinks.json
curl -s https://paseodelcomercio.com/.well-known/assetlinks.json | jq

# Reinstalar y probar
flutter uninstall
flutter clean
flutter pub get
flutter run
```

---

## PENDIENTE

- [ ] Testing en dispositivo real con instalación fresca
- [ ] Testing de todos los tipos de deep links
- [ ] Verificar funcionamiento después de subir a Play Store
- [ ] iOS Universal Links (pendiente implementación)

---

**Documento actualizado:** Marzo 2026
**Estado:** COMPLETADO - Pendiente Testing

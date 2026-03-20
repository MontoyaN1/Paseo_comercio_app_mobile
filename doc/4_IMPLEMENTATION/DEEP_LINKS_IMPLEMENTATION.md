# Deep Links Implementation Guide

**Fecha:** Marzo 2026  
**Estado:** PENDIENTE - Para implementar post-launch  
**Objetivo:** Abrir la app directamente desde enlaces compartidos

---

## CONTEXTO

### ¿Qué son Deep Links?
Deep Links permiten que al tocar un enlace como `https://paseodelcomercio.com/store/123`:
1. Si la app está instalada → abre directamente TiendaDetailPage con ID 123
2. Si NO está instalada → abre la página web

### Estado Actual
- Dominio existente: `paseodelcomercio.com` con CloudFlare ✅
- GoRouter configurado con rutas: `/plazoletas/:id`, `/tiendas/:id`, `/productos/:id`, `/organizaciones/:id` ✅
- ShareService genera enlaces web ✅
- **Deep links NO implementados** ❌

---

## OPCIONES DE IMPLEMENTACIÓN

| Opción | Costo | Complejidad | Notas |
|--------|-------|-------------|-------|
| App Links (Android) + Universal Links (iOS) | Gratis | Media-Alta | **Recomendada** |
| Firebase Dynamic Links | - | - | ⚠️ DEPRECATED (cerró en 2025) |
| URL Scheme (`paseo://`) | Gratis | Baja | No tiene fallback a web |

---

## ARQUITECTURA DE DEEP LINKS

### Flujo de un Deep Link

```
Usuario toca enlace
        ↓
Sistema operativo verifica si hay app que maneja el enlace
        ↓
[Android] Google verifica domain ownership → App Links
[iOS] Apple verifica domain ownership → Universal Links
        ↓
App recibe el enlace → GoRouter parsea y navega
```

### Archivos de Verificación Requeridos

| Plataforma | Archivo | Ubicación |
|------------|---------|-----------|
| Android | `assetlinks.json` | `https://paseodelcomercio.com/.well-known/assetlinks.json` |
| iOS | `apple-app-site-association` | `https://paseodelcomercio.com/.well-known/apple-app-site-association` |

---

## PASO 1: CLOUDLFARE / HOSTING

**No se requiere cambiar DNS.** Solo subir archivos al servidor.

### Archivos a crear en el servidor

#### 1.1 assetlinks.json (Android)
```json
[
  {
    "relation": ["delegate_permission_common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.paseodelcomercio.app",
      "sha256_cert_fingerprints": [
        "RELEASE_SHA256_FINGERPRINT",
        "DEBUG_SHA256_FINGERPRINT"
      ]
    }
  }
]
```

**Para obtener las huellas SHA256:**

```bash
# Huella de release (keystore de producción)
keytool -list -v -keystore your-release-keystore.jks -alias your-alias

# Huella de debug (ubicación típica en Linux/macOS)
keytool -list -v -keystore ~/.android/debug.keystore
```

#### 1.2 apple-app-site-association (iOS)
```json
{
  "applinks": {
    "details": [
      {
        "appID": "TEAM_ID.BUNDLE_IDENTIFIER",
        "paths": ["*"]
      }
    ]
  }
}
```

**Para obtener los valores:**
- `TEAM_ID`: Apple Developer Portal → Membership → Team ID
- `BUNDLE_IDENTIFIER`: Proyecto iOS → Runner → General → Bundle Identifier

---

## PASO 2: ANDROID (App Links)

### 2.1 Modificar AndroidManifest.xml

Ubicación: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest ...>
    <application ...>
        <activity ...>
            <!-- App Links - abrir enlaces de paseodelcomercio.com -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="https"
                    android:host="paseodelcomercio.com" />
            </intent-filter>
            
            <!-- Custom Scheme (alternativo, fallback) -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="paseo"
                    android:host="app" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### 2.2 Verificar minSdk

El intent-filter con `autoVerify` requiere **API level 23+** (Android 6.0+).

Verificar en `android/app/build.gradle.kts`:
```kotlin
defaultConfig {
    minSdk = 23  // Asegurar que sea 23 o mayor
}
```

### 2.3 Verificar assetlinks.json

Después de subir `assetlinks.json`, verificar en:
```
https://paseodelcomercio.com/.well-known/assetlinks.json
```

---

## PASO 3: iOS (Universal Links)

### 3.1 Crear archivo entitlements

Crear: `ios/Runner/Runner.entitlements`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:paseodelcomercio.com</string>
    </array>
</dict>
</plist>
```

### 3.2 Modificar Info.plist

Ubicación: `ios/Runner/Info.plist`

```xml
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

### 3.3 Modificar AppDelegate.swift

Ubicación: `ios/Runner/AppDelegate.swift`

```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Handle universal links when app is launched
    if let url = launchOptions?[.url] {
      self.handleDeepLink(url: url)
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // iOS 9.x support
  func application(
    _ application: UIApplication, 
    open url: URL, 
    sourceApplication: String?, 
    annotation: Any
  ) -> Bool {
    return handleDeepLink(url: url)
  }
  
  // iOS 13+ support
  func application(
    _ application: UIApplication, 
    continue userActivity: NSUserActivity, 
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = userActivity.webpageURL else {
      return false
    }
    return handleDeepLink(url: url)
  }
  
  private func handleDeepLink(url: URL) -> Bool {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return false
    }
    // GoRouter maneja la navegación
    let route = url.path
    if !route.isEmpty {
      controller.setInitialRoute(route)
    }
    return true
  }
}
```

### 3.4 Configurar en Xcode

1. Abrir `ios/Runner.xcworkspace` en Xcode
2. Seleccionar target **Runner**
3. Ir a **Signing & Capabilities**
4. Agregar **Associated Domains**
5. Agregar: `applinks:paseodelcomercio.com`

### 3.5 Subir apple-app-site-association

Subir a: `https://paseodelcomercio.com/.well-known/apple-app-site-association`

**Nota:** Este archivo NO tiene extensión `.json`

---

## PASO 4: GOROUTER

### Verificar app_router.dart

El GoRouter actual debería manejar deep links automáticamente si las rutas están definidas correctamente.

Verificar que las rutas usen path parameters:

```dart
// Ejemplo de ruta actual en app_router.dart
GoRoute(
  path: '/tiendas/:id',
  name: 'tienda-detail',
  builder: (context, state) {
    final id = int.parse(state.pathParameters['id']!);
    return TiendaDetailPage(tiendaId: id);
  },
),
```

### Configuración recomendada

```dart
final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [/* ... */],
  // GoRouter maneja deep links automáticamente 
  // cuando la plataforma está configurada correctamente
);
```

---

## PASO 5: TESTING

### Testing Android

```bash
# Instalar APK de release
adb install app-release.apk

# Simular deep link
adb shell am start -W -a android.intent.action.VIEW \
  -d "https://paseodelcomercio.com/tiendas/123" com.paseodelcomercio.app
```

### Testing iOS

1. Abrir Xcode
2. Seleccionar device real (no simulador)
3. Run
4. En Safari del dispositivo, tocar:
   ```
   https://paseodelcomercio.com/tiendas/123
   ```

### Verificación de archivos

Verificar que los archivos de verificación estén accesibles:

```bash
# Android
curl -s https://paseodelcomercio.com/.well-known/assetlinks.json | jq

# iOS  
curl -s https://paseodelcomercio.com/.well-known/apple-app-site-association | jq
```

---

## LINKS QUE FUNCIONARÁN

| Enlace | Ruta | Página |
|--------|------|--------|
| `https://paseodelcomercio.com/` | `/` | PlazoletaListPage |
| `https://paseodelcomercio.com/plazoletas` | `/plazoletas` | PlazoletaListPage |
| `https://paseodelcomercio.com/plazoletas/123` | `/plazoletas/123` | PlazoletaDetailPage |
| `https://paseodelcomercio.com/tiendas/456` | `/tiendas/456` | TiendaDetailPage |
| `https://paseodelcomercio.com/productos/789` | `/productos/789` | ProductoDetailPage |
| `https://paseodelcomercio.com/organizaciones/101` | `/organizaciones/101` | OrganizacionDetailPage |

**Custom scheme (alternativo):**
| Enlace | Ruta |
|--------|------|
| `paseo://app/plazoletas/123` | `/plazoletas/123` |

---

## TIEMPO ESTIMADO

| Componente | Complejidad | Tiempo |
|------------|------------|--------|
| Hosting archivos JSON | Baja | 30 min |
| Android App Links | Media | 2-3 horas |
| iOS Universal Links | Media | 2-3 horas |
| GoRouter | Baja | 1 hora |
| Testing | Media | 2-3 horas |

**Total: 8-12 horas**

---

## ARCHIVOS A MODIFICAR

| Archivo | Cambio |
|---------|--------|
| `android/app/src/main/AndroidManifest.xml` | Agregar intent-filter con autoVerify |
| `android/app/build.gradle.kts` | Verificar minSdk = 23 |
| `ios/Runner/Info.plist` | Agregar FlutterDeepLinkingEnabled |
| `ios/Runner/AppDelegate.swift` | Handle universal links |
| `ios/Runner/Runner.entitlements` | Crear con Associated Domains |
| `pubspec.yaml` | No requiere cambios |

---

## NOTAS IMPORTANTES

1. **HTTPS es obligatorio** - Tanto App Links como Universal Links requieren HTTPS

2. **Los fingerprints SHA cambian** - Cuando generes un nuevo keystore de release, debes actualizar `assetlinks.json`

3. **Testing en dispositivos reales** - Los deep links no funcionan bien en emuladores/simuladores

4. **Auth redirects** - Los redirects de auth en GoRouter seguirán funcionando con deep links

5. **GoRouter v17+** - Maneja deep links nativamente a través de la configuración de plataforma

---

## COMANDOS ÚTILES

```bash
# Obtener fingerprint SHA256 del keystore de debug
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey

# Obtener fingerprint SHA256 del keystore de release
keytool -list -v -keystore path/to/your-release-keystore.jks -alias your-alias

# Verificar archivo assetlinks.json
curl -s https://paseodelcomercio.com/.well-known/assetlinks.json | python3 -m json.tool

# Verificar apple-app-site-association
curl -s https://paseodelcomercio.com/.well-known/apple-app-site-association | python3 -m json.tool
```

---

## REFERENCIAS

- [Android App Links Documentation](https://developer.android.com/training/app-links)
- [iOS Universal Links Documentation](https://developer.apple.com/documentation/xcode/supporting-associated-domains)
- [GoRouter Deep Linking](https://goriverv.dev/--docs/uri-based-routing)
- [Digital Asset Links Tool](https://developers.google.com/digital-asset-links/tools_and_resources)

---

**Documento creado:** Marzo 2026  
**Última actualización:** Marzo 2026  
**Estado:** PENDIENTE - Para implementar post-launch

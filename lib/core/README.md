# Carpeta Core

## Descripción
La carpeta `core` contiene los componentes fundamentales y la infraestructura base de la aplicación. Aquí se encuentran las configuraciones, utilidades, constantes y servicios esenciales que son compartidos por todas las demás capas de la aplicación.

## Estructura

### 📁 `app/`
Contiene la configuración principal de la aplicación, incluyendo la inicialización y configuración global.

### 📁 `config/`
Archivos de configuración para diferentes entornos (desarrollo, producción, testing).

### 📁 `constants/`
Constantes globales de la aplicación como colores, rutas, nombres de tablas, claves de almacenamiento, etc.

### 📁 `errors/`
Definiciones de errores personalizados y manejo de excepciones globales.

### 📁 `localization/`
Configuración de internacionalización (i18n) y localización de la aplicación.

### 📁 `routing/`
Configuración de rutas y navegación de la aplicación.

### 📁 `utils/`
Utilidades y servicios compartidos:
- **`app_utils.dart`**: Utilidades generales de la aplicación
- **`auth_service.dart`**: Servicio de autenticación
- **`cache_service.dart`**: Servicio de caché para datos persistentes
- **`connectivity_service.dart`**: Monitoreo de conectividad a internet
- **`firebase_auth_service.dart`**: Integración con Firebase Authentication
- **`image_service.dart`**: Manejo y procesamiento de imágenes
- **`result.dart`**: Patrón Result para manejo de errores funcional

## Principios de Diseño

1. **Independencia**: Los componentes en `core` no deben depender de otras capas (data, domain, presentation).
2. **Reutilización**: Todos los componentes deben ser genéricos y reutilizables.
3. **Configurabilidad**: Las configuraciones deben ser fácilmente modificables por entorno.
4. **Manejo de Errores**: Errores bien definidos y manejados consistentemente.

## Uso Típico

```dart
// Ejemplo: Uso de servicios core
import 'package:paseo_del_comercio/core/utils/cache_service.dart';
import 'package:paseo_del_comercio/core/utils/connectivity_service.dart';

final cacheService = CacheService();
final connectivityService = ConnectivityService();

// Verificar conectividad
if (await connectivityService.isConnected) {
  // Operaciones que requieren internet
}

// Usar caché
await cacheService.save('key', 'value');
final cachedValue = await cacheService.get('key');
```

## Dependencias
- **Internas**: No depende de otras capas de la aplicación
- **Externas**: Dependencias de Flutter y paquetes de utilidades generales

## Notas Importantes
- Los cambios en esta carpeta pueden afectar a toda la aplicación
- Mantener las interfaces simples y bien documentadas
- Evitar lógica de negocio específica del dominio
- Seguir principios SOLID y clean architecture
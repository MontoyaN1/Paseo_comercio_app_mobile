# Carpeta Data

## Descripción
La carpeta `data` implementa la capa de acceso a datos de la aplicación, siguiendo el patrón Repository. Esta capa es responsable de interactuar con fuentes de datos externas (APIs, bases de datos) e internas (almacenamiento local), transformando los datos en formatos que la capa de dominio pueda consumir.

## Estructura

### 📁 `datasources/`
Contiene las implementaciones concretas para acceder a diferentes fuentes de datos:

#### `datasources/remote/`
- **APIs REST**: Conexión con servicios backend (Supabase, Firebase)
- **Servicios de almacenamiento**: S3, Cloudflare R2 para imágenes
- **Clientes HTTP**: Configuración de clientes para diferentes servicios

#### `datasources/local/`
- **Base de datos local**: Hive, SQLite, o almacenamiento compartido
- **Cache persistente**: Almacenamiento de datos en dispositivo
- **Preferencias de usuario**: Configuraciones guardadas localmente

### 📁 `models/`
Modelos de datos específicos para la capa de datos:
- **DTOs (Data Transfer Objects)**: Representaciones de datos para APIs
- **Modelos de persistencia**: Estructuras para almacenamiento local
- **Mapeadores**: Funciones para convertir entre diferentes representaciones de datos

### 📁 `repositories/`
Implementaciones concretas de los repositorios definidos en la capa de dominio:
- **Repositorios por entidad**: `AuthRepository`, `TiendaRepository`, `ProductoRepository`, etc.
- **Implementación de interfaces**: Cada repositorio implementa una interfaz de la capa de dominio
- **Coordinación de fuentes**: Decide qué fuente de datos usar (cache local vs remoto)

## Principios de Diseño

1. **Separación de responsabilidades**: Cada repositorio maneja una entidad específica
2. **Patrón Repository**: Abstracción del acceso a datos detrás de interfaces
3. **Caching estratégico**: Implementación inteligente de caché para mejorar rendimiento
4. **Manejo de errores**: Transformación de errores de infraestructura a errores de dominio
5. **Offline-first**: Soporte para operaciones sin conexión cuando sea posible

## Flujo de Datos Típico

```
UI/Bloc → UseCase → Repository Interface → Repository Implementation → DataSource
```

## Implementación de Repositorios

Cada repositorio típicamente:

1. **Verifica conectividad**: Usa `ConnectivityService`
2. **Consulta caché local**: Usa `CacheService` o `LocalCacheService`
3. **Si es necesario, consulta remoto**: Usa clientes HTTP o SDKs específicos
4. **Actualiza caché**: Guarda datos frescos localmente
5. **Transforma datos**: Convierte DTOs a entidades de dominio
6. **Retorna resultado**: Usa el patrón `Result` o `Either`

## Ejemplo de Uso

```dart
// Ejemplo: Repositorio de Tiendas
class TiendaRepository implements TiendaRepositoryInterface {
  final SupabaseClientService supabaseClient;
  final LocalCacheService localCache;
  final ConnectivityService connectivityService;
  final CacheService cacheService;

  TiendaRepository({
    required this.supabaseClient,
    required this.localCache,
    required this.connectivityService,
    required this.cacheService,
  });

  @override
  Future<Result<List<Tienda>>> getTiendas() async {
    try {
      // Verificar si hay datos en caché
      final cachedData = await cacheService.get('tiendas');
      if (cachedData != null) {
        return Result.success(cachedData);
      }

      // Verificar conectividad
      if (!await connectivityService.isConnected) {
        return Result.failure(NetworkFailure());
      }

      // Obtener datos remotos
      final response = await supabaseClient.getTiendas();
      
      // Transformar DTOs a entidades
      final tiendas = response.map((dto) => dto.toEntity()).toList();
      
      // Actualizar caché
      await cacheService.save('tiendas', tiendas);
      
      return Result.success(tiendas);
    } catch (e) {
      return Result.failure(DataFailure(message: e.toString()));
    }
  }
}
```

## Dependencias

### Internas
- **Core**: Utilidades, servicios de conectividad y caché
- **Domain**: Interfaces de repositorios y entidades

### Externas
- **Supabase**: `supabase_flutter` para backend
- **Firebase**: `firebase_auth`, `cloud_firestore`, `firebase_storage`
- **Almacenamiento local**: `hive`, `flutter_secure_storage`
- **Networking**: `dio`, `http`

## Configuración

### Variables de Entorno
Los repositorios suelen requerir configuración a través de:
- Claves de API
- URLs de endpoints
- Configuraciones de buckets de almacenamiento

### Inicialización
Los repositorios se inicializan en `service_locator.dart` y se inyectan como dependencias.

## Testing

### Estrategias
1. **Unit tests**: Testear lógica de repositorios con mocks
2. **Integration tests**: Testear integración con APIs reales (entornos de staging)
3. **Mocking**: Usar `Mockito` o similares para simular dependencias

### Consideraciones
- Testear diferentes estados de conectividad
- Verificar estrategias de caché
- Validar transformación de datos

## Notas Importantes

1. **No exponer detalles de implementación**: Los consumidores solo ven las interfaces
2. **Manejo de versiones**: Considerar migraciones de esquemas de datos
3. **Seguridad**: Nunca hardcodear credenciales
4. **Performance**: Implementar paginación para grandes conjuntos de datos
5. **Observabilidad**: Agregar logging para debugging de problemas de datos

## Repositorios Actuales

- `AuthRepository`: Autenticación de usuarios
- `TiendaRepository`: Gestión de tiendas del centro comercial
- `PlazoletaRepository`: Información de plazoletas/áreas comunes
- `ProductoRepository`: Catálogo de productos
- `OrganizacionRepository`: Información organizacional

## Extensiones Futuras

1. **Sincronización offline**: Mejor soporte para operaciones sin conexión
2. **Background sync**: Sincronización en segundo plano
3. **Data validation**: Validación más robusta de datos entrantes
4. **Analytics**: Tracking de operaciones de datos para análisis
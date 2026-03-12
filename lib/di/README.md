# Carpeta DI (Dependency Injection)

## Descripción
La carpeta `di` (Dependency Injection) contiene la configuración del contenedor de inyección de dependencias de la aplicación. Utiliza el patrón Service Locator con `get_it` para gestionar la creación, configuración y resolución de dependencias a lo largo de toda la aplicación.

## Estructura

### 📄 `service_locator.dart`
Archivo principal que configura todas las dependencias de la aplicación:

1. **Registro de servicios**: Configuración de servicios singleton y lazy
2. **Inicialización**: Setup asíncrono de servicios que requieren inicialización
3. **Resolución**: Funciones helper para obtener instancias de servicios
4. **Lifecycle management**: Gestión del ciclo de vida de las dependencias

## Principios de Diseño

1. **Inversión de dependencias**: Depender de abstracciones, no de implementaciones concretas
2. **Single Responsibility**: Cada servicio tiene una responsabilidad clara
3. **Testabilidad**: Facilita el mocking para pruebas unitarias
4. **Modularidad**: Dependencias organizadas por capa y responsabilidad
5. **Lifecycle awareness**: Gestión apropiada del ciclo de vida de cada servicio

## Configuración de Dependencias

### Tipos de Registro

```dart
// Singleton: Una única instancia compartida
getIt.registerSingleton<AppConfig>(appConfig);

// Lazy Singleton: Se crea solo cuando se necesita por primera vez
getIt.registerLazySingleton<TiendaRepositoryInterface>(
  () => TiendaRepository(
    supabaseClient: getIt<SupabaseClientService>(),
    localCache: getIt<LocalCacheService>(),
  ),
);

// Factory: Nueva instancia cada vez que se resuelve
getIt.registerFactory<SomeService>(() => SomeService());
```

### Orden de Registro
1. **Configuración y utilidades base**
2. **Servicios de infraestructura** (conectividad, caché, etc.)
3. **Clientes externos** (Supabase, Firebase, S3)
4. **Repositorios**
5. **Casos de uso**
6. **BLoCs/Controladores**

## Uso Típico

### Inicialización
```dart
// En main.dart o punto de entrada de la aplicación
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar configuración
  final appConfig = await loadAppConfig();
  
  // Configurar inyección de dependencias
  await setupServiceLocator(appConfig);
  
  runApp(MyApp());
}
```

### Resolución de Dependencias
```dart
// Obtener una instancia de servicio
final authService = getIt<AuthService>();
final tiendaRepository = getIt<TiendaRepositoryInterface>();

// Usar en BLoCs o widgets
class TiendaBloc extends Bloc<TiendaEvent, TiendaState> {
  final GetTiendasUseCase getTiendasUseCase;
  
  TiendaBloc()
      : getTiendasUseCase = getIt<GetTiendasUseCase>(),
        super(TiendaInitial());
}
```

### Funciones Helper
```dart
// Obtener servicio con función helper
T getService<T extends Object>() {
  return getIt.get<T>();
}

// Verificar si un servicio está registrado
bool isServiceRegistered<T extends Object>() {
  return getIt.isRegistered<T>();
}
```

## Servicios Configurados

### Core Services
- `AppConfig`: Configuración de la aplicación
- `ConnectivityService`: Monitoreo de conectividad
- `CacheService`: Servicio de caché en memoria
- `ImageService`: Procesamiento de imágenes
- `FirebaseAuthService`: Autenticación con Firebase

### Data Services
- `SupabaseClientService`: Cliente para Supabase
- `LocalCacheService`: Base de datos local
- `S3ImageService`: Servicio para S3 (si está configurado)

### Repositories
- `AuthRepositoryInterface` → `AuthRepository`
- `TiendaRepositoryInterface` → `TiendaRepository`
- `PlazoletaRepositoryInterface` → `PlazoletaRepository`
- `ProductoRepositoryInterface` → `ProductoRepository`
- `OrganizacionRepositoryInterface` → `OrganizacionRepository`

### Use Cases
- `GetTiendasUseCase`: Obtener lista de tiendas
- `GetTiendaByIdUseCase`: Obtener tienda por ID
- `SearchTiendasUseCase`: Buscar tiendas
- `AuthenticateUserUseCase`: Autenticar usuario
- `GetProductosUseCase`: Obtener productos
- `GetProductoByIdUseCase`: Obtener producto por ID

### BLoCs
- `AuthBloc`: Gestión de autenticación
- `TiendaBloc`: Gestión de tiendas
- `PlazoletaBloc`: Gestión de plazoletas
- `ProductoBloc`: Gestión de productos
- `ImageBloc`: Gestión de imágenes
- `OrganizacionBloc`: Gestión organizacional

## Testing

### Configuración para Tests
```dart
// En setUp de tests
await setupServiceLocator(testConfig);

// En tearDown de tests
await resetServiceLocator();
```

### Mocking de Dependencias
```dart
// Registrar mocks en lugar de implementaciones reales
getIt.registerSingleton<AuthRepositoryInterface>(MockAuthRepository());
```

## Consideraciones de Performance

1. **Lazy loading**: Usar `registerLazySingleton` para servicios costosos
2. **Async initialization**: Servicios que requieren inicialización asíncrona
3. **Memory management**: Limpiar servicios que ya no se necesitan
4. **Dependency graph**: Evitar ciclos de dependencias

## Seguridad

1. **Configuración sensible**: Las credenciales se cargan desde variables de entorno
2. **Validación**: Verificar que los servicios estén configurados correctamente
3. **Error handling**: Manejo apropiado de errores de inicialización

## Extensibilidad

### Agregar Nuevos Servicios
1. Crear la implementación del servicio
2. Definir interfaz si es necesario (para inversión de dependencias)
3. Registrar en `service_locator.dart`
4. Inyectar donde se necesite

### Modularización
Para aplicaciones grandes, considerar:
- Múltiples archivos de configuración por módulo
- Registro condicional basado en flags de feature
- Plugins o módulos intercambiables

## Troubleshooting

### Problemas Comunes
1. **Service not registered**: Verificar orden de inicialización
2. **Circular dependencies**: Revisar el gráfico de dependencias
3. **Async initialization**: Asegurar que `await setupServiceLocator()` se complete
4. **Testing issues**: Resetear el service locator entre tests

### Debugging
```dart
// Verificar si un servicio está registrado
print('AuthService registrado: ${getIt.isRegistered<AuthService>()}');

// Listar todos los servicios registrados (debug only)
getIt.registeredServices.forEach((key, value) {
  print('$key: ${value.instance}');
});
```

## Mejores Prácticas

1. **Siempre usar interfaces** para servicios que puedan tener múltiples implementaciones
2. **Minimizar dependencias globales** cuando sea posible
3. **Documentar dependencias** de cada servicio
4. **Mantener `service_locator.dart` organizado** por capas
5. **Versionar cambios** en la configuración de DI

## Notas de Mantenimiento

- Actualizar este README cuando se agreguen nuevos servicios
- Revisar periódicamente el gráfico de dependencias
- Considerar migrar a `injectable` o `get_it` con codegen para proyectos grandes
- Mantener compatibilidad con versiones anteriores al modificar servicios existentes
# Carpeta Presentation

## Descripción
La carpeta `presentation` contiene la capa de interfaz de usuario y gestión de estado de la aplicación. Esta capa es responsable de mostrar datos al usuario, capturar interacciones y gestionar el estado de la UI, siguiendo el patrón BLoC (Business Logic Component) para separar la lógica de presentación de los widgets de UI.

## Estructura

### 📁 `blocs/`
Contiene los BLoCs (Business Logic Components) que gestionan el estado de la aplicación:

- **`auth/`**: Gestión de estado para autenticación (login, registro, sesión)
- **`tienda/`**: Gestión de estado para operaciones con tiendas
- **`producto/`**: Gestión de estado para operaciones con productos
- **`plazoleta/`**: Gestión de estado para información de plazoletas
- **`image/`**: Gestión de estado para carga y procesamiento de imágenes
- **`organizacion/`**: Gestión de estado para información organizacional

Cada BLoC sigue el patrón Event-State:
- **Events**: Acciones que el usuario o el sistema pueden disparar
- **States**: Representaciones del estado actual de la UI
- **Bloc**: Lógica para transformar eventos en estados

### 📁 `pages/`
Contiene las pantallas principales de la aplicación:

- **Pantallas de autenticación**: Login, registro, recuperación de contraseña
- **Pantallas principales**: Home, exploración, búsqueda, perfil
- **Pantallas de detalle**: Detalle de tienda, detalle de producto, carrito
- **Pantallas de administración**: Gestión de contenido (si aplica)

Cada página:
- Es un widget `StatelessWidget` o `StatefulWidget`
- Consume BLoCs a través de `BlocBuilder` o `BlocListener`
- Sigue principios de diseño responsivo
- Implementa navegación a través de `GoRouter`

### 📁 `widgets/`
Contiene componentes UI reutilizables:

- **Widgets de formulario**: Inputs, botones, validadores
- **Widgets de lista**: Item de tienda, item de producto, grids
- **Widgets de navegación**: AppBar personalizado, bottom navigation
- **Widgets de estado**: Loaders, empty states, error states
- **Widgets específicos**: Tarjetas de tienda, carruseles, modales

Cada widget:
- Es reutilizable y configurable
- Sigue los principios de composición de Flutter
- Puede consumir BLoCs si necesita gestión de estado
- Sigue la guía de estilos de la aplicación

## Principios de Diseño

### 1. Separación de Preocupaciones
- **UI vs Lógica**: Los widgets solo manejan UI, la lógica está en BLoCs
- **Stateless cuando sea posible**: Preferir widgets inmutables
- **Composición**: Construir interfaces complejas con widgets simples

### 2. Patrón BLoC
```
UI → Event → Bloc → State → UI
```
- Los widgets despachan eventos
- Los BLoCs procesan eventos y emiten nuevos estados
- Los widgets se reconstruyen con nuevos estados

### 3. Reactividad
- Flujos de datos unidireccionales
- Estados inmutables
- Reconstrucción eficiente de UI

### 4. Responsividad
- Diseño adaptable a diferentes tamaños de pantalla
- Soporte para orientación portrait y landscape
- Consideración de diferentes dispositivos (móvil, tablet)

## Implementación Típica

### Estructura de un BLoC
```dart
// events/tienda_event.dart
abstract class TiendaEvent extends Equatable {
  const TiendaEvent();
}

class LoadTiendasEvent extends TiendaEvent {
  @override
  List<Object> get props => [];
}

class SearchTiendasEvent extends TiendaEvent {
  final String query;
  
  const SearchTiendasEvent(this.query);
  
  @override
  List<Object> get props => [query];
}

// states/tienda_state.dart
class TiendaState extends Equatable {
  final List<Tienda> tiendas;
  final bool loading;
  final String? error;
  final String? searchQuery;
  
  const TiendaState({
    this.tiendas = const [],
    this.loading = false,
    this.error,
    this.searchQuery,
  });
  
  // Estados derivados
  TiendaState copyWith({
    List<Tienda>? tiendas,
    bool? loading,
    String? error,
    String? searchQuery,
  }) {
    return TiendaState(
      tiendas: tiendas ?? this.tiendas,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
  
  @override
  List<Object?> get props => [tiendas, loading, error, searchQuery];
}

// tienda_bloc.dart
class TiendaBloc extends Bloc<TiendaEvent, TiendaState> {
  final GetTiendasUseCase getTiendasUseCase;
  final GetTiendaByIdUseCase getTiendaByIdUseCase;
  final SearchTiendasUseCase searchTiendasUseCase;
  
  TiendaBloc({
    required this.getTiendasUseCase,
    required this.getTiendaByIdUseCase,
    required this.searchTiendasUseCase,
  }) : super(const TiendaState()) {
    on<LoadTiendasEvent>(_onLoadTiendas);
    on<SearchTiendasEvent>(_onSearchTiendas);
  }
  
  Future<void> _onLoadTiendas(
    LoadTiendasEvent event,
    Emitter<TiendaState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    
    final result = await getTiendasUseCase.execute();
    
    result.fold(
      (failure) => emit(state.copyWith(
        loading: false,
        error: failure.message,
      )),
      (tiendas) => emit(state.copyWith(
        loading: false,
        tiendas: tiendas,
        error: null,
      )),
    );
  }
  
  Future<void> _onSearchTiendas(
    SearchTiendasEvent event,
    Emitter<TiendaState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(LoadTiendasEvent());
      return;
    }
    
    emit(state.copyWith(
      loading: true,
      searchQuery: event.query,
    ));
    
    final result = await searchTiendasUseCase.execute(event.query);
    
    result.fold(
      (failure) => emit(state.copyWith(
        loading: false,
        error: failure.message,
      )),
      (tiendas) => emit(state.copyWith(
        loading: false,
        tiendas: tiendas,
        error: null,
      )),
    );
  }
}
```

### Consumo en Widgets
```dart
class TiendasPage extends StatelessWidget {
  const TiendasPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiendas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navegar a pantalla de búsqueda
              context.go('/tiendas/search');
            },
          ),
        ],
      ),
      body: BlocBuilder<TiendaBloc, TiendaState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state.error != null) {
            return ErrorWidget(
              message: state.error!,
              onRetry: () {
                context.read<TiendaBloc>().add(LoadTiendasEvent());
              },
            );
          }
          
          if (state.tiendas.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.store,
              message: 'No hay tiendas disponibles',
            );
          }
          
          return TiendaListView(tiendas: state.tiendas);
        },
      ),
    );
  }
}
```

## Navegación

### Configuración con GoRouter
```dart
// En core/routing/app_router.dart
final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/tiendas',
      builder: (context, state) => const TiendasPage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return TiendaDetailPage(tiendaId: id);
          },
        ),
      ],
    ),
  ],
);
```

### Navegación en Widgets
```dart
// Navegación simple
context.go('/tiendas/123');

// Navegación con parámetros
context.go('/tiendas/123', extra: {'from': 'home'});

// Navegación con query parameters
context.go('/search', queryParameters: {'q': 'ropa'});
```

## Temas y Estilos

### Tema Global
```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.blue,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
      fontFamily: 'Poppins',
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Poppins',
    );
  }
}
```

### Widgets con Tema
```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        textStyle: theme.textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text),
    );
  }
}
```

## Testing

### Testing de BLoCs
```dart
void main() {
  group('TiendaBloc', () {
    late MockGetTiendasUseCase mockGetTiendasUseCase;
    late TiendaBloc tiendaBloc;
    
    setUp(() {
      mockGetTiendasUseCase = MockGetTiendasUseCase();
      tiendaBloc = TiendaBloc(
        getTiendasUseCase: mockGetTiendasUseCase,
        getTiendaByIdUseCase: MockGetTiendaByIdUseCase(),
        searchTiendasUseCase: MockSearchTiendasUseCase(),
      );
    });
    
    tearDown(() {
      tiendaBloc.close();
    });
    
    test('initial state is TiendaState', () {
      expect(tiendaBloc.state, equals(const TiendaState()));
    });
    
    blocTest<TiendaBloc, TiendaState>(
      'emits [loading, success] when LoadTiendasEvent is added',
      build: () {
        when(mockGetTiendasUseCase.execute())
          .thenAnswer((_) async => const Right([]));
        return tiendaBloc;
      },
      act: (bloc) => bloc.add(LoadTiendasEvent()),
      expect: () => [
        const TiendaState(loading: true),
        const TiendaState(loading: false, tiendas: []),
      ],
    );
  });
}
```

### Testing de Widgets
```dart
void main() {
  testWidgets('TiendasPage shows loading state', (tester) async {
    final mockBloc = MockTiendaBloc();
    
    when(mockBloc.state).thenReturn(const TiendaState(loading: true));
    when(mockBloc.stream).thenAnswer((_) => Stream.value(
      const TiendaState(loading: true),
    ));
    
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: mockBloc,
          child: const TiendasPage(),
        ),
      ),
    );
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

## Mejores Prácticas

### 1. Gestión de Estado
- Usar `BlocProvider` para proporcionar BLoCs
- Preferir `BlocBuilder` sobre `BlocListener` para reconstrucción
- Usar `BlocConsumer` cuando necesites ambos
- Limpiar recursos en `dispose` cuando sea necesario

### 2. Performance
- Usar `const` constructors para widgets estáticos
- Implementar `AutomaticKeepAliveClientMixin` para páginas costosas
- Usar `ListView.builder` para listas largas
- Implementar debouncing para búsquedas

### 3. Responsividad
- Usar `LayoutBuilder` para adaptar diseño
- Considerar `MediaQuery` para breakpoints
- Probar en diferentes tamaños de pantalla
- Soporte para accesibilidad

### 4. Mantenibilidad
- Separar widgets grandes en widgets más pequeños
- Documentar props complejas
- Seguir convenciones de naming
- Mantener coherencia en estilos

## Integración con Otras Capas

### Con Domain
```dart
// Los BLoCs consumen casos de uso
final result = await getTiendasUseCase.execute();

// Los widgets consumen entidades de dominio
TiendaCard(tienda: state.tiendas[0]);
```

### Con DI
```dart
// Los BLoCs se obtienen del service locator
final tiendaBloc = getIt<TiendaBloc>();

// O se proporcionan via BlocProvider
BlocProvider(
  create: (context) => getIt<TiendaBloc>(),
  child: const TiendasPage(),
);
```

## BLoCs Actuales

### AuthBloc
- Maneja autenticación de usuarios
- Estados: Unauthenticated, Authenticated, Loading, Error
- Eventos: Login, Logout, CheckSession

### TiendaBloc
- Maneja operaciones con tiendas
- Estados: Lista de tiendas, loading, error, búsqueda
- Eventos: LoadTiendas, SearchTiendas, SelectTienda

### ProductoBloc
- Maneja operaciones con productos
- Estados: Lista de productos, filtros, paginación
- Eventos: LoadProductos, FilterProductos, LoadMore

### ImageBloc
- Maneja carga y procesamiento de imágenes
- Estados: Uploading, Uploaded, Error, Processing
- Eventos: UploadImage, ProcessImage, DeleteImage

## Consideraciones de Seguridad

### Input Validation
- Validar inputs en el cliente
- Sanitizar datos antes de enviar al backend
- Mostrar errores de validación claros

### Gestión de Sesiones
- No almacenar tokens en widgets
- Usar servicios de autenticación centralizados
- Implementar logout automático por inactividad

### Protección de UI
- Ocultar funcionalidades basado en permisos
- Mostrar placeholders para datos sensibles
- Validar permisos antes de acciones críticas

## Extensibilidad

### Agregar Nueva Pantalla
1. Crear página en `pages/`
2. Crear BLoC en `blocs/` si necesita estado complejo
3. Crear widgets específicos en `widgets/`
4. Configurar ruta en `app_router.dart`
5. Proporcionar BLoC via `BlocProvider`

### Agregar Nuevo BLoC
1. Definir eventos en `events/`
2. Definir estados en `states/`
3. Implementar lógica en `bloc.dart`
4. Registrar en `service_locator.dart`
5. Proporcionar donde se necesite

## Troubleshooting

### Problemas Comunes
1. **Widget no se reconstruye**: Verificar `BlocBuilder` vs `BlocListener`
2. **Estado inconsistente**: Revisar inmutabilidad del estado
3. **Memory leaks**: Asegurar que los BLoCs se cierren
4. **Performance issues**: Revisar reconstrucciones innecesarias

### Debugging
```dart
// Activar logging de BLoC
Bloc.observer = SimpleBlocObserver();

// Verificar estado actual
print('Current state: ${bloc.state}');

// Verificar stream de estados
bloc.stream.listen((state) {
  print('State changed: $state');
});
```

## Recursos Adicionales

### Documentación Oficial
- [Flutter BLoC Library](https://bloclibrary.dev/)
- [GoRouter](https://gorouter.dev/)
- [Flutter Widgets](https://flutter.dev/docs/development/ui/widgets)

### Patrones Relacionados
- **MVVM**: Model-View-ViewModel
- **Provider**: Patrón de inyección de dependencias
- **Riverpod**: Alternativa a Provider

### Herramientas
- **Flutter DevTools**: Para profiling y debugging
- **BLoC Concurrency**: Para manejo de eventos concurrentes
- **Freezed**: Para generar código boilerplate
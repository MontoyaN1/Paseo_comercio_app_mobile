# Carpeta Domain

## Descripción
La carpeta `domain` representa la capa de dominio de la aplicación, que contiene la lógica de negocio central y las reglas empresariales. Esta capa es independiente de frameworks, bibliotecas externas y detalles de implementación, siguiendo los principios de Clean Architecture.

## Estructura

### 📁 `entities/`
Contiene las entidades de dominio que representan los conceptos fundamentales del negocio:

- **Tienda**: Representa una tienda del centro comercial virtual
- **Producto**: Representa un producto disponible en las tiendas
- **Plazoleta**: Representa un área o sección del centro comercial
- **Organizacion**: Información organizacional del centro comercial
- **Usuario**: Información del usuario autenticado

Cada entidad:
- Es inmutable cuando sea posible
- Contiene validaciones de negocio
- Define igualdad basada en identidad (usando `Equatable`)
- No tiene dependencias externas

### 📁 `failures/`
Define los tipos de fallos específicos del dominio:

- **AuthFailure**: Fallos relacionados con autenticación
- **DataFailure**: Fallos relacionados con acceso a datos
- **NetworkFailure**: Fallos de conectividad
- **ValidationFailure**: Fallos de validación de datos
- **UnexpectedFailure**: Fallos inesperados del sistema

Cada fallo:
- Extiende `Failure` o `Equatable`
- Contiene mensajes descriptivos
- Puede incluir códigos de error específicos
- Es serializable para logging

### 📁 `repositories/`
Contiene las interfaces abstractas de los repositorios:

- **AuthRepositoryInterface**: Operaciones de autenticación
- **TiendaRepositoryInterface**: Operaciones con tiendas
- **ProductoRepositoryInterface**: Operaciones con productos
- **PlazoletaRepositoryInterface**: Operaciones con plazoletas
- **OrganizacionRepositoryInterface**: Operaciones organizacionales

Cada interfaz:
- Define el contrato para la capa de datos
- Usa entidades de dominio en sus firmas
- Retorna `Future<Result<T>>` o `Future<Either<Failure, T>>`
- Es independiente de detalles de implementación

### 📁 `usecases/`
Contiene los casos de uso que encapsulan operaciones específicas de negocio:

- **GetTiendasUseCase**: Obtener lista de tiendas
- **GetTiendaByIdUseCase**: Obtener tienda por ID
- **SearchTiendasUseCase**: Buscar tiendas por criterios
- **AuthenticateUserUseCase**: Autenticar usuario
- **GetProductosUseCase**: Obtener lista de productos
- **GetProductoByIdUseCase**: Obtener producto por ID

Cada caso de uso:
- Implementa una operación atómica de negocio
- Depende solo de interfaces de repositorio
- Maneja errores de dominio
- Puede incluir lógica de validación

## Principios de Diseño

### 1. Independencia
- No depende de frameworks externos
- No contiene imports de `flutter` u otras bibliotecas específicas
- Las entidades son POCOs (Plain Old Dart Objects)

### 2. Inmutabilidad
- Las entidades son inmutables cuando sea posible
- Usa `copyWith` para crear variaciones
- Evita efectos secundarios

### 3. Validación de Negocio
- Las reglas de negocio se validan en las entidades
- Los casos de uso aplican validaciones adicionales
- Los fallos específicos indican violaciones de reglas

### 4. Abstracción
- Depende de abstracciones (interfaces), no de implementaciones
- Las interfaces definen contratos claros
- Facilita testing y sustitución de implementaciones

## Ejemplos de Implementación

### Entidad de Dominio
```dart
class Tienda extends Equatable {
  final String id;
  final String nombre;
  final String descripcion;
  final String? logoUrl;
  final List<String> categorias;
  final bool activa;
  final DateTime fechaCreacion;

  const Tienda({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.logoUrl,
    required this.categorias,
    required this.activa,
    required this.fechaCreacion,
  });

  Tienda copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? logoUrl,
    List<String>? categorias,
    bool? activa,
    DateTime? fechaCreacion,
  }) {
    return Tienda(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      logoUrl: logoUrl ?? this.logoUrl,
      categorias: categorias ?? this.categorias,
      activa: activa ?? this.activa,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  bool get tieneLogo => logoUrl != null && logoUrl!.isNotEmpty;
  
  bool perteneceACategoria(String categoria) {
    return categorias.contains(categoria);
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    descripcion,
    logoUrl,
    categorias,
    activa,
    fechaCreacion,
  ];
}
```

### Interfaz de Repositorio
```dart
abstract class TiendaRepositoryInterface {
  Future<Result<List<Tienda>>> getTiendas();
  Future<Result<Tienda>> getTiendaById(String id);
  Future<Result<List<Tienda>>> searchTiendas(String query);
  Future<Result<List<Tienda>>> getTiendasPorCategoria(String categoria);
}
```

### Caso de Uso
```dart
class GetTiendasUseCase {
  final TiendaRepositoryInterface repository;

  GetTiendasUseCase(this.repository);

  Future<Result<List<Tienda>>> execute() async {
    try {
      final result = await repository.getTiendas();
      
      // Aplicar lógica de negocio adicional si es necesario
      return result.map((tiendas) => 
        tiendas.where((tienda) => tienda.activa).toList()
      );
    } catch (e) {
      return Result.failure(UnexpectedFailure(
        message: 'Error al obtener tiendas: ${e.toString()}'
      ));
    }
  }
}
```

### Fallo de Dominio
```dart
class ValidationFailure extends Failure {
  final String field;
  final String validationMessage;

  const ValidationFailure({
    required this.field,
    required this.validationMessage,
  });

  @override
  String get message => 'Error de validación en $field: $validationMessage';

  @override
  List<Object> get props => [field, validationMessage];
}
```

## Flujo de Datos

```
Presentation Layer → Use Case → Repository Interface → Data Layer
      (UI/Bloc)      (Domain)        (Domain)          (Data)
```

## Testing

### Estrategias de Testing
1. **Unit tests para entidades**: Verificar validaciones y lógica de negocio
2. **Unit tests para casos de uso**: Mockear repositorios y testear lógica
3. **Contract tests**: Verificar que las implementaciones cumplan con las interfaces

### Ejemplo de Test
```dart
void main() {
  group('Tienda Entity', () {
    test('debe crear una tienda válida', () {
      final tienda = Tienda(
        id: '1',
        nombre: 'Tienda Ejemplo',
        descripcion: 'Descripción',
        categorias: ['ropa', 'accesorios'],
        activa: true,
        fechaCreacion: DateTime.now(),
      );
      
      expect(tienda.id, '1');
      expect(tienda.nombre, 'Tienda Ejemplo');
      expect(tienda.activa, true);
    });

    test('debe verificar si tiene logo', () {
      final tiendaConLogo = Tienda(
        id: '1',
        nombre: 'Tienda',
        descripcion: 'Desc',
        logoUrl: 'https://example.com/logo.jpg',
        categorias: [],
        activa: true,
        fechaCreacion: DateTime.now(),
      );
      
      final tiendaSinLogo = Tienda(
        id: '2',
        nombre: 'Tienda 2',
        descripcion: 'Desc 2',
        logoUrl: null,
        categorias: [],
        activa: true,
        fechaCreacion: DateTime.now(),
      );
      
      expect(tiendaConLogo.tieneLogo, true);
      expect(tiendaSinLogo.tieneLogo, false);
    });
  });
}
```

## Dependencias

### Internas
- **Ninguna dependencia de otras capas**
- Solo depende de paquetes de utilidades generales como `equatable`

### Externas
- `equatable`: Para igualdad basada en valor
- `dartz`: Para programación funcional (opcional, si se usa `Either`)

## Reglas de Negocio Actuales

### Para Tiendas
1. Una tienda debe tener nombre y descripción no vacíos
2. Solo las tiendas activas deben mostrarse en listados públicos
3. Las categorías deben ser una lista no vacía

### Para Productos
1. El precio debe ser positivo
2. El stock no puede ser negativo
3. Productos descontinuados no deben mostrarse como disponibles

### Para Autenticación
1. Las credenciales deben cumplir con políticas de seguridad
2. Sesiones expiradas requieren reautenticación
3. Accesos fallidos múltiples activan bloqueos temporales

## Extensibilidad

### Agregar Nueva Entidad
1. Crear clase en `entities/` con validaciones de negocio
2. Definir fallos relacionados en `failures/` si es necesario
3. Crear interfaz de repositorio en `repositories/`
4. Implementar casos de uso en `usecases/`

### Modificar Reglas de Negocio
1. Actualizar validaciones en entidades
2. Modificar casos de uso si afecta operaciones
3. Actualizar tests para reflejar cambios
4. Documentar cambios en este README

## Mejores Prácticas

1. **Mantener la pureza**: El dominio no debe tener efectos secundarios
2. **Validar temprano**: Las entidades deben ser válidas al crearse
3. **Usar value objects**: Para conceptos complejos como Email, Precio, etc.
4. **Documentar reglas**: Comentar por qué existen ciertas validaciones
5. **Testear exhaustivamente**: El dominio es el corazón de la aplicación

## Notas de Mantenimiento

- Revisar periódicamente si las reglas de negocio siguen siendo válidas
- Considerar extraer value objects para conceptos reutilizables
- Mantener coherencia en el naming de métodos y propiedades
- Actualizar documentación cuando se agreguen nuevas funcionalidades
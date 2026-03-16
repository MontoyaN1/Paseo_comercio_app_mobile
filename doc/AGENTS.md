# AGENTS.md - Paseo del Comercio App

This file contains essential information for AI agents working on this Flutter project.

## 📱 Project Overview

**Name:** Paseo del Comercio - Mobile Application  
**Platform:** Flutter (iOS, Android, Web)  
**Architecture:** Clean Architecture with 4 layers  
**State Management:** BLoC Pattern  
**Database:** Supabase PostgreSQL + Hive local cache  
**Authentication:** Firebase Auth + Google Sign In  
**Image Storage:** Cloudflare R2 (primary) + Contabo S3 + Supabase Storage

## 🚀 Build & Development Commands

### Essential Commands
```bash
# Install dependencies
flutter pub get

# Run the application
flutter run

# Run on specific device
flutter run -d chrome          # Web
flutter run -d android         # Android
flutter run -d ios             # iOS (macOS only)

# Build for release
flutter build apk --release    # Android APK
flutter build appbundle        # Android App Bundle
flutter build ios --release    # iOS (macOS only)
flutter build web --release    # Web

# Code generation (Hive models)
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch   # Watch mode for development
```

### Code Quality & Analysis
```bash
# Analyze code for errors and warnings
flutter analyze

# Format all Dart code
flutter format .

# Format specific directory
flutter format lib/

# Check formatting without applying changes
flutter format --dry-run .

# Run static analysis with custom rules
flutter analyze --fatal-infos   # Treat infos as errors
```

### Testing Commands
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage

# Run tests in watch mode
flutter test --watch

# Run tests with specific tags
flutter test --tags integration
flutter test --tags unit

# Run tests with specific name pattern
flutter test --name "Counter increments"

# Debug tests
flutter test --start-paused
```

### Development Utilities
```bash
# Clean build artifacts
flutter clean

# Upgrade Flutter and packages
flutter upgrade
flutter pub upgrade --major-versions

# Check for outdated packages
flutter pub outdated

# Generate launcher icons
flutter pub run flutter_launcher_icons:main

# Setup project (run initial configuration)
./setup.sh
```

## 🏗️ Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── app/                # App configuration
│   ├── config/             # Configuration files
│   ├── constants/          # App constants
│   ├── errors/             # Error handling
│   ├── localization/       # Localization support
│   ├── routing/            # Navigation (GoRouter)
│   └── utils/              # Shared utilities
├── domain/                 # Business logic layer
│   ├── entities/           # Domain entities (16+)
│   ├── failures/           # Failure classes
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Use cases
├── data/                   # Data layer
│   ├── datasources/        # Data sources (remote/local)
│   │   ├── local/         # Local datasources (Hive)
│   │   └── remote/        # Remote datasources (Supabase, S3)
│   ├── models/            # Data models
│   └── repositories/      # Repository implementations
├── presentation/           # UI layer
│   ├── blocs/             # BLoC state management
│   │   ├── auth/          # Authentication
│   │   ├── image/         # Image handling
│   │   ├── organizacion/  # Organizations
│   │   ├── plazoleta/     # Plazoletas (plazas)
│   │   ├── producto/     # Products
│   │   └── tienda/       # Stores
│   ├── pages/             # Screens/pages
│   └── widgets/           # Reusable widgets
└── di/                     # Dependency injection (GetIt)
```

### Domain Entities (16+)
- `Usuario` - System users
- `Tienda` - Commercial stores
- `Producto` - Products
- `Plazoleta` - Plazas/locations
- `Organizacion` - Organizations/collectives
- `Categoria` - Categories
- `Horario` - Business hours
- `ValoracionProducto` - Product reviews
- `EtiquetaTienda` - Store tags
- `EtiquetaProducto` - Product tags
- `Notificacion` - Notifications
- `ImagenBase` - Base image model
- And more...

### BLoCs Implemented (6)
- `AuthBloc` - Authentication state
- `ImageBloc` - Image handling
- `OrganizacionBloc` - Organizations
- `PlazoletaBloc` - Plazas
- `ProductoBloc` - Products
- `TiendaBloc` - Stores

### Pages Structure
- `auth/` - Authentication pages (login)
- `splash/` - Splash screen
- `profile/` - User profile
- `tiendas/` - Store pages (detail)
- `productos/` - Product pages (detail)
- `plazoletas/` - Plaza pages (list, detail)
- `organizaciones/` - Organization pages (list, detail)

## 📝 Code Style Guidelines

### Imports Organization
```dart
// 1. Dart/Flutter SDK imports
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 2. Third-party packages
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// 3. Project imports (relative paths)
import '../../domain/entities/tienda.dart';
import '../../domain/usecases/get_tiendas_usecase.dart';

// 4. Part files (at the end)
part 'auth_event.dart';
part 'auth_state.dart';
```

### Naming Conventions
- **Classes:** `PascalCase` (e.g., `TiendaRepository`, `AuthBloc`)
- **Variables:** `camelCase` (e.g., `tiendaList`, `isLoading`)
- **Constants:** `SCREAMING_SNAKE_CASE` (e.g., `APP_NAME`, `MAX_RETRY_COUNT`)
- **Files:** `snake_case.dart` (e.g., `tienda_repository.dart`, `auth_bloc.dart`)
- **Directories:** `snake_case` (e.g., `presentation/blocs/auth/`)

### Entity/Model Patterns
```dart
// Use Equatable for value comparison
class Tienda extends Equatable {
  final int id;
  final String nombreTienda;
  final String? descripcion;
  
  const Tienda({
    required this.id,
    required this.nombreTienda,
    this.descripcion,
  });
  
  // Factory constructor for JSON deserialization
  factory Tienda.fromJson(Map<String, dynamic> json) {
    return Tienda(
      id: json['id'] as int,
      nombreTienda: json['nombre_tienda'] as String,
      descripcion: json['descripcion'] as String?,
    );
  }
  
  // toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_tienda': nombreTienda,
      'descripcion': descripcion,
    };
  }
  
  // copyWith method for immutability
  Tienda copyWith({
    int? id,
    String? nombreTienda,
    String? descripcion,
  }) {
    return Tienda(
      id: id ?? this.id,
      nombreTienda: nombreTienda ?? this.nombreTienda,
      descripcion: descripcion ?? this.descripcion,
    );
  }
  
  @override
  List<Object?> get props => [id, nombreTienda, descripcion];
  
  @override
  bool get stringify => true;
}
```

### BLoC Pattern Implementation
```dart
// Event naming: [BlocName][Action]Event
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  
  const AuthSignInRequested({
    required this.email,
    required this.password,
  });
  
  @override
  List<Object> get props => [email, password];
}

// State naming: [BlocName][State]State
class AuthLoading extends AuthState {
  const AuthLoading();
  
  @override
  List<Object> get props => [];
}

// BLoC implementation
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthenticateUserUseCase _authenticateUserUseCase;
  
  AuthBloc(this._authenticateUserUseCase) : super(const AuthInitial()) {
    on<AuthSignInRequested>(_onAuthSignInRequested);
  }
  
  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final result = await _authenticateUserUseCase.execute(
        email: event.email,
        password: event.password,
      );
      
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) => emit(AuthAuthenticated(user: user)),
      );
    } catch (e) {
      emit(AuthError(message: 'Unexpected error: $e'));
    }
  }
}
```

### Error Handling Pattern
```dart
// Use Either pattern from dartz package
import 'package:dartz/dartz.dart';

abstract class Failure {
  final String message;
  
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class RepositoryFailure extends Failure {
  const RepositoryFailure(String message) : super(message);
}

// In use cases/repositories
Future<Either<Failure, Tienda>> getTiendaById(int id) async {
  try {
    final tienda = await _remoteDataSource.getTiendaById(id);
    return Right(tienda);
  } on SocketException {
    return Left(NetworkFailure('No internet connection'));
  } on FormatException {
    return Left(RepositoryFailure('Invalid data format'));
  } catch (e) {
    return Left(RepositoryFailure('Unexpected error: $e'));
  }
}
```

### Widget Naming and Structure
```dart
// Stateful widgets: [FeatureName]Widget
class TiendaCard extends StatelessWidget {
  final Tienda tienda;
  final VoidCallback? onTap;
  
  const TiendaCard({
    Key? key,
    required this.tienda,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tienda.nombreTienda,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (tienda.descripcion != null) ...[
                const SizedBox(height: 8),
                Text(
                  tienda.descripcion!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

### Dependency Injection (GetIt)
```dart
// Service locator pattern
final getIt = GetIt.instance;

void setupServiceLocator() {
  // Register services as singletons
  getIt.registerLazySingleton(() => CacheService());
  getIt.registerLazySingleton(() => ConnectivityService());
  getIt.registerLazySingleton(() => ImageService());
  
  // Register repositories
  getIt.registerLazySingleton<TiendaRepositoryInterface>(
    () => TiendaRepository(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );
  
  // Register use cases
  getIt.registerLazySingleton(
    () => GetTiendasUseCase(getIt()),
  );
  
  // Register BLoCs (factory - new instance each time)
  getIt.registerFactory(
    () => TiendaBloc(getIt()),
  );
}
```

## 🔧 Environment Configuration

### Required Environment Variables
```env
# Supabase (mandatory)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Firebase (mandatory)
FIREBASE_API_KEY=your-api-key
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_MESSAGING_SENDER_ID=your-sender-id
FIREBASE_APP_ID=your-app-id
FIREBASE_STORAGE_BUCKET=your-storage-bucket

# Google Sign In (mandatory)
GOOGLE_SIGN_IN_IOS_CLIENT_ID=your-ios-client-id
GOOGLE_SIGN_IN_ANDROID_CLIENT_ID=your-android-client-id

# Cloudflare R2 (optional - for image storage migration)
CLOUDFLARE_ACCOUNT_ID=xxxxxxxx
CLOUDFLARE_R2_ACCESS_KEY_ID=xxxxxxxx
CLOUDFLARE_R2_SECRET_ACCESS_KEY=xxxxxxxx
CLOUDFLARE_R2_BUCKET_NAME=your-bucket
CLOUDFLARE_R2_PUBLIC_URL=https://pub-xxxxxx.r2.dev
```

### Configuration Files
- `.env` - Environment variables (DO NOT commit)
- `.env.example` - Example environment variables
- `analysis_options.yaml` - Dart analyzer configuration
- `pubspec.yaml` - Dependencies and project metadata
- `build.yaml` - Build configuration
- `firebase.json` - Firebase configuration
- `lib/firebase_options.dart` - Firebase options

## 🧪 Testing Guidelines

### Test File Structure
```
test/
├── unit/                  # Unit tests
│   ├── domain/           # Domain layer tests
│   ├── data/             # Data layer tests
│   └── presentation/     # Presentation layer tests
├── integration/          # Integration tests
├── widget/              # Widget tests
└── test_helpers/        # Test utilities and mocks
```

### Test Naming Convention
```dart
// Test file: [feature_name]_test.dart
// Test group: [ClassName] tests
// Test case: should [expected behavior] when [condition]

void main() {
  group('TiendaRepository tests', () {
    late TiendaRepository repository;
    late MockRemoteDataSource mockRemoteDataSource;
    
    setUp(() {
      mockRemoteDataSource = MockRemoteDataSource();
      repository = TiendaRepository(remoteDataSource: mockRemoteDataSource);
    });
    
    test('should return tienda when getTiendaById succeeds', () async {
      // Arrange
      const tienda = Tienda(id: 1, nombreTienda: 'Test Tienda');
      when(mockRemoteDataSource.getTiendaById(1))
          .thenAnswer((_) async => tienda);
      
      // Act
      final result = await repository.getTiendaById(1);
      
      // Assert
      expect(result, equals(Right(tienda)));
      verify(mockRemoteDataSource.getTiendaById(1)).called(1);
    });
    
    test('should return failure when network error occurs', () async {
      // Arrange
      when(mockRemoteDataSource.getTiendaById(1))
          .thenThrow(SocketException('No internet'));
      
      // Act
      final result = await repository.getTiendaById(1);
      
      // Assert
      expect(result, isA<Left<Failure, Tienda>>());
      verify(mockRemoteDataSource.getTiendaById(1)).called(1);
    });
  });
}
```

### Mocking Guidelines
```dart
// Use mockito for mocking
class MockRemoteDataSource extends Mock implements RemoteDataSource {}

// Mock BLoC events/states
class MockAuthBloc extends Mock implements AuthBloc {}

// Mock navigation
class MockGoRouter extends Mock implements GoRouter {}
```

## 🔄 Git Workflow

### Commit Message Convention
```
feat: add tienda detail page
fix: resolve image loading issue in tienda card
docs: update README with setup instructions
style: format code according to dart guidelines
refactor: simplify auth service implementation
test: add unit tests for tienda repository
chore: update dependencies to latest versions
```

### Branch Naming
```
feature/add-tienda-search
bugfix/fix-image-cache-issue
hotfix/resolve-auth-crash
release/v1.0.0
```

## 🚨 Common Issues & Solutions

### 1. Build Runner Conflicts
```bash
# Clean and regenerate
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Hive Adapter Generation
```dart
// Add @HiveType() and @HiveField() annotations
@HiveType(typeId: 0)
class Tienda extends Equatable {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String nombreTienda;
  
  // ... rest of class
}

// Then run:
flutter pub run build_runner build
```

### 3. Multi-CDN Image Service Issues
- Check CORS configuration in Cloudflare R2/S3
- Verify environment variables are set correctly
- Ensure bucket has public read access
- Check network connectivity

### 4. Firebase Authentication Issues
- Verify `FIREBASE_API_KEY` is correct
- Check Google Sign In client IDs for iOS and Android
- Ensure SHA-1 fingerprint is configured in Firebase Console
- Check network connectivity to Firebase services

### 5. Supabase Connection Issues
- Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` are correct
- Check that Supabase project is active
- Verify network connectivity
- Check table RLS policies

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Library Documentation](https://bloclibrary.dev)
- [Supabase Flutter Documentation](https://supabase.com/docs/guides/flutter)
- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)
- [Google Sign In Flutter](https://pub.dev/packages/google_sign_in)
- [Clean Architecture for Flutter](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 📋 Key Dependencies

```yaml
# Authentication
firebase_core: ^3.7.0
firebase_auth: ^5.3.0
google_sign_in: ^6.2.0

# Database & Backend
supabase_flutter: ^2.1.3
cloud_firestore: ^5.3.0
firebase_storage: ^12.3.0

# State Management
flutter_bloc: ^9.1.1
equatable: ^2.0.5
dartz: ^0.10.1

# Local Storage
hive: ^2.2.3
hive_flutter: ^1.1.0
flutter_secure_storage: ^10.0.0

# Navigation
go_router: ^17.1.0

# Networking
dio: ^5.4.0
cached_network_image: ^3.3.0

# DI
get_it: ^9.2.0
```

---

**Last Updated:** March 2026  
**Project Status:** Phase 1 Completed, MVP in development  
**Primary Contacts:** Development Team
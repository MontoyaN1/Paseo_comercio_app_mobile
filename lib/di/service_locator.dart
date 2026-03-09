// lib/di/service_locator.dart

import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app/app_config.dart';
import '../core/utils/cache_service.dart';
import '../core/utils/connectivity_service.dart';
import '../core/utils/image_service.dart';
import '../core/utils/firebase_auth_service.dart';
import '../core/utils/app_utils_simple.dart';
import '../data/datasources/remote/supabase_client.dart';
import '../data/datasources/remote/s3_client.dart';
import '../data/datasources/local/local_database.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/tienda_repository.dart';
import '../data/repositories/plazoleta_repository.dart';
import '../data/repositories/producto_repository.dart';
import '../data/repositories/organizacion_repository.dart';
import '../domain/repositories/auth_repository_interface.dart';
import '../domain/repositories/tienda_repository_interface.dart';
import '../domain/repositories/plazoleta_repository_interface.dart';
import '../domain/repositories/producto_repository_interface.dart';
import '../domain/repositories/organizacion_repository_interface.dart';
// Los siguientes repositorios no existen aún, se comentan temporalmente
// import '../data/repositories/categoria_repository.dart';
// import '../data/repositories/imagen_repository.dart';
// import '../data/repositories/cache_repository.dart';
import '../domain/usecases/get_tiendas_usecase.dart';
import '../domain/usecases/get_tienda_by_id_usecase.dart';
import '../domain/usecases/search_tiendas_usecase.dart';
import '../domain/usecases/authenticate_user_usecase.dart';
import '../domain/usecases/get_productos_usecase.dart';
import '../domain/usecases/get_producto_by_id_usecase.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/tienda/tienda_bloc.dart';
import '../presentation/blocs/plazoleta/plazoleta_bloc.dart';
import '../presentation/blocs/producto/producto_bloc.dart';
import '../presentation/blocs/image/image_bloc.dart';
import '../presentation/blocs/organizacion/organizacion_bloc.dart';

final GetIt getIt = GetIt.instance;

/// Configurar inyección de dependencias
Future<void> setupServiceLocator(AppConfig appConfig) async {
  // Registrar configuración de la aplicación
  getIt.registerSingleton<AppConfig>(appConfig);

  // Registrar utilidades generales (versión simplificada)
  getIt.registerSingleton<AppUtilsSimple>(AppUtilsSimple());

  // Inicializar y registrar servicios de conectividad
  final connectivityService = ConnectivityService();
  await connectivityService.initialize();
  getIt.registerSingleton<ConnectivityService>(connectivityService);

  // Inicializar y registrar servicio de caché
  final cacheService = CacheService();
  await cacheService.initialize();
  getIt.registerSingleton<CacheService>(cacheService);

  // Configurar y registrar servicio de imágenes
  final imageService = ImageService();
  imageService.configure(
    r2BaseUrl:
        appConfig.cloudflareR2PublicUrl, // Usar URL pública de Cloudflare R2
    s3BaseUrl: appConfig.s3BaseUrl,
    supabaseUrl: appConfig.supabaseUrl,
    supabaseBucket: appConfig.awsS3BucketName,
  );
  getIt.registerSingleton<ImageService>(imageService);

  // Inicializar Supabase
  await Supabase.initialize(
    url: appConfig.supabaseUrl,
    anonKey: appConfig.supabaseServiceRoleKey,
  );
  final supabaseClient = Supabase.instance.client;
  getIt.registerSingleton<SupabaseClient>(supabaseClient);

  // Registrar cliente Supabase personalizado
  final supabaseClientService = SupabaseClientService();
  await supabaseClientService.initialize();
  getIt.registerSingleton<SupabaseClientService>(supabaseClientService);

  // Inicializar y registrar servicio de autenticación con Firebase
  final authService = FirebaseAuthService(
    supabaseClient: supabaseClientService,
  );
  await authService.initialize();
  getIt.registerSingleton<FirebaseAuthService>(authService);

  // Registrar servicio S3 si está configurado
  if (appConfig.isS3Configured && appConfig.awsAccessKeyId.isNotEmpty) {
    final s3Service = S3ImageService(
      endpoint: appConfig.s3EndpointUrl,
      bucketName: appConfig.awsS3BucketName,
      accessKey: appConfig.awsAccessKeyId,
      secretKey: appConfig.awsSecretAccessKey,
      region: appConfig.awsRegion,
    );
    getIt.registerSingleton<S3ImageService>(s3Service);
  }

  // Inicializar base de datos local
  final localDatabase = LocalCacheService();
  await localDatabase.initialize();
  getIt.registerSingleton<LocalCacheService>(localDatabase);

  // Registrar repositorios
  getIt.registerLazySingleton<AuthRepositoryInterface>(
    () => AuthRepository(
      supabaseClient: getIt<SupabaseClientService>(),
      localCache: getIt<LocalCacheService>(),
    ),
  );

  getIt.registerLazySingleton<TiendaRepositoryInterface>(
    () => TiendaRepository(
      supabaseClient: getIt<SupabaseClientService>(),
      localCache: getIt<LocalCacheService>(),
    ),
  );

  getIt.registerLazySingleton<PlazoletaRepositoryInterface>(
    () => PlazoletaRepository(
      supabaseClient: getIt<SupabaseClientService>(),
      connectivityService: getIt<ConnectivityService>(),
      cacheService: getIt<CacheService>(),
    ),
  );

  getIt.registerLazySingleton<ProductoRepositoryInterface>(
    () => ProductoRepository(
      supabaseClient: getIt<SupabaseClientService>(),
      localCache: getIt<LocalCacheService>(),
      connectivityService: getIt<ConnectivityService>(),
      cacheService: getIt<CacheService>(),
    ),
  );

  getIt.registerLazySingleton<OrganizacionRepositoryInterface>(
    () => OrganizacionRepository(
      supabaseClient: getIt<SupabaseClientService>(),
      localCache: getIt<LocalCacheService>(),
    ),
  );

  // Los siguientes repositorios están comentados porque no existen aún
  /*
  getIt.registerLazySingleton<CategoriaRepository>(
    () => CategoriaRepository(
      supabaseClient: getIt<SupabaseClientService>(),
      cacheService: getIt<CacheService>(),
      connectivityService: getIt<ConnectivityService>(),
    ),
  );

  getIt.registerLazySingleton<ImagenRepository>(
    () => ImagenRepository(
      supabaseClient: getIt<SupabaseClientService>(),
      cacheService: getIt<CacheService>(),
      imageService: getIt<ImageService>(),
      s3Service:
          getIt.isRegistered<S3ImageService>() ? getIt<S3ImageService>() : null,
    ),
  );

  getIt.registerLazySingleton<CacheRepository>(
    () => CacheRepository(localDatabase: getIt<LocalCacheService>()),
  );
  */

  // Registrar casos de uso
  getIt.registerLazySingleton<GetTiendasUseCase>(
    () => GetTiendasUseCase(getIt<TiendaRepositoryInterface>()),
  );

  getIt.registerLazySingleton<GetTiendaByIdUseCase>(
    () => GetTiendaByIdUseCase(getIt<TiendaRepositoryInterface>()),
  );

  getIt.registerLazySingleton<SearchTiendasUseCase>(
    () => SearchTiendasUseCase(getIt<TiendaRepositoryInterface>()),
  );

  getIt.registerLazySingleton<AuthenticateUserUseCase>(
    () => AuthenticateUserUseCase(getIt<AuthRepositoryInterface>()),
  );

  getIt.registerLazySingleton<GetProductosUseCase>(
    () => GetProductosUseCase(getIt<ProductoRepositoryInterface>()),
  );

  getIt.registerLazySingleton<GetProductoByIdUseCase>(
    () => GetProductoByIdUseCase(getIt<ProductoRepositoryInterface>()),
  );

  // Registrar BLoCs
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(getIt<AuthenticateUserUseCase>()),
  );

  getIt.registerLazySingleton<TiendaBloc>(
    () => TiendaBloc(
      getTiendasUseCase: getIt<GetTiendasUseCase>(),
      getTiendaByIdUseCase: getIt<GetTiendaByIdUseCase>(),
      searchTiendasUseCase: getIt<SearchTiendasUseCase>(),
    ),
  );

  getIt.registerLazySingleton<PlazoletaBloc>(
    () => PlazoletaBloc(
      plazoletaRepository: getIt<PlazoletaRepositoryInterface>(),
    ),
  );

  getIt.registerLazySingleton<ProductoBloc>(
    () => ProductoBloc(
      getProductosUseCase: getIt<GetProductosUseCase>(),
      getProductoByIdUseCase: getIt<GetProductoByIdUseCase>(),
    ),
  );

  getIt.registerLazySingleton<ImageBloc>(
    () => ImageBloc(
      imageService: getIt<ImageService>(),
      cacheService: getIt<CacheService>(),
      connectivityService: getIt<ConnectivityService>(),
    ),
  );

  getIt.registerLazySingleton<OrganizacionBloc>(
    () => OrganizacionBloc(
      organizacionRepository: getIt<OrganizacionRepositoryInterface>(),
    ),
  );

  // Verificar que todas las dependencias estén listas
  await getIt.allReady();
}

/// Obtener instancia de un servicio
T getService<T extends Object>() {
  return getIt.get<T>();
}

/// Verificar si un servicio está registrado
bool isServiceRegistered<T extends Object>() {
  return getIt.isRegistered<T>();
}

/// Reiniciar todas las dependencias (útil para testing)
Future<void> resetServiceLocator() async {
  await getIt.reset();
}

// lib/di/service_locator.dart

import 'package:get_it/get_it.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app/app_config.dart';
import '../data/datasources/remote/supabase_client.dart';
import '../data/datasources/remote/s3_client.dart';
import '../data/datasources/local/local_database.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/tienda_repository.dart';
import '../data/repositories/producto_repository.dart';
import '../data/repositories/categoria_repository.dart';
import '../data/repositories/imagen_repository.dart';
import '../data/repositories/cache_repository.dart';

final GetIt getIt = GetIt.instance;

/// Configurar inyección de dependencias
Future<void> setupServiceLocator(AppConfig appConfig) async {
  // Registrar configuración de la aplicación
  getIt.registerSingleton<AppConfig>(appConfig);

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

  // Registrar servicio S3 si está configurado
  if (appConfig.isS3Configured) {
    final s3Service = S3ImageService(
      accessKey: appConfig.awsAccessKeyId,
      secretKey: appConfig.awsSecretAccessKey,
      bucketName: appConfig.awsS3BucketName,
      endpointUrl: appConfig.s3EndpointUrl,
      baseUrl: appConfig.s3BaseUrl,
      folder: appConfig.contaboBucketFolder,
      region: appConfig.awsRegion,
    );
    getIt.registerSingleton<S3ImageService>(s3Service);
  }

  // Inicializar base de datos local
  final localDatabase = LocalCacheService();
  await localDatabase.initialize();
  getIt.registerSingleton<LocalCacheService>(localDatabase);

  // Registrar repositorios
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      supabaseClient: getIt<SupabaseClientService>(),
      localCache: getIt<LocalCacheService>(),
    ),
  );

  getIt.registerLazySingleton<TiendaRepository>(
    () => TiendaRepository(
      supabaseClient: getIt<SupabaseClientService>(),
      cacheService: getIt<LocalCacheService>(),
    ),
  );

  getIt.registerLazySingleton<ProductoRepository>(
    () => ProductoRepository(
      supabaseClient: getIt<SupabaseClientService>(),
      cacheService: getIt<LocalCacheService>(),
    ),
  );

  getIt.registerLazySingleton<CategoriaRepository>(
    () => CategoriaRepository(
      supabaseClient: getIt<SupabaseClientService>(),
      cacheService: getIt<LocalCacheService>(),
    ),
  );

  getIt.registerLazySingleton<ImagenRepository>(
    () => ImagenRepository(
      supabaseClient: getIt<SupabaseClientService>(),
      cacheService: getIt<LocalCacheService>(),
      s3Service:
          getIt.isRegistered<S3ImageService>() ? getIt<S3ImageService>() : null,
    ),
  );

  getIt.registerLazySingleton<CacheRepository>(
    () => CacheRepository(localDatabase: getIt<LocalCacheService>()),
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

// lib/domain/usecases/get_tiendas_usecase.dart

import 'package:equatable/equatable.dart';

import '../repositories/tienda_repository_interface.dart';

/// Caso de uso para obtener tiendas
class GetTiendasUseCase {
  final TiendaRepositoryInterface _tiendaRepository;

  GetTiendasUseCase(this._tiendaRepository);

  /// Ejecutar el caso de uso
  Future<List<Map<String, dynamic>>> execute(GetTiendasParams params) async {
    try {
      return await _tiendaRepository.getTiendas(
        page: params.page,
        limit: params.limit,
        categoriaId: params.categoriaId,
        soloActivas: params.soloActivas,
        forceRefresh: params.forceRefresh,
      );
    } catch (e) {
      // Re-lanzar la excepción para que sea manejada por la capa de presentación
      rethrow;
    }
  }
}

/// Parámetros para el caso de uso GetTiendas
class GetTiendasParams extends Equatable {
  final int page;
  final int limit;
  final String? categoriaId;
  final bool? soloActivas;
  final bool forceRefresh;

  const GetTiendasParams({
    this.page = 1,
    this.limit = 20,
    this.categoriaId,
    this.soloActivas = true,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    categoriaId,
    soloActivas,
    forceRefresh,
  ];

  GetTiendasParams copyWith({
    int? page,
    int? limit,
    String? categoriaId,
    bool? soloActivas,
    bool? forceRefresh,
  }) {
    return GetTiendasParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      categoriaId: categoriaId ?? this.categoriaId,
      soloActivas: soloActivas ?? this.soloActivas,
      forceRefresh: forceRefresh ?? this.forceRefresh,
    );
  }
}

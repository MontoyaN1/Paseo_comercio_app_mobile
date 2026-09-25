// lib/domain/usecases/get_tienda_by_id_usecase.dart

import 'package:equatable/equatable.dart';

import '../repositories/tienda_repository_interface.dart';

/// Caso de uso para obtener una tienda por ID
class GetTiendaByIdUseCase {
  final TiendaRepositoryInterface _tiendaRepository;

  GetTiendaByIdUseCase(this._tiendaRepository);

  /// Ejecutar el caso de uso
  Future<Map<String, dynamic>?> execute(GetTiendaByIdParams params) async {
    try {
      return await _tiendaRepository.getTiendaById(
        params.tiendaId,
        forceRefresh: params.forceRefresh,
      );
    } catch (e) {
      // Re-lanzar la excepción para que sea manejada por la capa de presentación
      rethrow;
    }
  }
}

/// Parámetros para el caso de uso GetTiendaById
class GetTiendaByIdParams extends Equatable {
  final int tiendaId;
  final bool forceRefresh;

  const GetTiendaByIdParams({
    required this.tiendaId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [tiendaId, forceRefresh];

  GetTiendaByIdParams copyWith({int? tiendaId, bool? forceRefresh}) {
    return GetTiendaByIdParams(
      tiendaId: tiendaId ?? this.tiendaId,
      forceRefresh: forceRefresh ?? this.forceRefresh,
    );
  }
}

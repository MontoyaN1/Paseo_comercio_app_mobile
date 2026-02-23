// lib/domain/usecases/get_productos_usecase.dart

import 'package:equatable/equatable.dart';

import '../repositories/producto_repository_interface.dart';

/// Caso de uso para obtener productos
class GetProductosUseCase {
  final ProductoRepositoryInterface _productoRepository;

  GetProductosUseCase(this._productoRepository);

  /// Ejecutar el caso de uso
  Future<List<Map<String, dynamic>>> execute(GetProductosParams params) async {
    try {
      return await _productoRepository.getProductos(
        page: params.page,
        limit: params.limit,
        tiendaId: params.tiendaId,
        categoriaId: params.categoriaId,
        estado: params.estado,
        forceRefresh: params.forceRefresh,
      );
    } catch (e) {
      // Re-lanzar la excepción para que sea manejada por la capa de presentación
      rethrow;
    }
  }
}

/// Parámetros para el caso de uso GetProductos
class GetProductosParams extends Equatable {
  final int page;
  final int limit;
  final int? tiendaId;
  final int? categoriaId;
  final String? estado;
  final bool forceRefresh;

  const GetProductosParams({
    this.page = 1,
    this.limit = 20,
    this.tiendaId,
    this.categoriaId,
    this.estado = 'publicado',
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    tiendaId,
    categoriaId,
    estado,
    forceRefresh,
  ];

  GetProductosParams copyWith({
    int? page,
    int? limit,
    int? tiendaId,
    int? categoriaId,
    String? estado,
    bool? forceRefresh,
  }) {
    return GetProductosParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      tiendaId: tiendaId ?? this.tiendaId,
      categoriaId: categoriaId ?? this.categoriaId,
      estado: estado ?? this.estado,
      forceRefresh: forceRefresh ?? this.forceRefresh,
    );
  }
}

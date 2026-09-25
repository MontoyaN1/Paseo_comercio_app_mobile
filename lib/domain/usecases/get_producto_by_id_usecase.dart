// lib/domain/usecases/get_producto_by_id_usecase.dart

import 'package:equatable/equatable.dart';

import '../repositories/producto_repository_interface.dart';

/// Caso de uso para obtener un producto por ID
class GetProductoByIdUseCase {
  final ProductoRepositoryInterface _productoRepository;

  GetProductoByIdUseCase(this._productoRepository);

  /// Ejecutar el caso de uso
  Future<Map<String, dynamic>?> execute(GetProductoByIdParams params) async {
    try {
      return await _productoRepository.getProductoById(
        params.productoId,
        forceRefresh: params.forceRefresh,
      );
    } catch (e) {
      // Re-lanzar la excepción para que sea manejada por la capa de presentación
      rethrow;
    }
  }
}

/// Parámetros para el caso de uso GetProductoById
class GetProductoByIdParams extends Equatable {
  final int productoId;
  final bool forceRefresh;

  const GetProductoByIdParams({
    required this.productoId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [productoId, forceRefresh];

  GetProductoByIdParams copyWith({int? productoId, bool? forceRefresh}) {
    return GetProductoByIdParams(
      productoId: productoId ?? this.productoId,
      forceRefresh: forceRefresh ?? this.forceRefresh,
    );
  }
}

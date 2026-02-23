// lib/presentation/blocs/producto/producto_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/usecases/get_productos_usecase.dart';
import '../../../../domain/usecases/get_producto_by_id_usecase.dart';

part 'producto_event.dart';
part 'producto_state.dart';

/// BLoC para gestión de productos
class ProductoBloc extends Bloc<ProductoEvent, ProductoState> {
  final GetProductosUseCase _getProductosUseCase;
  final GetProductoByIdUseCase _getProductoByIdUseCase;

  ProductoBloc({
    required GetProductosUseCase getProductosUseCase,
    required GetProductoByIdUseCase getProductoByIdUseCase,
  }) : _getProductosUseCase = getProductosUseCase,
       _getProductoByIdUseCase = getProductoByIdUseCase,
       super(const ProductoInitial()) {
    on<ProductoLoadRequested>(_onProductoLoadRequested);
    on<ProductoLoadByIdRequested>(_onProductoLoadByIdRequested);
    on<ProductoLoadMoreRequested>(_onProductoLoadMoreRequested);
    on<ProductoRefreshRequested>(_onProductoRefreshRequested);
    on<ProductoErrorCleared>(_onProductoErrorCleared);
    on<ProductoFilterByTiendaRequested>(_onProductoFilterByTiendaRequested);
    on<ProductoFilterByCategoriaRequested>(
      _onProductoFilterByCategoriaRequested,
    );
  }

  /// Manejar evento de carga de productos
  Future<void> _onProductoLoadRequested(
    ProductoLoadRequested event,
    Emitter<ProductoState> emit,
  ) async {
    // Si ya estamos cargando, no hacer nada
    if (state is ProductoLoading) return;

    emit(const ProductoLoading());

    try {
      final productos = await _getProductosUseCase.execute(
        GetProductosParams(
          page: event.page,
          limit: event.limit,
          tiendaId: event.tiendaId,
          categoriaId: event.categoriaId,
          estado: event.estado,
          forceRefresh: event.forceRefresh,
        ),
      );

      if (productos.isEmpty) {
        emit(const ProductoEmpty());
      } else {
        emit(
          ProductoLoaded(
            productos: productos,
            currentPage: event.page,
            hasMore: productos.length >= event.limit,
            tiendaId: event.tiendaId,
            categoriaId: event.categoriaId,
            estado: event.estado,
          ),
        );
      }
    } catch (e) {
      emit(ProductoError(message: 'Error al cargar productos: $e', error: e));
    }
  }

  /// Manejar evento de carga de producto por ID
  Future<void> _onProductoLoadByIdRequested(
    ProductoLoadByIdRequested event,
    Emitter<ProductoState> emit,
  ) async {
    // Si ya estamos cargando, no hacer nada
    if (state is ProductoLoading) return;

    emit(const ProductoLoading());

    try {
      final producto = await _getProductoByIdUseCase.execute(
        GetProductoByIdParams(
          productoId: event.productoId,
          forceRefresh: event.forceRefresh,
        ),
      );

      if (producto == null) {
        emit(
          ProductoError(
            message: 'Producto no encontrado',
            error: Exception(
              'Producto con ID ${event.productoId} no encontrado',
            ),
          ),
        );
      } else {
        emit(ProductoDetailLoaded(producto: producto));
      }
    } catch (e) {
      emit(ProductoError(message: 'Error al cargar producto: $e', error: e));
    }
  }

  /// Manejar evento de cargar más productos
  Future<void> _onProductoLoadMoreRequested(
    ProductoLoadMoreRequested event,
    Emitter<ProductoState> emit,
  ) async {
    // Solo cargar más si estamos en un estado cargado y hay más para cargar
    if (state is! ProductoLoaded) return;
    if (state is ProductoLoadingMore) return;

    final currentState = state as ProductoLoaded;
    if (!currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final newProductos = await _getProductosUseCase.execute(
        GetProductosParams(
          page: nextPage,
          limit: event.limit,
          tiendaId: currentState.tiendaId,
          categoriaId: currentState.categoriaId,
          estado: currentState.estado,
          forceRefresh: false,
        ),
      );

      final allProductos = [...currentState.productos, ...newProductos];
      emit(
        ProductoLoaded(
          productos: allProductos,
          currentPage: nextPage,
          hasMore: newProductos.length >= event.limit,
          tiendaId: currentState.tiendaId,
          categoriaId: currentState.categoriaId,
          estado: currentState.estado,
        ),
      );
    } catch (e) {
      // Revertir al estado anterior en caso de error
      emit(currentState);
      emit(
        ProductoError(message: 'Error al cargar más productos: $e', error: e),
      );
    }
  }

  /// Manejar evento de refrescar productos
  Future<void> _onProductoRefreshRequested(
    ProductoRefreshRequested event,
    Emitter<ProductoState> emit,
  ) async {
    final currentState = state;

    if (currentState is ProductoLoaded) {
      // Refrescar lista normal
      add(
        ProductoLoadRequested(
          page: 1,
          limit: currentState.productos.length,
          tiendaId: currentState.tiendaId,
          categoriaId: currentState.categoriaId,
          estado: currentState.estado,
          forceRefresh: true,
        ),
      );
    } else if (currentState is ProductoDetailLoaded) {
      // Refrescar detalle
      add(
        ProductoLoadByIdRequested(
          productoId: currentState.producto['id'] as int,
          forceRefresh: true,
        ),
      );
    }
  }

  /// Manejar evento de limpiar error
  void _onProductoErrorCleared(
    ProductoErrorCleared event,
    Emitter<ProductoState> emit,
  ) {
    // Volver al estado anterior o inicial
    if (state is ProductoError) {
      emit(const ProductoInitial());
    }
  }

  /// Manejar evento de filtrar por tienda
  Future<void> _onProductoFilterByTiendaRequested(
    ProductoFilterByTiendaRequested event,
    Emitter<ProductoState> emit,
  ) async {
    emit(const ProductoLoading());

    try {
      final productos = await _getProductosUseCase.execute(
        GetProductosParams(
          page: 1,
          limit: event.limit,
          tiendaId: event.tiendaId,
          estado: 'publicado',
          forceRefresh: event.forceRefresh,
        ),
      );

      if (productos.isEmpty) {
        emit(ProductoEmpty(message: 'No hay productos en esta tienda'));
      } else {
        emit(
          ProductoLoaded(
            productos: productos,
            currentPage: 1,
            hasMore: productos.length >= event.limit,
            tiendaId: event.tiendaId,
            estado: 'publicado',
          ),
        );
      }
    } catch (e) {
      emit(
        ProductoError(
          message: 'Error al filtrar productos por tienda: $e',
          error: e,
        ),
      );
    }
  }

  /// Manejar evento de filtrar por categoría
  Future<void> _onProductoFilterByCategoriaRequested(
    ProductoFilterByCategoriaRequested event,
    Emitter<ProductoState> emit,
  ) async {
    emit(const ProductoLoading());

    try {
      final productos = await _getProductosUseCase.execute(
        GetProductosParams(
          page: 1,
          limit: event.limit,
          categoriaId: event.categoriaId,
          estado: 'publicado',
          forceRefresh: event.forceRefresh,
        ),
      );

      if (productos.isEmpty) {
        emit(ProductoEmpty(message: 'No hay productos en esta categoría'));
      } else {
        emit(
          ProductoLoaded(
            productos: productos,
            currentPage: 1,
            hasMore: productos.length >= event.limit,
            categoriaId: event.categoriaId,
            estado: 'publicado',
          ),
        );
      }
    } catch (e) {
      emit(
        ProductoError(
          message: 'Error al filtrar productos por categoría: $e',
          error: e,
        ),
      );
    }
  }

  /// Obtener productos actuales del estado
  List<Map<String, dynamic>>? get currentProductos {
    if (state is ProductoLoaded) {
      return (state as ProductoLoaded).productos;
    }
    return null;
  }

  /// Verificar si hay más productos para cargar
  bool get hasMoreProductos {
    if (state is ProductoLoaded) {
      return (state as ProductoLoaded).hasMore;
    }
    return false;
  }

  /// Obtener página actual
  int get currentPage {
    if (state is ProductoLoaded) {
      return (state as ProductoLoaded).currentPage;
    }
    return 1;
  }

  /// Obtener filtros actuales
  Map<String, dynamic> get currentFilters {
    if (state is ProductoLoaded) {
      final loadedState = state as ProductoLoaded;
      return {
        'tiendaId': loadedState.tiendaId,
        'categoriaId': loadedState.categoriaId,
        'estado': loadedState.estado,
      };
    }
    return {};
  }

  /// Disposición del BLoC
  @override
  Future<void> close() {
    // Limpiar recursos si es necesario
    return super.close();
  }
}

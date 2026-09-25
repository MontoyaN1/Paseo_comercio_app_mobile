// lib/domain/usecases/search_tiendas_usecase.dart

import 'package:equatable/equatable.dart';

import '../repositories/tienda_repository_interface.dart';

/// Caso de uso para buscar tiendas
class SearchTiendasUseCase {
  final TiendaRepositoryInterface _tiendaRepository;

  SearchTiendasUseCase(this._tiendaRepository);

  /// Ejecutar el caso de uso
  Future<List<Map<String, dynamic>>> execute(SearchTiendasParams params) async {
    try {
      return await _tiendaRepository.searchTiendas(
        params.query,
        page: params.page,
        limit: params.limit,
      );
    } catch (e) {
      // Re-lanzar la excepción para que sea manejada por la capa de presentación
      rethrow;
    }
  }
}

/// Parámetros para el caso de uso SearchTiendas
class SearchTiendasParams extends Equatable {
  final String query;
  final int page;
  final int limit;

  const SearchTiendasParams({
    required this.query,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, page, limit];

  SearchTiendasParams copyWith({String? query, int? page, int? limit}) {
    return SearchTiendasParams(
      query: query ?? this.query,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toJson() {
    return {'query': query, 'page': page, 'limit': limit};
  }

  /// Validar parámetros de búsqueda
  void validate() {
    if (query.isEmpty) {
      throw ArgumentError('El término de búsqueda no puede estar vacío');
    }
    if (query.length < 2) {
      throw ArgumentError(
        'El término de búsqueda debe tener al menos 2 caracteres',
      );
    }
    if (page < 1) {
      throw ArgumentError('La página debe ser mayor o igual a 1');
    }
    if (limit < 1 || limit > 100) {
      throw ArgumentError('El límite debe estar entre 1 y 100');
    }
  }
}

/// Resultado de búsqueda de tiendas
class SearchTiendasResult extends Equatable {
  final List<Map<String, dynamic>> tiendas;
  final int totalResults;
  final int currentPage;
  final int totalPages;
  final String query;
  final DateTime timestamp;

  const SearchTiendasResult({
    required this.tiendas,
    required this.totalResults,
    required this.currentPage,
    required this.totalPages,
    required this.query,
    required this.timestamp,
  });

  factory SearchTiendasResult.fromJson(Map<String, dynamic> json) {
    return SearchTiendasResult(
      tiendas: List<Map<String, dynamic>>.from(json['tiendas'] ?? []),
      totalResults: json['total_results'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      query: json['query'] ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tiendas': tiendas,
      'total_results': totalResults,
      'current_page': currentPage,
      'total_pages': totalPages,
      'query': query,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Verificar si hay más páginas disponibles
  bool get hasMorePages => currentPage < totalPages;

  /// Verificar si no hay resultados
  bool get isEmpty => tiendas.isEmpty;

  /// Obtener siguiente página
  SearchTiendasParams get nextPageParams {
    return SearchTiendasParams(
      query: query,
      page: currentPage + 1,
      limit: tiendas.length,
    );
  }

  /// Obtener página anterior
  SearchTiendasParams get previousPageParams {
    return SearchTiendasParams(
      query: query,
      page: currentPage > 1 ? currentPage - 1 : 1,
      limit: tiendas.length,
    );
  }

  @override
  List<Object?> get props => [
    tiendas,
    totalResults,
    currentPage,
    totalPages,
    query,
    timestamp,
  ];

  @override
  String toString() {
    return 'SearchTiendasResult{tiendas: ${tiendas.length}, totalResults: $totalResults, currentPage: $currentPage, totalPages: $totalPages, query: $query}';
  }
}

/// Excepciones específicas para búsqueda de tiendas
abstract class SearchTiendasException implements Exception {
  final String message;
  final Object? cause;

  const SearchTiendasException(this.message, {this.cause});

  @override
  String toString() =>
      'SearchTiendasException: $message${cause != null ? ' (Caused by: $cause)' : ''}';
}

/// Excepción cuando el término de búsqueda es inválido
class InvalidSearchTermException extends SearchTiendasException {
  final String term;

  const InvalidSearchTermException(this.term)
    : super('Término de búsqueda inválido: "$term"');

  @override
  String toString() =>
      'InvalidSearchTermException: Término de búsqueda inválido: "$term"';
}

/// Excepción cuando no hay resultados de búsqueda
class NoSearchResultsException extends SearchTiendasException {
  final String query;

  const NoSearchResultsException(this.query)
    : super('No se encontraron resultados para: "$query"');

  @override
  String toString() =>
      'NoSearchResultsException: No se encontraron resultados para: "$query"';
}

/// Excepción cuando la página solicitada no existe
class PageOutOfRangeException extends SearchTiendasException {
  final int requestedPage;
  final int totalPages;

  const PageOutOfRangeException(this.requestedPage, this.totalPages)
    : super(
        'Página $requestedPage fuera de rango. Total de páginas: $totalPages',
      );

  @override
  String toString() =>
      'PageOutOfRangeException: Página $requestedPage fuera de rango. Total de páginas: $totalPages';
}

/// Excepción cuando el límite de resultados es inválido
class InvalidLimitException extends SearchTiendasException {
  final int limit;

  const InvalidLimitException(this.limit)
    : super('Límite inválido: $limit. Debe estar entre 1 y 100');

  @override
  String toString() =>
      'InvalidLimitException: Límite inválido: $limit. Debe estar entre 1 y 100';
}

/// Excepción cuando hay un error de conexión durante la búsqueda
class SearchConnectionException extends SearchTiendasException {
  const SearchConnectionException(Object? cause)
    : super('Error de conexión durante la búsqueda', cause: cause);
}

/// Excepción cuando el servidor de búsqueda no está disponible
class SearchServerUnavailableException extends SearchTiendasException {
  const SearchServerUnavailableException()
    : super('Servidor de búsqueda no disponible temporalmente');
}

/// Excepción cuando la búsqueda toma demasiado tiempo
class SearchTimeoutException extends SearchTiendasException {
  const SearchTimeoutException()
    : super('La búsqueda ha excedido el tiempo límite');
}

/// Excepción cuando hay un error en los parámetros de búsqueda
class SearchParametersException extends SearchTiendasException {
  final Map<String, String> errors;

  const SearchParametersException(this.errors)
    : super('Error en los parámetros de búsqueda');

  @override
  String toString() {
    final errorMessages = errors.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    return 'SearchParametersException: Error en los parámetros de búsqueda: $errorMessages';
  }
}

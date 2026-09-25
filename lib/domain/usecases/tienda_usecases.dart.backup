// lib/domain/usecases/tienda_usecases.dart

import 'package:dartz/dartz.dart';

import '../entities/tienda.dart';
import '../repositories/tienda_repository_interface.dart';
import '../repositories/tienda_repository_interface.dart'
    show
        TiendaRepositoryException,
        ValidationException,
        TiendaNotFoundException,
        TiendaCreationFailedException,
        TiendaUpdateFailedException,
        TiendaDeleteFailedException;

/// Casos de uso para operaciones relacionadas con tiendas
/// Utiliza el patrón de diseño UseCase para separar la lógica de negocio
/// de la implementación del repositorio.

/// Caso de uso: Obtener todas las tiendas
class GetTiendasUseCase {
  final TiendaRepositoryInterface _repository;

  GetTiendasUseCase(this._repository);

  /// Ejecutar el caso de uso para obtener tiendas
  ///
  /// Parámetros:
  /// - `params`: Parámetros de paginación y filtros
  ///
  /// Retorna:
  /// - `Either<TiendaRepositoryException, List<Tienda>>`:
  ///   - `Right`: Lista de tiendas obtenida exitosamente
  ///   - `Left`: Excepción si ocurre un error
  Future<Either<TiendaRepositoryException, List<Tienda>>> execute(
    GetTiendasParams params,
  ) async {
    try {
      // Validar parámetros
      if (params.page < 1) {
        return Left(
          ValidationException({'page': 'La página debe ser mayor o igual a 1'}),
        );
      }

      if (params.limit < 1 || params.limit > 100) {
        return Left(
          ValidationException({'limit': 'El límite debe estar entre 1 y 100'}),
        );
      }

      // Obtener datos del repositorio
      final tiendasData = await _repository.getTiendas(
        page: params.page,
        limit: params.limit,
        categoriaId: params.categoriaId,
        soloActivas: params.soloActivas,
        forceRefresh: params.forceRefresh,
      );

      // Convertir datos a entidades de dominio
      final tiendas =
          tiendasData
              .map((data) => Tienda.fromJson(data))
              .where((tienda) => tienda.estaActiva)
              .toList();

      return Right(tiendas);
    } on TiendaRepositoryException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        TiendaRepositoryException(
          'Error inesperado al obtener tiendas',
          cause: e,
        ),
      );
    }
  }
}

/// Caso de uso: Obtener tienda por ID
class GetTiendaByIdUseCase {
  final TiendaRepositoryInterface _repository;

  GetTiendaByIdUseCase(this._repository);

  /// Ejecutar el caso de uso para obtener una tienda por ID
  Future<Either<TiendaRepositoryException, Tienda>> execute(
    int tiendaId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Validar ID
      if (tiendaId <= 0) {
        return Left(
          ValidationException({
            'tiendaId': 'El ID de la tienda debe ser mayor a 0',
          }),
        );
      }

      // Obtener datos del repositorio
      final tiendaData = await _repository.getTiendaById(
        tiendaId,
        forceRefresh: forceRefresh,
      );

      if (tiendaData == null) {
        return Left(TiendaNotFoundException(tiendaId));
      }

      // Convertir a entidad de dominio
      final tienda = Tienda.fromJson(tiendaData);

      // Validar que la tienda esté activa (si se solicitó solo activas)
      if (!tienda.estaActiva) {
        return Left(
          TiendaRepositoryException('La tienda $tiendaId no está activa'),
        );
      }

      return Right(tienda);
    } on TiendaRepositoryException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        TiendaRepositoryException(
          'Error inesperado al obtener la tienda $tiendaId',
          cause: e,
        ),
      );
    }
  }
}

/// Caso de uso: Buscar tiendas por término
class SearchTiendasUseCase {
  final TiendaRepositoryInterface _repository;

  SearchTiendasUseCase(this._repository);

  /// Ejecutar el caso de uso para buscar tiendas
  Future<Either<TiendaRepositoryException, List<Tienda>>> execute(
    SearchTiendasParams params,
  ) async {
    try {
      // Validar parámetros
      if (params.query.trim().isEmpty) {
        return Left(
          ValidationException({
            'query': 'El término de búsqueda no puede estar vacío',
          }),
        );
      }

      if (params.query.length < 2) {
        return Left(
          ValidationException({
            'query': 'El término de búsqueda debe tener al menos 2 caracteres',
          }),
        );
      }

      if (params.page < 1) {
        return Left(
          ValidationException({'page': 'La página debe ser mayor o igual a 1'}),
        );
      }

      if (params.limit < 1 || params.limit > 50) {
        return Left(
          ValidationException({
            'limit': 'El límite debe estar entre 1 y 50 para búsquedas',
          }),
        );
      }

      // Obtener datos del repositorio
      final tiendasData = await _repository.searchTiendas(
        params.query,
        page: params.page,
        limit: params.limit,
      );

      // Convertir datos a entidades de dominio
      final tiendas =
          tiendasData
              .map((data) => Tienda.fromJson(data))
              .where((tienda) => tienda.estaActiva)
              .toList();

      return Right(tiendas);
    } on TiendaRepositoryException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        TiendaRepositoryException(
          'Error inesperado al buscar tiendas',
          cause: e,
        ),
      );
    }
  }
}

/// Caso de uso: Crear nueva tienda
class CreateTiendaUseCase {
  final TiendaRepositoryInterface _repository;

  CreateTiendaUseCase(this._repository);

  /// Ejecutar el caso de uso para crear una tienda
  Future<Either<TiendaRepositoryException, Tienda>> execute(
    CreateTiendaParams params,
  ) async {
    try {
      // Validar parámetros
      final validationErrors = <String, String>{};

      if (params.idPropietario <= 0) {
        validationErrors['idPropietario'] = 'El ID del propietario es inválido';
      }

      if (params.nombreTienda.trim().isEmpty) {
        validationErrors['nombreTienda'] =
            'El nombre de la tienda es requerido';
      } else if (params.nombreTienda.length < 3) {
        validationErrors['nombreTienda'] =
            'El nombre debe tener al menos 3 caracteres';
      } else if (params.nombreTienda.length > 100) {
        validationErrors['nombreTienda'] =
            'El nombre no puede exceder 100 caracteres';
      }

      if (params.descripcion != null && params.descripcion!.length > 500) {
        validationErrors['descripcion'] =
            'La descripción no puede exceder 500 caracteres';
      }

      if (params.emailContacto != null &&
          !_isValidEmail(params.emailContacto!)) {
        validationErrors['emailContacto'] = 'El email no es válido';
      }

      if (params.telefonoContacto != null &&
          !_isValidPhone(params.telefonoContacto!)) {
        validationErrors['telefonoContacto'] = 'El teléfono no es válido';
      }

      if (validationErrors.isNotEmpty) {
        return Left(ValidationException(validationErrors));
      }

      // Crear tienda en el repositorio
      final tiendaData = await _repository.createTienda(
        idPropietario: params.idPropietario,
        nombreTienda: params.nombreTienda,
        descripcion: params.descripcion,
        redesSociales: params.redesSociales,
        organizacionId: params.organizacionId,
        emailContacto: params.emailContacto,
        telefonoContacto: params.telefonoContacto,
        direccion: params.direccion,
      );

      if (tiendaData == null) {
        return Left(TiendaCreationFailedException(null));
      }

      // Convertir a entidad de dominio
      final tienda = Tienda.fromJson(tiendaData);

      return Right(tienda);
    } on TiendaRepositoryException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(TiendaCreationFailedException(e));
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[0-9+\-\s()]{7,20}$');
    return phoneRegex.hasMatch(phone);
  }
}

/// Caso de uso: Actualizar tienda
class UpdateTiendaUseCase {
  final TiendaRepositoryInterface _repository;

  UpdateTiendaUseCase(this._repository);

  /// Ejecutar el caso de uso para actualizar una tienda
  Future<Either<TiendaRepositoryException, Tienda>> execute(
    UpdateTiendaParams params,
  ) async {
    try {
      // Validar parámetros
      if (params.tiendaId <= 0) {
        return Left(
          ValidationException({'tiendaId': 'El ID de la tienda es inválido'}),
        );
      }

      if (!params.hasUpdates) {
        return Left(
          ValidationException({
            'updates': 'No hay actualizaciones para aplicar',
          }),
        );
      }

      final validationErrors = <String, String>{};

      if (params.nombreTienda != null) {
        if (params.nombreTienda!.trim().isEmpty) {
          validationErrors['nombreTienda'] =
              'El nombre de la tienda no puede estar vacío';
        } else if (params.nombreTienda!.length < 3) {
          validationErrors['nombreTienda'] =
              'El nombre debe tener al menos 3 caracteres';
        } else if (params.nombreTienda!.length > 100) {
          validationErrors['nombreTienda'] =
              'El nombre no puede exceder 100 caracteres';
        }
      }

      if (params.descripcion != null && params.descripcion!.length > 500) {
        validationErrors['descripcion'] =
            'La descripción no puede exceder 500 caracteres';
      }

      if (params.emailContacto != null &&
          !_isValidEmail(params.emailContacto!)) {
        validationErrors['emailContacto'] = 'El email no es válido';
      }

      if (params.telefonoContacto != null &&
          !_isValidPhone(params.telefonoContacto!)) {
        validationErrors['telefonoContacto'] = 'El teléfono no es válido';
      }

      if (validationErrors.isNotEmpty) {
        return Left(ValidationException(validationErrors));
      }

      // Actualizar tienda en el repositorio
      final success = await _repository.updateTienda(
        params.tiendaId,
        nombreTienda: params.nombreTienda,
        descripcion: params.descripcion,
        redesSociales: params.redesSociales,
        organizacionId: params.organizacionId,
        emailContacto: params.emailContacto,
        telefonoContacto: params.telefonoContacto,
        direccion: params.direccion,
      );

      if (!success) {
        return Left(TiendaUpdateFailedException(params.tiendaId, null));
      }

      // Obtener la tienda actualizada
      final tiendaData = await _repository.getTiendaById(
        params.tiendaId,
        forceRefresh: true,
      );

      if (tiendaData == null) {
        return Left(TiendaNotFoundException(params.tiendaId));
      }

      // Convertir a entidad de dominio
      final tienda = Tienda.fromJson(tiendaData);

      return Right(tienda);
    } on TiendaRepositoryException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(TiendaUpdateFailedException(params.tiendaId, e));
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[0-9+\-\s()]{7,20}$');
    return phoneRegex.hasMatch(phone);
  }
}

/// Caso de uso: Eliminar tienda
class DeleteTiendaUseCase {
  final TiendaRepositoryInterface _repository;

  DeleteTiendaUseCase(this._repository);

  /// Ejecutar el caso de uso para eliminar una tienda
  Future<Either<TiendaRepositoryException, bool>> execute(int tiendaId) async {
    try {
      // Validar ID
      if (tiendaId <= 0) {
        return Left(
          ValidationException({'tiendaId': 'El ID de la tienda es inválido'}),
        );
      }

      // Verificar que la tienda existe
      final tiendaData = await _repository.getTiendaById(tiendaId);
      if (tiendaData == null) {
        return Left(TiendaNotFoundException(tiendaId));
      }

      // Eliminar tienda
      final success = await _repository.deleteTienda(tiendaId);

      if (!success) {
        return Left(TiendaDeleteFailedException(tiendaId, null));
      }

      return Right(true);
    } on TiendaRepositoryException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(TiendaDeleteFailedException(tiendaId, e));
    }
  }
}

/// Caso de uso: Obtener tiendas destacadas
class GetTiendasDestacadasUseCase {
  final TiendaRepositoryInterface _repository;

  GetTiendasDestacadasUseCase(this._repository);

  /// Ejecutar el caso de uso para obtener tiendas destacadas
  Future<Either<TiendaRepositoryException, List<Tienda>>> execute(
    GetTiendasDestacadasParams params,
  ) async {
    try {
      // Validar parámetros
      if (params.limit < 1 || params.limit > 50) {
        return Left(
          ValidationException({'limit': 'El límite debe estar entre 1 y 50'}),
        );
      }

      // Obtener tiendas destacadas del repositorio
      final tiendasData = await _repository.getTiendasDestacadas(
        limit: params.limit,
      );

      // Convertir datos a entidades de dominio
      final tiendas =
          tiendasData
              .map((data) => Tienda.fromJson(data))
              .where((tienda) => tienda.estaActiva)
              .toList();

      return Right(tiendas);
    } on TiendaRepositoryException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        TiendaRepositoryException(
          'Error inesperado al obtener tiendas destacadas',
          cause: e,
        ),
      );
    }
  }
}

/// Caso de uso: Obtener tiendas por propietario
class GetTiendasByPropietarioUseCase {
  final TiendaRepositoryInterface _repository;

  GetTiendasByPropietarioUseCase(this._repository);

  /// Ejecutar el caso de uso para obtener tiendas por propietario
  Future<Either<TiendaRepositoryException, List<Tienda>>> execute(
    GetTiendasByPropietarioParams params,
  ) async {
    try {
      // Validar parámetros
      if (params.propietarioId <= 0) {
        return Left(
          ValidationException({
            'propietarioId': 'El ID del propietario es inválido',
          }),
        );
      }

      if (params.page < 1) {
        return Left(
          ValidationException({'page': 'La página debe ser mayor o igual a 1'}),
        );
      }

      if (params.limit < 1 || params.limit > 50) {
        return Left(
          ValidationException({'limit': 'El límite debe estar entre 1 y 50'}),
        );
      }

      // Obtener tiendas del repositorio
      final tiendasData = await _repository.getTiendasByPropietario(
        params.propietarioId,
        page: params.page,
        limit: params.limit,
        forceRefresh: params.forceRefresh,
      );

      // Convertir datos a entidades de dominio
      final tiendas =
          tiendasData
              .map((data) => Tienda.fromJson(data))
              .where((tienda) => tienda.estaActiva)
              .toList();

      return Right(tiendas);
    } on TiendaRepositoryException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        TiendaRepositoryException(
          'Error inesperado al obtener tiendas del propietario',
          cause: e,
        ),
      );
    }
  }
}

/// Caso de uso: Registrar visita a tienda
class RegistrarVisitaTiendaUseCase {
  final TiendaRepositoryInterface _repository;

  RegistrarVisitaTiendaUseCase(this._repository);

  /// Ejecutar el caso de uso para registrar una visita
  Future<Either<TiendaRepositoryException, bool>> execute(int tiendaId) async {
    try {
      // Validar ID
      if (tiendaId <= 0) {
        return Left(
          ValidationException({'tiendaId': 'El ID de la tienda es inválido'}),
        );
      }

      // Verificar que la tienda existe
      final tiendaData = await _repository.getTiendaById(tiendaId);
      if (tiendaData == null) {
        return Left(TiendaNotFoundException(tiendaId));
      }

      // Registrar visita
      final success = await _repository.registrarVisitaTienda(tiendaId);

      if (!success) {
        return Left(
          TiendaRepositoryException(
            'Error al registrar visita a la tienda $tiendaId',
          ),
        );
      }

      return Right(true);
    } on TiendaRepositoryException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        TiendaRepositoryException(
          'Error inesperado al registrar visita',
          cause: e,
        ),
      );
    }
  }
}

/// Caso de uso: Obtener tiendas por propietario
class GetTiendasByPropietarioUseCase {
  final TiendaRepositoryInterface _repository;

  GetTiendasByPropietarioUseCase(this._repository);

  /// Ejecutar el caso de uso para obtener tiendas por propietario
  Future<Either<TiendaRepositoryException, List<Tienda>>> execute(
    GetTiendasByPropietarioParams params,
  ) async {
    try {
      // Validar parámetros
      if (params.propietarioId <= 0) {
        return Left(
          ValidationException({
            'propietarioId': 'El ID del propietario es inválido',
          }),
        );
      }

      if (params.page < 1) {
        return Left(
          ValidationException({'page': 'La página debe ser mayor o igual a 1'}),
        );
      }

      if (params.limit < 1 || params.limit > 50) {
        return Left(
          ValidationException({'limit': 'El límite debe estar entre 1 y 50'}),
        );
      }

      // Obtener tiendas del repositorio
      final tiendasData = await _repository.getTiendasByPropietario(
        params.propietarioId,
        page: params.page,
        limit: params.limit,
        forceRefresh: params.forceRefresh,
      );

      // Convertir datos a entidades de dominio
      final tiendas =
          tiendasData
              .map((data) => Tienda.fromJson(data))
              .where((tienda) => tienda.estaActiva)
              .toList();

      return Right(tiendas);
    } on TiendaRepositoryException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        TiendaRepositoryException(
          'Error inesperado al obtener tiendas del propietario',
          cause: e,
        ),
      );
    }
  }
}

/// Caso de uso: Registrar visita a tienda
class RegistrarVisitaTiendaUseCase {
  final TiendaRepositoryInterface _repository;

  RegistrarVisitaTiendaUseCase(this._repository);

  /// Ejecutar el caso de uso para registrar una visita
  Future<Either<TiendaRepositoryException, bool>> execute(int tiendaId) async {
    try {
      // Validar ID
      if (tiendaId <= 0) {
        return Left(
          ValidationException({
            'tiendaId': 'El ID de la tienda debe ser mayor a 0',
          }),
        );
      }

      // Verificar que la tienda existe
      final tiendaData = await _repository.getTiendaById(tiendaId);
      if (tiendaData == null) {
        return Left(TiendaNotFoundException(tiendaId));
      }

      // Registrar visita
      final success = await _repository.registrarVisita(tiendaId);

      if (!success) {
        return Left(
          TiendaRepositoryException(
            'Error al registrar visita a la tienda $tiendaId',
          ),
        );
      }

      return Right(true);
    } on TiendaRepositoryException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        TiendaRepositoryException(
          'Error inesperado al registrar visita',
          cause: e,
        ),
      );
    }
  }
}

// lib/core/utils/result.dart

/// Patrón Result para manejar operaciones que pueden fallar
sealed class Result<T, E> {
  const Result();

  /// Verificar si es éxito
  bool get isSuccess => this is Success<T, E>;

  /// Verificar si es error
  bool get isError => this is Error<T, E>;

  /// Obtener valor si es éxito
  T? get valueOrNull => isSuccess ? (this as Success<T, E>).value : null;

  /// Obtener error si es error
  E? get errorOrNull => isError ? (this as Error<T, E>).error : null;

  /// Mapear valor si es éxito
  Result<U, E> map<U>(U Function(T value) transform) {
    return switch (this) {
      Success<T, E>(:final value) => Success(transform(value)),
      Error<T, E>(:final error) => Error(error),
    };
  }

  /// Mapear error si es error
  Result<T, F> mapError<F>(F Function(E error) transform) {
    return switch (this) {
      Success<T, E>(:final value) => Success(value),
      Error<T, E>(:final error) => Error(transform(error)),
    };
  }

  /// Mapear valor si es éxito (async)
  Future<Result<U, E>> mapAsync<U>(
    Future<U> Function(T value) transform,
  ) async {
    return switch (this) {
      Success<T, E>(:final value) => Success(await transform(value)),
      Error<T, E>(:final error) => Error(error),
    };
  }

  /// Mapear error si es error (async)
  Future<Result<T, F>> mapErrorAsync<F>(
    Future<F> Function(E error) transform,
  ) async {
    return switch (this) {
      Success<T, E>(:final value) => Success(value),
      Error<T, E>(:final error) => Error(await transform(error)),
    };
  }

  /// Ejecutar función si es éxito
  Result<T, E> onSuccess(void Function(T value) action) {
    if (this is Success<T, E>) {
      action((this as Success<T, E>).value);
    }
    return this;
  }

  /// Ejecutar función si es error
  Result<T, E> onError(void Function(E error) action) {
    if (this is Error<T, E>) {
      action((this as Error<T, E>).error);
    }
    return this;
  }

  /// Obtener valor o lanzar excepción
  T getOrThrow() {
    return switch (this) {
      Success<T, E>(:final value) => value,
      Error<T, E>(:final error) =>
        throw error is Exception ? error : Exception('$error'),
    };
  }

  /// Obtener valor o valor por defecto
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T, E>(:final value) => value,
      Error<T, E>() => defaultValue,
    };
  }

  /// Obtener valor o calcular valor por defecto
  T getOrElseGet(T Function() defaultValue) {
    return switch (this) {
      Success<T, E>(:final value) => value,
      Error<T, E>() => defaultValue(),
    };
  }

  /// Fold: transformar ambos casos
  U fold<U>(U Function(T value) onSuccess, U Function(E error) onError) {
    return switch (this) {
      Success<T, E>(:final value) => onSuccess(value),
      Error<T, E>(:final error) => onError(error),
    };
  }

  /// Fold async: transformar ambos casos (async)
  Future<U> foldAsync<U>(
    Future<U> Function(T value) onSuccess,
    Future<U> Function(E error) onError,
  ) async {
    return switch (this) {
      Success<T, E>(:final value) => await onSuccess(value),
      Error<T, E>(:final error) => await onError(error),
    };
  }

  /// Combinar dos resultados
  static Result<(T1, T2), E> combine<T1, T2, E>(
    Result<T1, E> result1,
    Result<T2, E> result2,
  ) {
    return switch ((result1, result2)) {
      (Success<T1, E>(value: final v1), Success<T2, E>(value: final v2)) =>
        Success((v1, v2)),
      (Error<T1, E>(error: final e), _) => Error(e),
      (_, Error<T2, E>(error: final e)) => Error(e),
    };
  }

  /// Combinar múltiples resultados
  static Result<List<T>, E> combineAll<T, E>(List<Result<T, E>> results) {
    final values = <T>[];
    for (final result in results) {
      switch (result) {
        case Success<T, E>(value: final value):
          values.add(value);
        case Error<T, E>(error: final error):
          return Error(error);
      }
    }
    return Success(values);
  }

  /// Crear resultado exitoso
  static Result<T, E> success<T, E>(T value) => Success(value);

  /// Crear resultado con error
  static Result<T, E> error<T, E>(E error) => Error(error);

  /// Ejecutar función y envolver en Result
  static Result<T, Exception> tryCatch<T>(T Function() computation) {
    try {
      return Success(computation());
    } catch (e) {
      return Error(e is Exception ? e : Exception('$e'));
    }
  }

  /// Ejecutar función async y envolver en Result
  static Future<Result<T, Exception>> tryCatchAsync<T>(
    Future<T> Function() computation,
  ) async {
    try {
      return Success(await computation());
    } catch (e) {
      return Error(e is Exception ? e : Exception('$e'));
    }
  }
}

/// Resultado exitoso
final class Success<T, E> extends Result<T, E> {
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Success<T, E> && other.value == value);
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Resultado con error
final class Error<T, E> extends Result<T, E> {
  final E error;

  const Error(this.error);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Error<T, E> && other.error == error);
  }

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Error($error)';
}

/// Extensión para Future<Result>
extension FutureResultExtension<T, E> on Future<Result<T, E>> {
  /// Mapear valor si es éxito
  Future<Result<U, E>> mapFuture<U>(U Function(T value) transform) async {
    final result = await this;
    return result.map(transform);
  }

  /// Mapear error si es error
  Future<Result<T, F>> mapErrorFuture<F>(F Function(E error) transform) async {
    final result = await this;
    return result.mapError(transform);
  }

  /// Obtener valor o lanzar excepción
  Future<T> getOrThrowFuture() async {
    final result = await this;
    return result.getOrThrow();
  }

  /// Obtener valor o valor por defecto
  Future<T> getOrElseFuture(T defaultValue) async {
    final result = await this;
    return result.getOrElse(defaultValue);
  }

  /// Fold: transformar ambos casos
  Future<U> foldFuture<U>(
    U Function(T value) onSuccess,
    U Function(E error) onError,
  ) async {
    final result = await this;
    return result.fold(onSuccess, onError);
  }
}

/// Extensión para Result con Exception como error
extension ResultExceptionExtension<T> on Result<T, Exception> {
  /// Convertir a Future<Result> con error manejado
  Future<Result<T, String>> toUserFriendlyResult() async {
    return mapError((error) => error.toString());
  }

  /// Ejecutar y mostrar snackbar si hay error
  Future<Result<T, Exception>> withErrorSnackbar(
    void Function(String message) showSnackbar,
  ) async {
    return onError((error) {
      showSnackbar('Error: ${error.toString()}');
    });
  }
}

/// Extensión para Option-like comportamiento
extension ResultOptionExtension<T, E> on Result<T, E> {
  /// Verificar si contiene valor específico
  bool contains(T value) {
    if (this is Success<T, E>) {
      final success = this as Success<T, E>;
      return success.value == value;
    }
    return false;
  }

  /// Filtrar valor si cumple condición
  Result<T, E> filter(bool Function(T value) predicate, E Function() onFalse) {
    return switch (this) {
      Success<T, E>(:final value) =>
        predicate(value) ? Success(value) : Error(onFalse()),
      Error<T, E>(:final error) => Error(error),
    };
  }

  /// Flat map: mapear a otro Result
  Result<U, E> flatMap<U>(Result<U, E> Function(T value) transform) {
    return switch (this) {
      Success<T, E>(:final value) => transform(value),
      Error<T, E>(:final error) => Error(error),
    };
  }

  /// Flat map async: mapear a otro Result (async)
  Future<Result<U, E>> flatMapAsync<U>(
    Future<Result<U, E>> Function(T value) transform,
  ) async {
    return switch (this) {
      Success<T, E>(:final value) => await transform(value),
      Error<T, E>(:final error) => Error(error),
    };
  }
}

/// Extensión para List<Result>
extension ListResultExtension<T, E> on List<Result<T, E>> {
  /// Separar éxitos y errores
  (List<T>, List<E>) partitionResults() {
    final successes = <T>[];
    final errors = <E>[];

    for (final result in this) {
      switch (result) {
        case Success<T, E>(value: final value):
          successes.add(value);
        case Error<T, E>(error: final error):
          errors.add(error);
      }
    }

    return (successes, errors);
  }

  /// Obtener solo éxitos
  List<T> getSuccesses() {
    return whereType<Success<T, E>>().map((s) => s.value).toList();
  }

  /// Obtener solo errores
  List<E> getErrors() {
    return whereType<Error<T, E>>().map((e) => e.error).toList();
  }

  /// Verificar si todos son éxitos
  bool allSuccess() {
    return every((result) => result.isSuccess);
  }

  /// Verificar si hay algún error
  bool anyError() {
    return any((result) => result.isError);
  }
}

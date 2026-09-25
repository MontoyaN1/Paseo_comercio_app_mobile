// lib/core/utils/auth_state.dart

/// Estados de autenticación posibles
enum AuthState {
  /// Estado desconocido (inicial)
  unknown('unknown'),

  /// Autenticado correctamente
  authenticated('authenticated'),

  /// No autenticado
  unauthenticated('unauthenticated'),

  /// En proceso de autenticación
  authenticating('authenticating'),

  /// Modo invitado (solo lectura)
  guest('guest'),

  /// Error de autenticación
  error('error'),

  /// Sesión expirada
  expired('expired'),

  /// Requiere verificación (2FA, email, etc.)
  requiresVerification('requires_verification'),

  /// Requiere cambio de contraseña
  requiresPasswordChange('requires_password_change'),

  /// Bloqueado (demasiados intentos)
  locked('locked'),

  /// Deshabilitado por administrador
  disabled('disabled');

  final String name;

  const AuthState(this.name);

  /// Verificar si el estado indica que el usuario está autenticado
  bool get isAuthenticated => this == AuthState.authenticated;

  /// Verificar si el estado indica que el usuario no está autenticado
  bool get isUnauthenticated => this == AuthState.unauthenticated;

  /// Verificar si el estado indica modo invitado
  bool get isGuest => this == AuthState.guest;

  /// Verificar si el estado indica error
  bool get isError => this == AuthState.error;

  /// Verificar si el estado requiere acción del usuario
  bool get requiresAction =>
      this == AuthState.requiresVerification ||
      this == AuthState.requiresPasswordChange;

  /// Verificar si el estado es bloqueante
  bool get isBlocking =>
      this == AuthState.locked ||
      this == AuthState.disabled ||
      this == AuthState.expired;

  /// Obtener estado desde nombre
  static AuthState fromName(String name) {
    for (final state in AuthState.values) {
      if (state.name == name) {
        return state;
      }
    }
    return AuthState.unknown;
  }

  /// Obtener descripción amigable para el usuario
  String get description {
    switch (this) {
      case AuthState.unknown:
        return 'Estado desconocido';
      case AuthState.authenticated:
        return 'Autenticado';
      case AuthState.unauthenticated:
        return 'No autenticado';
      case AuthState.authenticating:
        return 'Autenticando...';
      case AuthState.guest:
        return 'Modo invitado';
      case AuthState.error:
        return 'Error de autenticación';
      case AuthState.expired:
        return 'Sesión expirada';
      case AuthState.requiresVerification:
        return 'Requiere verificación';
      case AuthState.requiresPasswordChange:
        return 'Requiere cambio de contraseña';
      case AuthState.locked:
        return 'Cuenta bloqueada';
      case AuthState.disabled:
        return 'Cuenta deshabilitada';
    }
  }

  /// Obtener icono sugerido para el estado
  String get icon {
    switch (this) {
      case AuthState.authenticated:
        return 'check_circle';
      case AuthState.unauthenticated:
        return 'person_outline';
      case AuthState.authenticating:
        return 'hourglass_empty';
      case AuthState.guest:
        return 'person';
      case AuthState.error:
        return 'error_outline';
      case AuthState.expired:
        return 'timer_off';
      case AuthState.requiresVerification:
        return 'mark_email_read';
      case AuthState.requiresPasswordChange:
        return 'lock_reset';
      case AuthState.locked:
        return 'lock';
      case AuthState.disabled:
        return 'block';
      default:
        return 'help_outline';
    }
  }

  /// Obtener color sugerido para el estado
  String get color {
    switch (this) {
      case AuthState.authenticated:
        return 'success';
      case AuthState.unauthenticated:
        return 'secondary';
      case AuthState.authenticating:
        return 'info';
      case AuthState.guest:
        return 'primary';
      case AuthState.error:
        return 'error';
      case AuthState.expired:
        return 'warning';
      case AuthState.requiresVerification:
        return 'info';
      case AuthState.requiresPasswordChange:
        return 'warning';
      case AuthState.locked:
        return 'error';
      case AuthState.disabled:
        return 'error';
      default:
        return 'disabled';
    }
  }

  /// Verificar si se puede realizar una transición a otro estado
  bool canTransitionTo(AuthState targetState) {
    // Reglas de transición
    switch (this) {
      case AuthState.unknown:
        return targetState != AuthState.unknown;
      case AuthState.authenticated:
        return targetState != AuthState.authenticating;
      case AuthState.unauthenticated:
        return targetState != AuthState.unauthenticated;
      case AuthState.authenticating:
        return targetState == AuthState.authenticated ||
            targetState == AuthState.unauthenticated ||
            targetState == AuthState.error ||
            targetState == AuthState.requiresVerification;
      case AuthState.guest:
        return targetState == AuthState.authenticated ||
            targetState == AuthState.unauthenticated;
      case AuthState.error:
        return targetState == AuthState.unauthenticated ||
            targetState == AuthState.authenticating;
      case AuthState.expired:
        return targetState == AuthState.unauthenticated ||
            targetState == AuthState.authenticating;
      case AuthState.requiresVerification:
        return targetState == AuthState.authenticated ||
            targetState == AuthState.unauthenticated ||
            targetState == AuthState.error;
      case AuthState.requiresPasswordChange:
        return targetState == AuthState.authenticated ||
            targetState == AuthState.unauthenticated ||
            targetState == AuthState.error;
      case AuthState.locked:
        return targetState == AuthState.unauthenticated;
      case AuthState.disabled:
        return targetState == AuthState.unauthenticated;
    }
  }

  @override
  String toString() => 'AuthState.$name';
}

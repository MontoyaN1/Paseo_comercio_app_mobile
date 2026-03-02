import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/firebase_auth_service.dart';
import '../../../di/service_locator.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data != null) {
              // Usuario ya autenticado, redirigir a plazoletas
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/plazoletas');
              });
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                ),
              );
            }

            // Usuario no autenticado, mostrar formulario de login
            return const SingleChildScrollView(
              child: Padding(padding: EdgeInsets.all(24.0), child: LoginForm()),
            );
          },
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = getIt<FirebaseAuthService>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Colores del tema GTK/Gnome en dorado y negro
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color borderColor = Color(0xFF333333);
  static const Color textColor = Colors.white;
  static const Color hintTextColor = Color(0xFF888888);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      result.fold(
        (_) {
          // Éxito - la redirección se maneja en el StreamBuilder
        },
        (error) {
          setState(() {
            _errorMessage = error.toString();
          });
        },
      );
    } catch (error) {
      setState(() {
        _errorMessage = 'Error inesperado: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithGoogle();
      result.fold(
        (_) {
          // Éxito - la redirección se maneja en el StreamBuilder
        },
        (error) {
          setState(() {
            _errorMessage = error.toString();
          });
        },
      );
    } catch (error) {
      setState(() {
        _errorMessage = 'Error inesperado: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        nombre: _emailController.text.split('@').first,
      );

      result.fold(
        (_) {
          // Éxito - la redirección se maneja en el StreamBuilder
        },
        (error) {
          setState(() {
            _errorMessage = error.toString();
          });
        },
      );
    } catch (error) {
      setState(() {
        _errorMessage = 'Error inesperado: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage =
            'Por favor ingresa tu email para restablecer la contraseña';
      });
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: surfaceColor,
            surfaceTintColor: primaryGold,
            title: Text(
              'Restablecer contraseña',
              style: TextStyle(color: textColor),
            ),
            content: Text(
              '¿Enviar email de restablecimiento a $email?',
              style: TextStyle(color: hintTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: hintTextColor),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });

                  try {
                    final result = await _authService.resetPassword(email);
                    result.fold(
                      (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: primaryGold,
                            content: Text(
                              'Email de restablecimiento enviado',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      },
                      (error) {
                        setState(() {
                          _errorMessage = error.toString();
                        });
                      },
                    );
                  } catch (error) {
                    setState(() {
                      _errorMessage = 'Error inesperado: $error';
                    });
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Enviar', style: TextStyle(color: primaryGold)),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Encabezado elegante
        Column(
          children: [
            // Logo redondeado
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(50), // Círculo perfecto
                border: Border.all(color: primaryGold, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: primaryGold.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(45), // Redondeado interno
                  child: Image.asset(
                    'assets/icons/favicon.jpeg',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.storefront,
                        size: 50,
                        color: primaryGold,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Título principal con fuentes personalizadas
            Column(
              children: [
                // "Paseo" en Optima
                Text(
                  'Paseo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: primaryGold,
                    fontFamily: 'Optima',
                    letterSpacing: 1,
                    shadows: [
                      Shadow(
                        color: primaryGold.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                // "del comercio" en Poppins
                Text(
                  'del comercio',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: hintTextColor,
                    fontFamily: 'Poppins',
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Subtítulo
            Text(
              'Centro Comercial Virtual',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: hintTextColor.withOpacity(0.8),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),

        // Formulario de login
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Campo de email
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: hintTextColor),
                    prefixIcon: Icon(Icons.email, color: primaryGold),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryGold, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    if (!value.contains('@')) {
                      return 'Email no válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo de contraseña
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: textColor),
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: hintTextColor),
                    prefixIcon: Icon(Icons.lock, color: primaryGold),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: hintTextColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryGold, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Mensaje de error
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[300]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red[300],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_errorMessage != null) const SizedBox(height: 20),

                // Botón de login
                ElevatedButton(
                  onPressed: _isLoading ? null : _signInWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: primaryGold.withOpacity(0.5),
                  ),
                  child:
                      _isLoading
                          ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                          : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              'INICIAR SESIÓN',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                ),
                const SizedBox(height: 16),

                // Botón de registro
                OutlinedButton(
                  onPressed: _isLoading ? null : _signUpWithEmail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGold,
                    side: BorderSide(color: primaryGold, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'CREAR CUENTA',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Separador elegante
                Row(
                  children: [
                    Expanded(child: Divider(color: borderColor, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'O continúa con',
                        style: TextStyle(color: hintTextColor, fontSize: 14),
                      ),
                    ),
                    Expanded(child: Divider(color: borderColor, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 24),

                // Botón de Google con estilo GTK
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.asset(
                      'assets/images/google_logo.png',
                      errorBuilder:
                          (context, error, stackTrace) =>
                              Icon(Icons.g_mobiledata, color: primaryGold),
                    ),
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Google',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: surfaceColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Enlace para restablecer contraseña
                TextButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: primaryGold,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        decorationColor: primaryGold.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Footer
        const SizedBox(height: 40),
        Align(
          alignment: Alignment.center,
          child: Text(
            '© 2026 Paseo del Comercio',
            style: TextStyle(color: hintTextColor, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

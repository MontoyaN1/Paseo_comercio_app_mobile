import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/firebase_auth_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../../di/service_locator.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Login',
        showBackButton: true,
        showProfileButton: false,
      ),
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData && snapshot.data != null) {
              // Usuario ya autenticado, redirigir a plazoletas
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/plazoletas');
              });
              return const Center(child: CircularProgressIndicator());
            }

            // Usuario no autenticado, mostrar formulario de login
            return const Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: LoginForm(),
              ),
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
  String? _errorMessage;

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

  Future<void> _signInAsGuest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInAsGuest();
      result.fold(
        (_) {
          // Éxito - redirigir a plazoletas
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/plazoletas');
          });
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
            title: const Text('Restablecer contraseña'),
            content: Text('¿Enviar email de restablecimiento a $email?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
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
                          const SnackBar(
                            content: Text('Email de restablecimiento enviado'),
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
                child: const Text('Enviar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Logo o icono
        const Icon(Icons.storefront, size: 80, color: Colors.blue),
        const SizedBox(height: 24),

        // Título
        const Text(
          'Paseo del Comercio',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF121212),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Centro Comercial Virtual',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 32),

        // Formulario de login
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
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
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Mensaje de error
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red[800]),
              textAlign: TextAlign.center,
            ),
          ),

        if (_errorMessage != null) const SizedBox(height: 16),

        // Botón de login con email
        ElevatedButton(
          onPressed: _isLoading ? null : _signInWithEmail,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('Iniciar sesión'),
        ),
        const SizedBox(height: 12),

        // Botón de registro
        OutlinedButton(
          onPressed: _isLoading ? null : _signUpWithEmail,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Crear cuenta'),
        ),
        const SizedBox(height: 12),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'O continuar con',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 12),

        // Botón de Google
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _signInWithGoogle,
          icon: Image.asset(
            'assets/images/google_logo.png',
            height: 24,
            width: 24,
            errorBuilder:
                (context, error, stackTrace) =>
                    const Icon(Icons.g_mobiledata, color: Colors.red),
          ),
          label: const Text('Google'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Botón de invitado
        TextButton(
          onPressed: _isLoading ? null : _signInAsGuest,
          child: const Text('Continuar como invitado'),
        ),
        const SizedBox(height: 12),

        // Enlace para restablecer contraseña
        TextButton(
          onPressed: _isLoading ? null : _resetPassword,
          child: const Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

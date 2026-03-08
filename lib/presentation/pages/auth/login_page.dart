// lib/presentation/pages/auth/login_page.dart
//
// 🏛️  PLAZA UNIVERSE — Login de Lujo
// ────────────────────────────────────────────────────────────
//  ANIMACIONES:
//  • Fondo: partículas isométricas flotantes + haces de luz
//  • Entrada: logo cae desde arriba con rebote elástico
//  • Título: letras aparecen una por una (typewriter dorado)
//  • Card del formulario: sube desde abajo con fade
//  • Campos: se iluminan al focus con glow dorado
//  • Botones: scale + shimmer al hover/press
//  • Error: shake horizontal animado
//  • Loading: spinner con trazo dorado pulsante
// ────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/firebase_auth_service.dart';
import '../../../di/service_locator.dart';

// ── Paleta ────────────────────────────────────────────────────
const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kBg = Color(0xFF07070F);
const _kSurface = Color(0xFF0F0F1E);
const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);

// ══════════════════════════════════════════════════════════════
//  PAGE WRAPPER — escucha auth state
// ══════════════════════════════════════════════════════════════
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _FullScreenLoader();
          }
          if (snapshot.hasData && snapshot.data != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/plazoletas');
            });
            return const _FullScreenLoader();
          }
          return const _LoginScreen();
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PANTALLA DE LOGIN — con todas las animaciones
// ══════════════════════════════════════════════════════════════
class _LoginScreen extends StatefulWidget {
  const _LoginScreen();

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen>
    with TickerProviderStateMixin {
  // ── Controladores de animación ─────────────────────────────
  late final AnimationController _bgCtrl; // fondo continuo
  late final AnimationController _introCtrl; // entrada orquestada
  late final AnimationController _logoCtrl; // logo elástico
  late final AnimationController _titleCtrl; // typewriter
  late final AnimationController _cardCtrl; // card sube
  late final AnimationController _shakeCtrl; // shake error
  late final AnimationController _shimmerCtrl; // shimmer botón

  // ── Animaciones derivadas ──────────────────────────────────
  late final Animation<double> _logoY;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _cardSlide;
  late final Animation<double> _cardOpacity;
  late final Animation<double> _shakeX;

  // ── Form state ────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = getIt<FirebaseAuthService>();
  bool _isLoading = false;
  bool _obscurePass = true;
  String? _errorMessage;
  bool _emailFocused = false;
  bool _passFocused = false;

  @override
  void initState() {
    super.initState();

    // Fondo animado continuo
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    // Shimmer continuo en botón
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Shake de error
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.linear));

    // Logo: cae desde arriba con rebote elástico
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoY = Tween<double>(
      begin: -120,
      end: 0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.3)),
    );

    // Título typewriter (lo controla el builder con el valor)
    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Card sube desde abajo
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardSlide = Tween<double>(
      begin: 80,
      end: 0,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardCtrl, curve: const Interval(0, 0.6)),
    );

    // Secuencia de entrada
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _startIntro();
  }

  Future<void> _startIntro() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _titleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _cardCtrl.forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _introCtrl.dispose();
    _logoCtrl.dispose();
    _titleCtrl.dispose();
    _cardCtrl.dispose();
    _shakeCtrl.dispose();
    _shimmerCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Acciones ──────────────────────────────────────────────
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _authService.signInWithEmail(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      result.fold((_) {}, (err) => _showError(err.toString()));
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _authService.signUpWithEmail(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
        nombre: _emailCtrl.text.split('@').first,
      );
      result.fold((_) {}, (err) => _showError(err.toString()));
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _authService.signInWithGoogle();
      result.fold((_) {}, (err) => _showError(err.toString()));
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    setState(() => _errorMessage = msg);
    _shakeCtrl.forward(from: 0);
  }

  void _resetPassword() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showError('Ingresa tu email primero');
      return;
    }
    showDialog(
      context: context,
      builder:
          (_) => _ResetDialog(
            email: email,
            authService: _authService,
            onError: _showError,
          ),
    );
  }

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Fondo animado ──────────────────────────────────────
        AnimatedBuilder(
          animation: _bgCtrl,
          builder:
              (_, __) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _BgPainter(_bgCtrl.value),
              ),
        ),

        // ── Contenido ─────────────────────────────────────────
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 48),

                // ── Logo con animación elástica ────────────────
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder:
                      (_, __) => Opacity(
                        opacity: _logoOpacity.value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, _logoY.value),
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: const _LogoWidget(),
                          ),
                        ),
                      ),
                ),

                const SizedBox(height: 28),

                // ── Título con typewriter ──────────────────────
                AnimatedBuilder(
                  animation: _titleCtrl,
                  builder: (_, __) => _TitleWidget(progress: _titleCtrl.value),
                ),

                const SizedBox(height: 36),

                // ── Card del formulario ────────────────────────
                AnimatedBuilder(
                  animation: _cardCtrl,
                  builder:
                      (_, __) => Opacity(
                        opacity: _cardOpacity.value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, _cardSlide.value),
                          child: AnimatedBuilder(
                            animation: _shakeCtrl,
                            builder:
                                (_, child) => Transform.translate(
                                  offset: Offset(_shakeX.value, 0),
                                  child: child,
                                ),
                            child: _FormCard(
                              formKey: _formKey,
                              emailCtrl: _emailCtrl,
                              passwordCtrl: _passwordCtrl,
                              isLoading: _isLoading,
                              obscurePass: _obscurePass,
                              errorMessage: _errorMessage,
                              emailFocused: _emailFocused,
                              passFocused: _passFocused,
                              shimmerCtrl: _shimmerCtrl,
                              onTogglePass:
                                  () => setState(
                                    () => _obscurePass = !_obscurePass,
                                  ),
                              onEmailFocus:
                                  (v) => setState(() => _emailFocused = v),
                              onPassFocus:
                                  (v) => setState(() => _passFocused = v),
                              onSignIn: _signIn,
                              onSignUp: _signUp,
                              onGoogle: _googleSignIn,
                              onReset: _resetPassword,
                            ),
                          ),
                        ),
                      ),
                ),

                const SizedBox(height: 36),

                // ── Footer ────────────────────────────────────
                AnimatedBuilder(
                  animation: _cardCtrl,
                  builder:
                      (_, __) => Opacity(
                        opacity: (_cardOpacity.value * 0.7).clamp(0.0, 1.0),
                        child: Text(
                          '© 2026 Paseo del Comercio',
                          style: TextStyle(
                            color: _kHint.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  FONDO: partículas isométricas + claraboya
// ══════════════════════════════════════════════════════════════
class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  static final _rng = math.Random(42);
  static final _particles = List.generate(
    60,
    (i) => [
      _rng.nextDouble(), // x relativo
      _rng.nextDouble(), // y relativo
      _rng.nextDouble() * 0.6 + 0.2, // fase
      _rng.nextDouble() * 2.5 + 0.5, // radio
      _rng.nextInt(3).toDouble(), // color idx
    ],
  );

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Fondo base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.4),
          radius: 1.0,
          colors: [const Color(0xFF111128), const Color(0xFF09091A), _kBg],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Haz de luz cenital suave
    final beamOp = math.sin(t * math.pi * 2) * 0.04 + 0.10;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.35, 0)
        ..lineTo(w * 0.65, 0)
        ..lineTo(w * 0.80, h * 0.65)
        ..lineTo(w * 0.20, h * 0.65)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kGoldLight.withOpacity(beamOp), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.65)),
    );

    // Rombos isométricos decorativos (mini tiles del mall)
    final tileAlpha = 0.06;
    final tW = w * 0.18;
    final tH = tW * 0.5;
    for (int row = -1; row <= 9; row++) {
      for (int col = -1; col <= 6; col++) {
        final cx = (col - row) * tW / 2 + w * 0.5;
        final cy = (col + row) * tH / 2 - t * tH * 0.5;
        final pulse = math.sin(t * math.pi * 2 + col * 0.4 + row * 0.3) * 0.015;
        final alpha = (tileAlpha + pulse).clamp(0.0, 0.12);
        // Cara superior del tile isométrico
        final path =
            Path()
              ..moveTo(cx, cy - tH / 2)
              ..lineTo(cx + tW / 2, cy)
              ..lineTo(cx, cy + tH / 2)
              ..lineTo(cx - tW / 2, cy)
              ..close();
        canvas.drawPath(
          path,
          Paint()
            ..color = _kGold.withOpacity(alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6,
        );
        // Cara lateral (sombra)
        if (row % 3 == 0) {
          canvas.drawPath(
            path,
            Paint()..color = _kGold.withOpacity(alpha * 0.25),
          );
        }
      }
    }

    // Partículas de luz flotante
    const colors = [_kGold, _kGoldLight, Colors.white];
    for (final p in _particles) {
      final phase = (t + p[2]) % 1.0;
      final op = math.sin(phase * math.pi) * 0.35;
      if (op <= 0) continue;
      final px = p[0] * w;
      final py = p[1] * h - phase * h * 0.22;
      canvas.drawCircle(
        Offset(px, py),
        p[3],
        Paint()
          ..color = colors[p[4].toInt()].withOpacity(op)
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, p[3] * 1.2),
      );
    }

    // Viñeta perimetral
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.78,
          colors: [Colors.transparent, Colors.black.withOpacity(0.70)],
          stops: const [0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Líneas de estructura dorada
    final linePaint =
        Paint()
          ..color = _kGold.withOpacity(0.04)
          ..strokeWidth = 0.7;
    for (int i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(w * i / 5, 0),
        Offset(w * 0.5, h * 0.5),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_BgPainter o) => o.t != t;
}

// ══════════════════════════════════════════════════════════════
//  LOGO ANIMADO
// ══════════════════════════════════════════════════════════════
class _LogoWidget extends StatelessWidget {
  const _LogoWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Anillo de glow exterior
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _kGold.withOpacity(0.35),
                blurRadius: 28,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: _kGold.withOpacity(0.15),
                blurRadius: 56,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1E38), Color(0xFF0C0C1E)],
              ),
              border: Border.all(color: _kGold.withOpacity(0.70), width: 1.8),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/icons/favicon.jpeg',
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const Icon(
                      Icons.storefront_rounded,
                      size: 52,
                      color: _kGold,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TÍTULO CON EFECTO TYPEWRITER DORADO
// ══════════════════════════════════════════════════════════════
class _TitleWidget extends StatelessWidget {
  final double progress;
  const _TitleWidget({required this.progress});

  @override
  Widget build(BuildContext context) {
    const line1 = 'Paseo';
    const line2 = 'del comercio';
    const sub = 'Centro Comercial Virtual';

    // Typewriter: cada carácter aparece en secuencia
    final totalChars = line1.length + line2.length;
    final charsVisible =
        (progress * totalChars * 1.3).clamp(0, totalChars.toDouble()).toInt();

    final l1visible = charsVisible.clamp(0, line1.length);
    final l2visible = (charsVisible - line1.length).clamp(0, line2.length);
    final subOpacity = ((progress - 0.75) * 4).clamp(0.0, 1.0);
    final cursorOpacity = progress < 0.98 ? 1.0 : 0.0;

    return Column(
      children: [
        // Línea 1: "Paseo" con cursor
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback:
                  (b) => const LinearGradient(
                    colors: [_kGoldDeep, _kGold, _kGoldLight, _kGold],
                    stops: [0.0, 0.3, 0.6, 1.0],
                  ).createShader(b),
              child: Text(
                line1.substring(0, l1visible),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Optima',
                  letterSpacing: 2,
                ),
              ),
            ),
            // Cursor parpadeante mientras escribe línea 1
            if (l1visible < line1.length)
              Opacity(
                opacity: cursorOpacity,
                child: Container(
                  width: 2,
                  height: 36,
                  margin: const EdgeInsets.only(left: 2),
                  color: _kGold,
                ),
              ),
          ],
        ),

        // Línea 2: "del comercio"
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: l2visible > 0 ? 1.0 : 0.0,
              child: Text(
                line2.substring(0, l2visible),
                style: TextStyle(
                  color: _kHint,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Poppins',
                  letterSpacing: 1.5,
                ),
              ),
            ),
            // Cursor en línea 2
            if (l1visible >= line1.length && l2visible < line2.length)
              Opacity(
                opacity: cursorOpacity,
                child: Container(
                  width: 1.5,
                  height: 22,
                  margin: const EdgeInsets.only(left: 1),
                  color: _kHint,
                ),
              ),
          ],
        ),

        const SizedBox(height: 6),

        // Subtítulo con fade + separador dorado
        AnimatedOpacity(
          opacity: subOpacity,
          duration: const Duration(milliseconds: 400),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 1,
                    color: _kGold.withOpacity(0.4),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    sub,
                    style: TextStyle(
                      color: _kHint.withOpacity(0.75),
                      fontSize: 12,
                      letterSpacing: 2.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 24,
                    height: 1,
                    color: _kGold.withOpacity(0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CARD DEL FORMULARIO
// ══════════════════════════════════════════════════════════════
class _FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl, passwordCtrl;
  final bool isLoading, obscurePass, emailFocused, passFocused;
  final String? errorMessage;
  final AnimationController shimmerCtrl;
  final VoidCallback onTogglePass, onSignIn, onSignUp, onGoogle, onReset;
  final ValueChanged<bool> onEmailFocus, onPassFocus;

  const _FormCard({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.isLoading,
    required this.obscurePass,
    required this.errorMessage,
    required this.emailFocused,
    required this.passFocused,
    required this.shimmerCtrl,
    required this.onTogglePass,
    required this.onEmailFocus,
    required this.onPassFocus,
    required this.onSignIn,
    required this.onSignUp,
    required this.onGoogle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: _kSurface.withOpacity(0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _kBorder, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 40,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: _kGold.withOpacity(0.06),
                blurRadius: 60,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Campo email ──────────────────────────────
                _AnimatedField(
                  controller: emailCtrl,
                  label: 'Correo electrónico',
                  icon: Icons.alternate_email_rounded,
                  isFocused: emailFocused,
                  onFocusChange: onEmailFocus,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu email';
                    if (!v.contains('@')) return 'Email no válido';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── Campo contraseña ─────────────────────────
                _AnimatedField(
                  controller: passwordCtrl,
                  label: 'Contraseña',
                  icon: Icons.lock_outline_rounded,
                  isFocused: passFocused,
                  onFocusChange: onPassFocus,
                  obscureText: obscurePass,
                  suffixIcon: GestureDetector(
                    onTap: onTogglePass,
                    child: Icon(
                      obscurePass
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _kHint,
                      size: 20,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── Mensaje de error ─────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child:
                      errorMessage != null
                          ? Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.red[300],
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red[300],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : const SizedBox.shrink(),
                ),

                // ── Botón INICIAR SESIÓN (shimmer) ───────────
                _ShimmerButton(
                  label: 'INICIAR SESIÓN',
                  isLoading: isLoading,
                  shimmerCtrl: shimmerCtrl,
                  onTap: onSignIn,
                ),

                const SizedBox(height: 12),

                // ── Botón CREAR CUENTA (outline) ─────────────
                _OutlineActionButton(
                  label: 'CREAR CUENTA',
                  isLoading: isLoading,
                  onTap: onSignUp,
                ),

                const SizedBox(height: 22),

                // ── Separador ────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, _kBorder],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'o continúa con',
                        style: TextStyle(
                          color: _kHint,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_kBorder, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ── Botón Google ─────────────────────────────
                _GoogleButton(isLoading: isLoading, onTap: onGoogle),

                const SizedBox(height: 18),

                // ── Olvidé contraseña ─────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: isLoading ? null : onReset,
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: _kGold.withOpacity(0.75),
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: _kGold.withOpacity(0.35),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CAMPO CON GLOW ANIMADO AL FOCUS
// ══════════════════════════════════════════════════════════════
class _AnimatedField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isFocused;
  final ValueChanged<bool> onFocusChange;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _AnimatedField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isFocused,
    required this.onFocusChange,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  State<_AnimatedField> createState() => _AnimatedFieldState();
}

class _AnimatedFieldState extends State<_AnimatedField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _focusCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _focusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _glowAnim = CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(_AnimatedField old) {
    super.didUpdateWidget(old);
    if (widget.isFocused != old.isFocused) {
      widget.isFocused ? _focusCtrl.forward() : _focusCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _focusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder:
          (_, child) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withOpacity(0.22 * _glowAnim.value),
                  blurRadius: 16 * _glowAnim.value + 1,
                  spreadRadius: _glowAnim.value * 1.5,
                ),
              ],
            ),
            child: child,
          ),
      child: Focus(
        onFocusChange: widget.onFocusChange,
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: widget.isFocused ? _kGold.withOpacity(0.9) : _kHint,
              fontSize: 13,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(
                widget.icon,
                color: widget.isFocused ? _kGold : _kHint,
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon:
                widget.suffixIcon != null
                    ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: widget.suffixIcon,
                    )
                    : null,
            filled: true,
            fillColor: Colors.black.withOpacity(0.28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kBorder, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kGold, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.withOpacity(0.7)),
            ),
            errorStyle: const TextStyle(fontSize: 11),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BOTÓN CON EFECTO SHIMMER DORADO
// ══════════════════════════════════════════════════════════════
class _ShimmerButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final AnimationController shimmerCtrl;
  final VoidCallback onTap;

  const _ShimmerButton({
    required this.label,
    required this.isLoading,
    required this.shimmerCtrl,
    required this.onTap,
  });

  @override
  State<_ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<_ShimmerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressScale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressCtrl, widget.shimmerCtrl]),
        builder:
            (_, __) => Transform.scale(
              scale: _pressScale.value,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _kGold.withOpacity(0.38),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      // Base dorada
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_kGoldDeep, _kGold, _kGoldLight, _kGold],
                            stops: [0.0, 0.35, 0.65, 1.0],
                          ),
                        ),
                      ),
                      // Barrido de shimmer
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: widget.shimmerCtrl,
                          builder: (_, __) {
                            final x = widget.shimmerCtrl.value * 2 - 0.5;
                            return FractionallySizedBox(
                              widthFactor: 0.35,
                              alignment: Alignment(x * 2 - 1, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0),
                                      Colors.white.withOpacity(0.22),
                                      Colors.white.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Contenido
                      Center(
                        child:
                            widget.isLoading
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.black,
                                    ),
                                  ),
                                )
                                : Text(
                                  widget.label,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BOTÓN OUTLINE CON PRESS SCALE
// ══════════════════════════════════════════════════════════════
class _OutlineActionButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _OutlineActionButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_OutlineActionButton> createState() => _OutlineActionButtonState();
}

class _OutlineActionButtonState extends State<_OutlineActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        _ctrl.reverse();
        setState(() => _pressed = false);
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () {
        _ctrl.reverse();
        setState(() => _pressed = false);
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _pressed ? _kGold : _kGold.withOpacity(0.55),
                    width: 1.5,
                  ),
                  color:
                      _pressed ? _kGold.withOpacity(0.08) : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: _kGold,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BOTÓN GOOGLE
// ══════════════════════════════════════════════════════════════
class _GoogleButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _GoogleButton({required this.isLoading, required this.onTap});

  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E1E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kBorder, width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Image.asset(
                        'assets/images/google_logo.png',
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.g_mobiledata_rounded,
                              color: _kGold,
                              size: 22,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Continuar con Google',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  DIÁLOGO RESET PASSWORD
// ══════════════════════════════════════════════════════════════
class _ResetDialog extends StatelessWidget {
  final String email;
  final FirebaseAuthService authService;
  final ValueChanged<String> onError;

  const _ResetDialog({
    required this.email,
    required this.authService,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _kSurface,
      surfaceTintColor: _kGold,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.lock_reset_rounded, color: _kGold, size: 20),
          const SizedBox(width: 10),
          const Text(
            'Restablecer contraseña',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: Text(
        '¿Enviar email de restablecimiento a\n$email?',
        style: const TextStyle(color: _kHint, fontSize: 14, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: _kHint)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            try {
              final result = await authService.resetPassword(email);
              result.fold((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: _kGold,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      content: const Text(
                        'Email enviado ✓',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }
              }, (err) => onError(err.toString()));
            } catch (e) {
              onError('Error: $e');
            }
          },
          child: const Text(
            'Enviar',
            style: TextStyle(color: _kGold, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  LOADER PANTALLA COMPLETA
// ══════════════════════════════════════════════════════════════
class _FullScreenLoader extends StatelessWidget {
  const _FullScreenLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kBg,
      child: const Center(
        child: SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(_kGold),
          ),
        ),
      ),
    );
  }
}

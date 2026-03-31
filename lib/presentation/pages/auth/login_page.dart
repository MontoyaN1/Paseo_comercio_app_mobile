// lib/presentation/pages/auth/login_page.dart
//
// 🏛️  PLAZA UNIVERSE — Login de Lujo
// ────────────────────────────────────────────────────────────
//  Fragmentado: widgets extraídos a lib/presentation/widgets/auth/
//  USA Theme.of(context) para colores de UI genéricos
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/firebase_auth_service.dart';
import '../../../di/service_locator.dart';
import '../../widgets/auth/login_bg_painter.dart';
import '../../widgets/auth/login_card.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoginLoader();
          }
          if (snapshot.hasData && snapshot.data != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/plazoletas');
            });
            return const LoginLoader();
          }
          return const _LoginScreen();
        },
      ),
    );
  }
}

class _LoginScreen extends StatefulWidget {
  const _LoginScreen();

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _introCtrl;
  late final AnimationController _logoCtrl;
  late final AnimationController _titleCtrl;
  late final AnimationController _cardCtrl;
  late final AnimationController _shakeCtrl;
  late final AnimationController _shimmerCtrl;

  late final Animation<double> _logoY;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _cardSlide;
  late final Animation<double> _cardOpacity;
  late final Animation<double> _shakeX;

  final _authService = getIt<FirebaseAuthService>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

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

    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

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
    super.dispose();
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _authService.signInWithGoogle();
      result.fold((_) {}, (err) {
        final message = err.toString();
        if (message.contains('cancelado') || message.contains('cancelled')) {
          _showInfo('Inicio de sesión cancelado');
        } else {
          _showError(message);
        }
      });
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _microsoftSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _authService.signInWithMicrosoft();
      result.fold((_) {}, (err) {
        final message = err.toString();
        if (message.contains('cancelado') ||
            message.contains('cancelled') ||
            message.contains('web-context')) {
          _showInfo('Inicio de sesión cancelado');
        } else {
          _showError(message);
        }
      });
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showInfo(String msg) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kGold : theme.colorScheme.primary;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: accentColor.withOpacity(0.3)),
        ),
      ),
    );
  }

  void _showError(String msg) {
    setState(() => _errorMessage = msg);
    _shakeCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _bgCtrl,
          builder:
              (_, __) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: LoginBgPainter(_bgCtrl.value, theme.brightness),
              ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 48),
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
                AnimatedBuilder(
                  animation: _titleCtrl,
                  builder: (_, __) => _TitleWidget(progress: _titleCtrl.value),
                ),
                const SizedBox(height: 36),
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
                            child: LoginCard(
                              isLoading: _isLoading,
                              errorMessage: _errorMessage,
                              onGoogle: _googleSignIn,
                              onMicrosoft: _microsoftSignIn,
                            ),
                          ),
                        ),
                      ),
                ),
                const SizedBox(height: 36),
                AnimatedBuilder(
                  animation: _cardCtrl,
                  builder:
                      (_, __) => Opacity(
                        opacity: (_cardOpacity.value * 0.7).clamp(0.0, 1.0),
                        child: Text(
                          '© 2026 Paseo del Comercio',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.5),
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

class _LogoWidget extends StatelessWidget {
  const _LogoWidget();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kGold : theme.colorScheme.primary;

    return Column(
      children: [
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.35),
                blurRadius: 28,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: accentColor.withOpacity(0.15),
                blurRadius: 56,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isDark
                        ? [const Color(0xFF1E1E38), const Color(0xFF0C0C1E)]
                        : [
                          theme.colorScheme.surfaceContainerHighest,
                          theme.colorScheme.surface,
                        ],
              ),
              border: Border.all(
                color: accentColor.withOpacity(0.70),
                width: 1.8,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/icons/favicon.jpeg',
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Icon(
                      Icons.storefront_rounded,
                      size: 52,
                      color: accentColor,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TitleWidget extends StatelessWidget {
  final double progress;
  const _TitleWidget({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kGold : theme.colorScheme.primary;
    final hintColor =
        isDark ? const Color(0xFF6B6B8A) : theme.colorScheme.onSurfaceVariant;

    const line1 = 'Paseo';
    const line2 = 'del comercio';
    const sub = 'Centro Comercial Virtual';

    final totalChars = line1.length + line2.length;
    final charsVisible =
        (progress * totalChars * 1.3).clamp(0, totalChars.toDouble()).toInt();

    final l1visible = charsVisible.clamp(0, line1.length);
    final l2visible = (charsVisible - line1.length).clamp(0, line2.length);
    final subOpacity = ((progress - 0.75) * 4).clamp(0.0, 1.0);
    final cursorOpacity = progress < 0.98 ? 1.0 : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback:
                  (b) =>
                      isDark
                          ? const LinearGradient(
                            colors: [_kGoldDeep, _kGold, _kGoldLight, _kGold],
                            stops: [0.0, 0.3, 0.6, 1.0],
                          ).createShader(b)
                          : LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
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
            if (l1visible < line1.length)
              Opacity(
                opacity: cursorOpacity,
                child: Container(
                  width: 2,
                  height: 36,
                  margin: const EdgeInsets.only(left: 2),
                  color: accentColor,
                ),
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: l2visible > 0 ? 1.0 : 0.0,
              child: Text(
                line2.substring(0, l2visible),
                style: TextStyle(
                  color: hintColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Poppins',
                  letterSpacing: 1.5,
                ),
              ),
            ),
            if (l1visible >= line1.length && l2visible < line2.length)
              Opacity(
                opacity: cursorOpacity,
                child: Container(
                  width: 1.5,
                  height: 22,
                  margin: const EdgeInsets.only(left: 1),
                  color: hintColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
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
                    color: accentColor.withOpacity(0.4),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    sub,
                    style: TextStyle(
                      color: hintColor.withOpacity(0.75),
                      fontSize: 12,
                      letterSpacing: 2.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 24,
                    height: 1,
                    color: accentColor.withOpacity(0.4),
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

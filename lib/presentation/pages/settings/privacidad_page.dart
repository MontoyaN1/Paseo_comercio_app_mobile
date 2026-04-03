// lib/presentation/pages/settings/privacidad_page.dart

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';

const Color _kGold = Color(0xFFD4AF37);
const Color _kGoldLight = Color(0xFFFFE082);

class PrivacidadPage extends StatelessWidget {
  const PrivacidadPage({super.key});

  Future<String> _loadMarkdown() async {
    return await rootBundle.loadString('assets/legal/privacidad.md');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: FutureBuilder<String>(
                    future: _loadMarkdown(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(color: _kGold),
                        );
                      }
                      return _buildMarkdownContent(context, snapshot.data!);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownContent(BuildContext context, String data) {
    final theme = Theme.of(context);
    return Markdown(
      data: data,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      physics: const BouncingScrollPhysics(),
      styleSheet: MarkdownStyleSheet(
        h1: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        h2: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        p: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 13,
          height: 1.6,
        ),
        listBullet: TextStyle(color: _kGold),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark
            ? theme.colorScheme.surface.withValues(alpha: 0.82)
            : Colors.white.withValues(alpha: 0.90);

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.outline, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _GoldIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () {
                  try {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      Future.microtask(() => context.go('/plazoletas'));
                    }
                  } catch (e) {
                    Future.microtask(() => context.go('/'));
                  }
                },
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [_kGold, _kGold, _kGoldLight],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(bounds),
                  child: Text(
                    'Política de privacidad',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoldIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GoldIconButton({required this.icon, required this.onTap});

  @override
  State<_GoldIconButton> createState() => _GoldIconButtonState();
}

class _GoldIconButtonState extends State<_GoldIconButton>
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
      end: 0.88,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kGold : theme.colorScheme.primary;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: accentColor, size: 20),
              ),
            ),
      ),
    );
  }
}

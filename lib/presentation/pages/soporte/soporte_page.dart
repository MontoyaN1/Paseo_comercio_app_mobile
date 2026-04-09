// lib/presentation/pages/soporte/soporte_page.dart

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app/app_config.dart';

const Color _kGold = Color(0xFFD4AF37);
const Color _kGoldLight = Color(0xFFFFE082);
const Color _kGoldDeep = Color(0xFF9C7A1A);

class SoportePage extends StatelessWidget {
  const SoportePage({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = AppConfig();
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
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    children: [
                      const SizedBox(height: 32),
                      _buildHeader(context, appConfig),
                      const SizedBox(height: 32),
                      _buildSupportSection(appConfig),
                      const SizedBox(height: 24),
                      _buildSocialSection(appConfig),
                      const SizedBox(height: 24),
                      _buildAppInfoSection(appConfig),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
                      (b) => const LinearGradient(
                        colors: [_kGoldDeep, _kGold, _kGoldLight],
                      ).createShader(b),
                  child: Text(
                    'Soporte',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppConfig appConfig) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const SweepGradient(
              colors: [_kGoldDeep, _kGold, _kGoldLight, _kGold, _kGoldDeep],
            ),
            boxShadow: [
              BoxShadow(
                color: _kGold.withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF07070F) : Colors.white,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/icons/favicon.jpeg',
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) =>
                      const Icon(Icons.store_rounded, color: _kGold, size: 36),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Paseo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: _kGold,
                fontFamily: 'Optima',
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'del comercio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontFamily: 'Poppins',
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Centro Comercial Virtual',
          style: TextStyle(
            color: isDark ? const Color(0xFF6B6B8A) : Colors.grey[500],
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(AppConfig appConfig) {
    return _GlassSection(
      title: 'Soporte',
      icon: Icons.support_agent_rounded,
      child: Column(
        children: [
          _SocialTile(
            icon: SimpleIcons.whatsapp,
            title: 'WhatsApp',
            subtitle: 'Escríbenos directamente',
            backgroundColor: const Color(0xFF25D366),
            iconColor: Colors.white,
            onTap: () {
              try {
                _launchUrl(appConfig.whatsappSoporteUrl);
              } catch (e) {
                // Handle error silently
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection(AppConfig appConfig) {
    return _GlassSection(
      title: 'Síguenos',
      icon: Icons.public_rounded,
      child: Column(
        children: [
          _SocialTile(
            icon: SimpleIcons.instagram,
            title: 'Instagram',
            subtitle: '@paseodelcomercio.ccv',
            backgroundColor: const Color(0xFFE4405F),
            iconColor: Colors.white,
            onTap: () {
              try {
                _launchUrl(appConfig.instagramUrl);
              } catch (e) {
                // Handle error silently
              }
            },
          ),
          const _SectionDivider(),
          _SocialTile(
            icon: SimpleIcons.tiktok,
            title: 'TikTok',
            subtitle: '@paseodelcomercio.ccv',
            backgroundColor: Colors.black,
            iconColor: Colors.white,
            onTap: () {
              try {
                _launchUrl(appConfig.tiktokUrl);
              } catch (e) {
                // Handle error silently
              }
            },
          ),
          const _SectionDivider(),
          _SocialTile(
            icon: SimpleIcons.youtube,
            title: 'YouTube',
            subtitle: '@PaseodelComercio',
            backgroundColor: const Color(0xFFFF0000),
            iconColor: Colors.white,
            onTap: () {
              try {
                _launchUrl(appConfig.youtubeUrl);
              } catch (e) {
                // Handle error silently
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection(AppConfig appConfig) {
    return _GlassSection(
      title: 'Información',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _InfoRow(label: 'Versión', value: appConfig.appVersion),
          const _SectionDivider(),
          _InfoRow(
            label: 'Sitio web',
            value: appConfig.companyUrl,
            isLink: true,
            onTap: () {
              try {
                _launchUrl(appConfig.companyUrl);
              } catch (e) {
                // Handle error silently
              }
            },
          ),
        ],
      ),
    );
  }
}

class _GlassSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _GlassSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kGold : theme.colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.surfaceContainerHighest,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withValues(alpha: 0.10),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.28),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: accentColor, size: 15),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _SocialTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_SocialTile> createState() => _SocialTileState();
}

class _SocialTileState extends State<_SocialTile>
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
      end: 0.97,
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

    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        _ctrl.reverse();
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        _ctrl.reverse();
        setState(() => _pressed = false);
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 130),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      _pressed
                          ? widget.backgroundColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: widget.backgroundColor.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLink;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLink = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: isLink ? _kGold : theme.colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isLink) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.open_in_new_rounded, color: _kGold, size: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            Colors.transparent,
          ],
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.07),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.28),
                    width: 1,
                  ),
                ),
                child: Icon(widget.icon, color: accentColor, size: 18),
              ),
            ),
      ),
    );
  }
}

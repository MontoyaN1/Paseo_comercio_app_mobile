// lib/presentation/widgets/organizacion/organizacion_app_bar.dart
//
// 🏛️ PLAZA UNIVERSE — Organizacion App Bar
// ────────────────────────────────────────────────────────────
//  FLOATING APP BAR + TAB BAR - USA TEMA
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../organizacion_components.dart';

const _kGold = Color(0xFFD4AF37);
const _kSurface = Color(0xFF0F0F1E);
const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);

class OrganizacionFloatingAppBar extends StatelessWidget {
  final String title;
  final double collapseProgress;
  final VoidCallback onBack;
  final VoidCallback? onShare;

  const OrganizacionFloatingAppBar({
    super.key,
    required this.title,
    required this.collapseProgress,
    required this.onBack,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opacity = collapseProgress;
    final surfaceColor = isDark ? _kSurface : Colors.white;
    final borderColor = isDark ? _kBorder : Colors.grey.shade300;
    final textColor = isDark ? Colors.white : Colors.black;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20 * opacity, sigmaY: 20 * opacity),
        child: AnimatedContainer(
          duration: Duration.zero,
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.85 * opacity),
            border: Border(
              bottom: BorderSide(
                color: borderColor.withOpacity(opacity),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              OrganizacionIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    Future.microtask(() => context.go('/organizaciones'));
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: Duration.zero,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (onShare != null)
                OrganizacionIconButton(
                  icon: Icons.share_rounded,
                  onTap: onShare!,
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class OrganizacionTabBar extends StatelessWidget {
  final TabController tabController;

  const OrganizacionTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? _kSurface : Colors.white;
    final borderColor = isDark ? _kBorder : Colors.grey.shade300;
    final unselectedLabel = isDark ? _kHint : Colors.grey.shade600;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.88),
            border: Border(bottom: BorderSide(color: borderColor, width: 1)),
          ),
          child: TabBar(
            controller: tabController,
            labelColor: _kGold,
            unselectedLabelColor: unselectedLabel,
            indicatorColor: _kGold,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.info_outline_rounded, size: 18),
                text: 'Información',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
              Tab(
                icon: Icon(Icons.store_rounded, size: 18),
                text: 'Tiendas',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

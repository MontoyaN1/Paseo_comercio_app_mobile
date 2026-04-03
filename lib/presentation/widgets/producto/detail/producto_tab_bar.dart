// lib/presentation/widgets/producto/producto_tab_bar.dart
//
// 🏛️ PLAZA UNIVERSE — Producto Tab Bar
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);
const _kSurface = Color(0xFF0F0F1E);
const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);

class ProductoTabBar extends StatelessWidget {
  final TabController tabController;

  const ProductoTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabBgColor =
        isDark
            ? _kSurface.withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.88);
    final tabBorderColor = isDark ? _kBorder : Colors.grey.shade300;
    final unselectedLabel = isDark ? _kHint : Colors.grey.shade600;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: tabBgColor,
            border: Border(bottom: BorderSide(color: tabBorderColor, width: 1)),
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
                text: 'Info',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
              Tab(
                icon: Icon(Icons.store_outlined, size: 18),
                text: 'Tienda',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
              Tab(
                icon: Icon(Icons.star_outline_rounded, size: 18),
                text: 'Reseñas',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

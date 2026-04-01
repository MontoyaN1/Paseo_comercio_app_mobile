// lib/presentation/widgets/organizacion/organizacion_hero.dart
//
// 🏛️ PLAZA UNIVERSE — Organizacion Hero
// ────────────────────────────────────────────────────────────
//  HERO SECTION - USA TEMA
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'package:paseo_del_comercio/domain/entities/organizacion.dart';
import 'package:paseo_del_comercio/domain/entities/enums.dart';

import 'organizacion_components.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kSurface = Color(0xFF0F0F1E);

class OrganizacionHero extends StatelessWidget {
  final Organizacion organizacion;

  const OrganizacionHero({super.key, required this.organizacion});

  String _getDescripcionTipo(TipoOrganizacion tipo) {
    switch (tipo) {
      case TipoOrganizacion.fundacion:
        return 'Fundación';
      case TipoOrganizacion.asociacion:
        return 'Asociación';
      case TipoOrganizacion.cooperativa:
        return 'Cooperativa';
      case TipoOrganizacion.empresa:
        return 'Empresa';
      case TipoOrganizacion.comunidad:
        return 'Comunidad';
      case TipoOrganizacion.otro:
        return 'Otra Organización';
    }
  }

  @override
  Widget build(BuildContext context) {
    final logoUrl = organizacion.logoUrlPrincipal;

    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (logoUrl != null)
            Image.network(
              logoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildFallback(context),
            )
          else
            _buildFallback(context),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xCC07070F),
                  const Color(0x3307070F),
                  const Color(0xFF07070F),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _kGold.withOpacity(0.06),
                  Colors.transparent,
                  _kGoldDeep.withOpacity(0.08),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _kGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _kGold.withOpacity(0.40),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          organizacion.iconoTipo,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getDescripcionTipo(organizacion.tipo),
                          style: const TextStyle(
                            color: _kGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ShaderMask(
                    shaderCallback:
                        (b) => const LinearGradient(
                          colors: [Colors.white, _kGoldLight],
                          stops: [0.6, 1.0],
                        ).createShader(b),
                    child: Text(
                      organizacion.nombreParaMostrar,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      OrganizacionHeroStatPill(
                        icon: Icons.store_rounded,
                        value: '${organizacion.totalTiendas ?? 0} tiendas',
                      ),
                      const SizedBox(width: 8),
                      OrganizacionHeroStatPill(
                        icon: Icons.people_alt_rounded,
                        value: '${organizacion.totalMiembros ?? 0} miembros',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? _kSurface : Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kGold.withOpacity(0.08),
                border: Border.all(color: _kGold.withOpacity(0.35), width: 1.5),
              ),
              child: Center(
                child: Text(
                  organizacion.iconoTipo,
                  style: const TextStyle(fontSize: 42),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/presentation/widgets/tienda/tienda_info_tab.dart
//
// 🏛️ INFO TAB - Tienda Detail
// ────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:paseo_del_comercio/core/utils/phone_utils.dart';

const _kGold = Color(0xFFD4AF37);
const _kHint = Color(0xFF6B6B8A);
const _kBorder = Color(0xFF1E1E3A);
const _kSurfaceCard = Color(0xFF0F0F1E);

class TiendaInfoTab extends StatelessWidget {
  final Map<String, dynamic> tienda;
  final List<Map<String, dynamic>> horarios;
  final VoidCallback? onOpenMaps;

  const TiendaInfoTab({
    super.key,
    required this.tienda,
    required this.horarios,
    this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? _kHint : Colors.grey.shade600;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tienda['descripcion'] != null &&
              tienda['descripcion'].toString().isNotEmpty) ...[
            _buildSection(
              context,
              title: 'Sobre la tienda',
              icon: Icons.auto_stories_rounded,
              child: Text(
                tienda['descripcion'].toString(),
                style: TextStyle(
                  color: hintColor,
                  fontSize: 14,
                  height: 1.65,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildSection(
            context,
            title: 'Información de contacto',
            icon: Icons.contact_page_outlined,
            child: Column(
              children: [
                if (tienda['telefono_contacto'] != null ||
                    tienda['telefono'] != null ||
                    tienda['telefono_contacto']?.toString().isNotEmpty ==
                        true) ...[
                  _buildInfoRow(
                    context: context,
                    icon: Icons.phone_rounded,
                    label: 'Teléfono',
                    child: _PhoneInfoWidget(
                      phoneNumber:
                          tienda['telefono_contacto']?.toString() ??
                          tienda['telefono']?.toString() ??
                          'No disponible',
                    ),
                  ),
                  _buildDivider(context: context),
                ],
                if (tienda['email_contacto'] != null ||
                    tienda['email'] != null ||
                    tienda['email_contacto']?.toString().isNotEmpty ==
                        true) ...[
                  _buildInfoRow(
                    context: context,
                    icon: Icons.alternate_email_rounded,
                    label: 'Correo electrónico',
                    value:
                        tienda['email_contacto']?.toString() ??
                        tienda['email']?.toString() ??
                        'No disponible',
                  ),
                  _buildDivider(context: context),
                ],
                if (tienda['direccion'] != null &&
                    tienda['direccion'].toString().isNotEmpty) ...[
                  _buildInfoRow(
                    context: context,
                    icon: Icons.location_on_rounded,
                    label: 'Dirección',
                    value: tienda['direccion'].toString(),
                    trailing: _buildMapButton(context),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (horarios.isNotEmpty) ...[
            _buildSection(
              context,
              title: 'Horarios de atención',
              icon: Icons.schedule_rounded,
              child: Column(
                children:
                    horarios
                        .map((horario) => _buildHorarioRow(context, horario))
                        .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (tienda['redes_sociales'] != null &&
              (tienda['redes_sociales'] as Map).isNotEmpty) ...[
            _buildSection(
              context,
              title: 'Redes sociales',
              icon: Icons.share_rounded,
              child: Column(
                children: _buildSocialButtons(
                  context,
                  tienda['redes_sociales'] as Map<String, dynamic>,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildStatsRow(context),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        isDark
            ? _kSurfaceCard.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.9);
    final cardBorder =
        isDark ? _kBorder.withValues(alpha: 0.5) : Colors.grey.shade300;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _kGold),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    String? value,
    Widget? child,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? _kHint : Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: _kGold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: hintColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                child ??
                    Text(
                      value ?? '',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }

  Widget _buildDivider({required BuildContext context}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? _kBorder : Colors.grey.shade300;
    return Divider(color: dividerColor.withValues(alpha: 0.5), height: 1);
  }

  Widget _buildMapButton(BuildContext context) {
    return GestureDetector(
      onTap: onOpenMaps,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _kGold.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kGold.withValues(alpha: 0.25), width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_rounded, size: 14, color: _kGold),
            SizedBox(width: 4),
            Text(
              'Ver mapa',
              style: TextStyle(
                color: _kGold,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorarioRow(BuildContext context, Map<String, dynamic> horario) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOpen = horario['hora_apertura'] != null;
    final textColor = isDark ? Colors.white : Colors.black87;
    final closedColor = isDark ? _kHint : Colors.grey.shade600;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            horario['dia']?.toString() ?? '',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            (horario['hora_apertura'] != null && horario['hora_cierre'] != null)
                ? '${horario['hora_apertura']} - ${horario['hora_cierre']}'
                : 'Cerrado',
            style: TextStyle(
              color: isOpen ? _kGold : closedColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GoldStatCard(
            icon: Icons.visibility_rounded,
            value: tienda['total_visitas'] ?? 0,
            label: 'Visitas',
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSocialButtons(
    BuildContext context,
    Map<String, dynamic> redesSociales,
  ) {
    final buttons = <Widget>[];
    final socialConfig = {
      'facebook': {
        'icon': SimpleIcons.facebook,
        'color': const Color(0xFF1877F2),
      },
      'instagram': {
        'icon': SimpleIcons.instagram,
        'color': const Color(0xFFE4405F),
      },
      'twitter': {
        'icon': SimpleIcons.x,
        'color': const Color(0xFF1DA1F2),
      },
      'x': {
        'icon': SimpleIcons.x,
        'color': const Color(0xFF000000),
      },
      'tiktok': {
        'icon': SimpleIcons.tiktok,
        'color': const Color(0xFF25F4EE),
      },
      'youtube': {
        'icon': SimpleIcons.youtube,
        'color': const Color(0xFFFF0000),
      },
      'linkedin': {
        'icon': Icons.business_rounded,
        'color': const Color(0xFF0A66C2),
      },
      'whatsapp': {
        'icon': SimpleIcons.whatsapp,
        'color': const Color(0xFF25D366),
      },
      'web': {'icon': Icons.language_rounded, 'color': _kGold},
    };

    for (final entry in redesSociales.entries) {
      final red = entry.key.toLowerCase();
      dynamic valor = entry.value;

      String? url;
      if (valor is String) {
        if (valor.contains('{')) {
          try {
            final parsed = jsonDecode(valor);
            if (parsed is Map) url = parsed['url'] as String?;
          } catch (_) {
            url = valor;
          }
        } else {
          url = valor;
        }
      } else if (valor is Map) {
        url = valor['url'] as String?;
      }

      if (url == null || url.isEmpty) continue;

      final config = socialConfig[red];
      if (config == null) continue;

      final color = config['color'] as Color;

      buttons.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _abrirUrl(url!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(config['icon'] as IconData, color: color, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formatearNombreRed(red),
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    color: color.withValues(alpha: 0.7),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  String _formatearNombreRed(String red) {
    final nombres = {
      'facebook': 'Facebook',
      'instagram': 'Instagram',
      'twitter': 'Twitter',
      'x': 'X (Twitter)',
      'tiktok': 'TikTok',
      'youtube': 'YouTube',
      'linkedin': 'LinkedIn',
      'whatsapp': 'WhatsApp',
      'web': 'Sitio web',
    };
    return nombres[red.toLowerCase()] ?? red;
  }

  Future<void> _abrirUrl(String url) async {
    try {
      String urlFinal = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        urlFinal = 'https://$url';
      }
      final uri = Uri.parse(urlFinal);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error al abrir URL: $e');
    }
  }
}

class _PhoneInfoWidget extends StatelessWidget {
  final String phoneNumber;

  const _PhoneInfoWidget({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    final countryCode = extractCountryCode(phoneNumber);
    final phoneWithoutCode = extractPhoneWithoutCode(phoneNumber);
    final flag =
        countryCode != null ? getFlagForCountryCode(countryCode) : null;

    if (flag != null && countryCode != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(countryCode, style: TextStyle(color: textColor, fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            phoneWithoutCode,
            style: TextStyle(color: textColor, fontSize: 14),
          ),
        ],
      );
    }
    return Text(phoneNumber, style: TextStyle(color: textColor, fontSize: 14));
  }
}

class _GoldStatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _GoldStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? _kHint : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _kGold.withValues(alpha: 0.12),
            isDark ? const Color(0xFF12121F) : Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kGold.withValues(alpha: 0.30), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: _kGold, size: 24),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: hintColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

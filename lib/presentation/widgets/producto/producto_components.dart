// lib/presentation/widgets/producto/producto_components.dart
//
// 🏛️ COMPONENTES DE PRODUCTO - USA Theme.of(context)
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:paseo_del_comercio/core/utils/phone_utils.dart';

const _kGold = Color(0xFFD4AF37);

class ProductoPhoneInfo extends StatelessWidget {
  final String phoneNumber;

  const ProductoPhoneInfo({super.key, required this.phoneNumber});

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

class ProductoGoldStatCard extends StatelessWidget {
  final IconData icon;
  final dynamic value;
  final String label;

  const ProductoGoldStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark
            ? const Color(0xFF0F0F1E).withValues(alpha: 0.80)
            : Colors.white.withValues(alpha: 0.90);
    final borderColor = isDark ? const Color(0xFF1E1E3A) : Colors.grey.shade300;
    final hintColor = isDark ? const Color(0xFF6B6B8A) : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Icon(icon, color: _kGold, size: 24),
          const SizedBox(height: 8),
          Text(
            value?.toString() ?? '0',
            style: const TextStyle(
              color: _kGold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: hintColor, fontSize: 12)),
        ],
      ),
    );
  }
}

class ProductoIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ProductoIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark
            ? const Color(0xFF0F0F1E).withValues(alpha: 0.80)
            : Colors.white.withValues(alpha: 0.90);
    final borderColor = isDark ? const Color(0xFF1E1E3A) : Colors.grey.shade300;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: surfaceColor,
            border: Border.all(color: borderColor),
          ),
          child: Icon(icon, color: _kGold, size: 20),
        ),
      ),
    );
  }
}

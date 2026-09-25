// lib/presentation/widgets/profile/profile_avatar_hero.dart
//
// 🏛️ PLAZA UNIVERSE — Profile Avatar Hero
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paseo_del_comercio/core/utils/firebase_auth_service.dart';
import 'package:paseo_del_comercio/di/service_locator.dart';
import 'package:paseo_del_comercio/presentation/providers/avatar_provider.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kSurface = Color(0xFF0F0F1E);
const _kBg = Color(0xFF07070F);
const _kHint = Color(0xFF6B6B8A);

class ProfileAvatarHero extends StatelessWidget {
  final Animation<double> avatarPulse;
  final VoidCallback onAvatarTap;

  const ProfileAvatarHero({
    super.key,
    required this.avatarPulse,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final authService = getIt<FirebaseAuthService>();
    final avatarProvider = getIt<AvatarProvider>();
    final displayName = authService.currentUserName;
    final email = authService.currentUserEmail;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: AnimatedBuilder(
            animation: avatarPulse,
            builder:
                (_, child) => Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kGold.withValues(
                              alpha: 0.20 * avatarPulse.value,
                            ),
                            blurRadius: 30 * avatarPulse.value,
                            spreadRadius: 6 * avatarPulse.value,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            _kGold.withValues(alpha: 0.80),
                            _kGoldLight.withValues(alpha: 0.30),
                            _kGold.withValues(alpha: 0.80),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? _kSurface : Colors.grey.shade200,
                        border: Border.all(
                          color: isDark ? _kBg : Colors.grey.shade400,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: ListenableBuilder(
                          listenable: avatarProvider,
                          builder: (context, _) {
                            final imageUrl = avatarProvider.avatarUrl;
                            final updateCount = avatarProvider.updateCount;
                            if (imageUrl != null && imageUrl.isNotEmpty) {
                              return Image.network(
                                imageUrl,
                                key: ValueKey(
                                  'avatar_${imageUrl}_$updateCount',
                                ),
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => _buildAvatarFallback(),
                              );
                            }
                            return _buildAvatarFallback();
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _kGold,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? _kBg : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
          ),
        ),
        const SizedBox(height: 18),
        ShaderMask(
          shaderCallback:
              (b) => const LinearGradient(
                colors: [_kGoldDeep, _kGold, _kGoldLight],
              ).createShader(b),
          child: Text(
            displayName ?? 'Usuario',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          email ?? '',
          style: TextStyle(
            color: isDark ? _kHint : Colors.grey.shade600,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.green.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDark
                      ? Colors.green.withValues(alpha: 0.40)
                      : Colors.green.shade400,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.greenAccent : Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'Sesión activa',
                style: TextStyle(
                  color: isDark ? Colors.greenAccent : Colors.green.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarFallback() {
    final authService = getIt<FirebaseAuthService>();
    final displayName = authService.currentUserName;
    final initials =
        (displayName?.isNotEmpty == true) ? displayName![0].toUpperCase() : '?';
    return Container(
      color: _kGold.withOpacity(0.10),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: _kGold,
            fontSize: 38,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

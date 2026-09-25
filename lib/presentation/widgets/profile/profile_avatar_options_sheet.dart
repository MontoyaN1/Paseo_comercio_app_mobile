// lib/presentation/widgets/profile/profile_avatar_options_sheet.dart
//
// 🏛️ PLAZA UNIVERSE — Profile Avatar Options Sheet
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const _kGold = Color(0xFFD4AF37);
const _kSurface = Color(0xFF0F0F1E);
const _kHint = Color(0xFF6B6B8A);

class ProfileAvatarOptionsSheet extends StatelessWidget {
  final Function(ImageSource) onSourceSelected;

  const ProfileAvatarOptionsSheet({super.key, required this.onSourceSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? _kHint : Colors.grey.shade600;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cambiar foto de perfil',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _kGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: _kGold),
              ),
              title: Text('Tomar foto', style: TextStyle(color: textColor)),
              subtitle: Text(
                'Usar la cámara',
                style: TextStyle(color: hintColor),
              ),
              onTap: () {
                Navigator.pop(context);
                onSourceSelected(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _kGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library, color: _kGold),
              ),
              title: Text(
                'Elegir de galería',
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                'Seleccionar una imagen',
                style: TextStyle(color: hintColor),
              ),
              onTap: () {
                Navigator.pop(context);
                onSourceSelected(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required Function(ImageSource) onSourceSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? _kSurface : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) =>
              ProfileAvatarOptionsSheet(onSourceSelected: onSourceSelected),
    );
  }
}

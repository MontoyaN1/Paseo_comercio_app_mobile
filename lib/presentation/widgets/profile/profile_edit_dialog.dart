// lib/presentation/widgets/profile/profile_edit_dialog.dart

import 'package:flutter/material.dart';
import 'package:paseo_del_comercio/core/utils/phone_utils.dart';
import 'package:paseo_del_comercio/presentation/widgets/profile/country_picker_dialog.dart';

class ProfileEditDialog extends StatefulWidget {
  final String field;
  final String currentValue;
  final String label;
  final Future<void> Function(String field, String value) onSave;

  const ProfileEditDialog({
    super.key,
    required this.field,
    required this.currentValue,
    required this.label,
    required this.onSave,
  });

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late final TextEditingController _controller;
  String _selectedCountryCode = '+57';
  String _currentPhoneWithoutCode = '';
  bool _countryChanged = false;

  static const _kGold = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    if (widget.field == 'nombre') {
      _controller.text = widget.currentValue;
    } else {
      _selectedCountryCode = extractCountryCode(widget.currentValue) ?? '+57';
      _currentPhoneWithoutCode = extractPhoneWithoutCode(widget.currentValue);
      _controller.text = _currentPhoneWithoutCode;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _displayLabel =>
      widget.field == 'nombre' ? 'Nombre completo' : 'Teléfono';

  Future<String?> _showCountryPicker() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<String>(
      context: context,
      builder:
          (_) => CountryPickerDialog(
            currentCode: _selectedCountryCode,
            onSelected: (code) => Navigator.pop(context, code),
            isDark: isDark,
          ),
    );
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _validatePhone(String phone) {
    if (phone.isEmpty && !_countryChanged) {
      _showSnackBar('Ingresa un número de teléfono');
      return false;
    }
    if (phone.contains(' ')) {
      _showSnackBar('No incluyas espacios en el número de teléfono');
      return false;
    }
    if (phone.contains('-')) {
      _showSnackBar('No incluyas guiones en el número de teléfono');
      return false;
    }
    if (phone.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showSnackBar('Solo se permiten números en el teléfono');
      return false;
    }
    if (phone.isNotEmpty && phone.length < 7) {
      _showSnackBar('El número de teléfono debe tener al menos 7 dígitos');
      return false;
    }
    return true;
  }

  Future<void> _handleSave() async {
    String newValue = _controller.text.trim();
    if (widget.field == 'telefono') {
      newValue = '$_selectedCountryCode $newValue';
    }

    if (newValue.isEmpty) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }

    if (widget.field == 'telefono') {
      final phoneOnly = _controller.text.trim();
      if (phoneOnly == _currentPhoneWithoutCode && !_countryChanged) {
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
      if (!_validatePhone(phoneOnly)) return;
    } else if (newValue == widget.currentValue) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }

    Navigator.pop(context, newValue);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0F0F1E) : Colors.white;
    final surfaceCardColor =
        isDark ? const Color(0xFF12121F) : Colors.grey.shade100;
    final borderColor = isDark ? const Color(0xFF1E1E3A) : Colors.grey.shade300;
    final hintColor = isDark ? const Color(0xFF6B6B8A) : Colors.grey.shade600;
    final textColor = isDark ? Colors.white : Colors.black87;

    final flag = getFlagForCountryCode(_selectedCountryCode);

    return AlertDialog(
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor, width: 1),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _kGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.field == 'nombre'
                  ? Icons.person_outline
                  : Icons.phone_outlined,
              color: _kGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Editar ${_displayLabel}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          if (widget.field == 'telefono') ...[
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final newCode = await _showCountryPicker();
                    if (newCode != null && newCode != _selectedCountryCode) {
                      setState(() {
                        _selectedCountryCode = newCode;
                        _countryChanged = true;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _kGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _kGold.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(flag ?? '', style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          _selectedCountryCode,
                          style: const TextStyle(
                            color: _kGold,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: _kGold,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Número de teléfono',
                      labelStyle: TextStyle(color: hintColor),
                      hintText: 'Ej: 3001234567',
                      hintStyle: TextStyle(
                        color: hintColor.withValues(alpha: 0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _kGold),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: TextStyle(color: textColor),
                    cursorColor: _kGold,
                    keyboardType: TextInputType.phone,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Formato: $_selectedCountryCode + número (ej: 3001234567)',
              style: TextStyle(
                color: hintColor,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else ...[
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: _displayLabel,
                labelStyle: TextStyle(color: hintColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kGold),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: TextStyle(color: textColor),
              cursorColor: _kGold,
              keyboardType: TextInputType.text,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: surfaceCardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: borderColor),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Cancelar', style: TextStyle(color: textColor)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

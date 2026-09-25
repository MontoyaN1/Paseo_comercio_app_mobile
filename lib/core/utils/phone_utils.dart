// lib/core/utils/phone_utils.dart

const List<Map<String, String>> countryCodes = [
  {'code': '+57', 'name': 'Colombia', 'flag': '🇨🇴'},
  {'code': '+34', 'name': 'España', 'flag': '🇪🇸'},
  {'code': '+1', 'name': 'Estados Unidos', 'flag': '🇺🇸'},
  {'code': '+52', 'name': 'México', 'flag': '🇲🇽'},
  {'code': '+54', 'name': 'Argentina', 'flag': '🇦🇷'},
  {'code': '+56', 'name': 'Chile', 'flag': '🇨🇱'},
  {'code': '+51', 'name': 'Perú', 'flag': '🇵🇪'},
  {'code': '+58', 'name': 'Venezuela', 'flag': '🇻🇪'},
  {'code': '+55', 'name': 'Brasil', 'flag': '🇧🇷'},
  {'code': '+44', 'name': 'Reino Unido', 'flag': '🇬🇧'},
  {'code': '+33', 'name': 'Francia', 'flag': '🇫🇷'},
  {'code': '+49', 'name': 'Alemania', 'flag': '🇩🇪'},
  {'code': '+39', 'name': 'Italia', 'flag': '🇮🇹'},
  {'code': '+81', 'name': 'Japón', 'flag': '🇯🇵'},
  {'code': '+86', 'name': 'China', 'flag': '🇨🇳'},
  {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
  {'code': '+7', 'name': 'Rusia', 'flag': '🇷🇺'},
  {'code': '+61', 'name': 'Australia', 'flag': '🇦🇺'},
  {'code': '+64', 'name': 'Nueva Zelanda', 'flag': '🇳🇿'},
  {'code': '+27', 'name': 'Sudáfica', 'flag': '🇿🇦'},
];

String? extractCountryCode(String phoneNumber) {
  if (phoneNumber.startsWith('+')) {
    final plusIndex = phoneNumber.indexOf('+');
    final spaceIndex = phoneNumber.indexOf(' ');
    if (spaceIndex > plusIndex) {
      return phoneNumber.substring(plusIndex, spaceIndex);
    } else {
      int i = 1;
      while (i < phoneNumber.length &&
          phoneNumber[i].contains(RegExp(r'[0-9]'))) {
        i++;
      }
      return phoneNumber.substring(0, i);
    }
  }
  return null;
}

String? getFlagForCountryCode(String countryCode) {
  final Map<String, String> countryCodeToFlag = {
    '+57': '🇨🇴',
    '+34': '🇪🇸',
    '+1': '🇺🇸',
    '+52': '🇲🇽',
    '+54': '🇦🇷',
    '+56': '🇨🇱',
    '+51': '🇵🇪',
    '+58': '🇻🇪',
    '+55': '🇧🇷',
    '+44': '🇬🇧',
    '+33': '🇫🇷',
    '+49': '🇩🇪',
    '+39': '🇮🇹',
    '+81': '🇯🇵',
    '+86': '🇨🇳',
    '+91': '🇮🇳',
    '+7': '🇷🇺',
    '+61': '🇦🇺',
    '+64': '🇳🇿',
    '+27': '🇿🇦',
  };
  return countryCodeToFlag[countryCode];
}

String extractPhoneWithoutCode(String phoneNumber) {
  if (phoneNumber.startsWith('+')) {
    final plusIndex = phoneNumber.indexOf('+');
    final spaceIndex = phoneNumber.indexOf(' ');
    if (spaceIndex > plusIndex) {
      return phoneNumber.substring(spaceIndex + 1);
    } else {
      int i = 1;
      while (i < phoneNumber.length &&
          phoneNumber[i].contains(RegExp(r'[0-9]'))) {
        i++;
      }
      return phoneNumber.substring(i);
    }
  }
  return phoneNumber;
}

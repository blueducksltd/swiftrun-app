import 'package:flutter/services.dart';

class CountryUtils {
  static final Map<String, Map<String, dynamic>> countryConfigs = {
    'NG': {
      'name': 'Nigeria',
      'code': '+234',
      'flag': '🇳🇬',
      'maxLength': 10,
      'format': 'XXX-XXX-XXXX',
      'inputFormatters': [FilteringTextInputFormatter.digitsOnly],
    },
    'US': {
      'name': 'United States',
      'code': '+1',
      'flag': '🇺🇸',
      'maxLength': 10,
      'format': '(XXX) XXX-XXXX',
      'inputFormatters': [FilteringTextInputFormatter.digitsOnly],
    },
    'CA': {
      'name': 'Canada',
      'code': '+1',
      'flag': '🇨🇦',
      'maxLength': 10,
      'format': '(XXX) XXX-XXXX',
      'inputFormatters': [FilteringTextInputFormatter.digitsOnly],
    },
    'MT': {
      'name': 'Malta',
      'code': '+356',
      'flag': '🇲🇹',
      'maxLength': 8,
      'format': 'XXXX XXXX',
      'inputFormatters': [FilteringTextInputFormatter.digitsOnly],
    },
  };

  static Map<String, dynamic> getCountryConfig(String countryCode) {
    return countryConfigs[countryCode] ?? countryConfigs['NG']!;
  }

  static String formatPhoneNumber(String phoneNumber, String countryCode) {
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    switch (countryCode) {
      case 'NG':
        if (digits.length >= 10) {
          return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6, 10)}';
        } else if (digits.length >= 6) {
          return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
        } else if (digits.length >= 3) {
          return '${digits.substring(0, 3)}-${digits.substring(3)}';
        }
        return digits;
      
      case 'US':
      case 'CA':
        if (digits.length >= 10) {
          return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, 10)}';
        } else if (digits.length >= 6) {
          return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
        } else if (digits.length >= 3) {
          return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
        }
        return digits;
      
      case 'MT':
        if (digits.length >= 8) {
          return '${digits.substring(0, 4)} ${digits.substring(4, 8)}';
        } else if (digits.length >= 4) {
          return '${digits.substring(0, 4)} ${digits.substring(4)}';
        }
        return digits;
      
      default:
        return digits;
    }
  }

  static bool isValidPhoneNumber(String phoneNumber, String countryCode) {
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final countryConfig = getCountryConfig(countryCode);
    return digits.length == countryConfig['maxLength'];
  }

  static String getFullPhoneNumber(String phoneNumber, String countryCode) {
    final countryConfig = getCountryConfig(countryCode);
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return '${countryConfig['code']}$digits';
  }
}

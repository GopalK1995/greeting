import 'package:flutter/material.dart';

class AppTheme {
  static const Color background    = Color(0xFF0A0A0F);
  static const Color surface       = Color(0xFF14141E);
  static const Color surfaceHigh   = Color(0xFF1C1C2E);
  static const Color accent        = Color(0xFFE5173F);
  static const Color accentLight   = Color(0xFFFF4D6D);
  static const Color textPrimary   = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary  = Color(0xFF48484A);
  static const Color gold          = Color(0xFFFFD60A);
  static const Color green         = Color(0xFF30D158);
  static const Color border        = Color(0xFF2C2C3E);

  // Platform brand colours
  static const Color netflix  = Color(0xFFE50914);
  static const Color prime    = Color(0xFF00A8E1);
  static const Color hotstar  = Color(0xFF1F80E0);
  static const Color bms      = Color(0xFFE5173F);
  static const Color sonyliv  = Color(0xFF0057A8);
  static const Color zee5     = Color(0xFF8E3AF4);
  static const Color jio      = Color(0xFF003CB6);

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: surface,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
    );
  }

  static Color providerColor(int providerId) {
    switch (providerId) {
      case 8:   return netflix;
      case 119: return prime;
      case 122: return hotstar;
      case 220: return jio;
      case 237: return sonyliv;
      case 232: return zee5;
      default:  return textSecondary;
    }
  }
}

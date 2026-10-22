import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'palette.dart';

ThemeData buildTheme(Palette p, Brightness b) {
  final isDark = b == Brightness.dark;
  final scheme = ColorScheme(
    brightness: b,
    primary: p.pri,
    onPrimary: p.onPri,
    secondary: p.pri,
    onSecondary: p.onPri,
    error: p.red,
    onError: isDark ? const Color(0xFF690005) : Colors.white,
    surface: p.surface,
    onSurface: p.on,
    onSurfaceVariant: p.mut,
    outline: p.mut,
    outlineVariant: p.line,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.surface,
    fontFamily: 'Roboto',
    appBarTheme: AppBarTheme(
      backgroundColor: p.surface,
      foregroundColor: p.on,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: p.on,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        fontFamily: 'Roboto',
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.pri,
        foregroundColor: p.onPri,
        minimumSize: const Size(48, 48),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.on,
        minimumSize: const Size(48, 48),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF2D3636),
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      actionTextColor: const Color(0xFFF8FF4F),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  );
}

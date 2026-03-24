import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// silat ar rahim — design system
// Principles: Tufte data-ink ratio · Tschichold typographic grid
// Color carries meaning only. No decoration without purpose.
// ---------------------------------------------------------------------------

abstract final class SilatColors {
  // --- Neutrals ---
  static const Color bg0 = Color(0xFF0F1117); // near-black canvas
  static const Color bg1 = Color(0xFF181B24); // card surface
  static const Color bg2 = Color(0xFF222636); // elevated surface
  static const Color bg3 = Color(0xFF2C3148); // border / divider

  static const Color fg0 = Color(0xFFF5F2ED); // primary text
  static const Color fg1 = Color(0xFFB8B4AE); // secondary text
  static const Color fg2 = Color(0xFF7A776F); // tertiary / hint
  static const Color fg3 = Color(0xFF4A4840); // disabled

  // Light mode neutrals
  static const Color lbg0 = Color(0xFFF8F6F1); // paper white
  static const Color lbg1 = Color(0xFFEFEDE8); // card
  static const Color lbg2 = Color(0xFFE4E1DA); // elevated
  static const Color lbg3 = Color(0xFFCBC8C0); // border

  static const Color lfg0 = Color(0xFF111318); // primary text
  static const Color lfg1 = Color(0xFF3D3C38); // secondary
  static const Color lfg2 = Color(0xFF6B6860); // tertiary
  static const Color lfg3 = Color(0xFF9B9890); // disabled

  // --- Semantic / accent ---
  static const Color terracotta = Color(0xFFC1602A); // primary action
  static const Color terracottaLight = Color(0xFFE07840); // hover
  static const Color slate = Color(0xFF6B8CAE); // secondary / links
  static const Color slateLight = Color(0xFF8AAAC8);

  static const Color success = Color(0xFF4A9E6B); // living / confirmed
  static const Color deceased = Color(0xFF7A776F); // deceased members
  static const Color error = Color(0xFFB85450);
  static const Color warning = Color(0xFFB8922A);

  // --- Kinship generation depth (max 4 shades) ---
  static const Color gen0 = Color(0xFFC1602A); // ego
  static const Color gen1 = Color(0xFF6B8CAE); // parents / children
  static const Color gen2 = Color(0xFF4A9E6B); // grandparents / grandchildren
  static const Color gen3 = Color(0xFFB8922A); // great-grandparents +

  // --- Gender indicators (minimal, meaningful) ---
  static const Color genderM = Color(0xFF6B8CAE); // slate
  static const Color genderF = Color(0xFFC1602A); // terracotta
  static const Color genderX = Color(0xFF8A8680); // neutral grey
}

abstract final class SilatTypography {
  // Inter — clean, readable, works at all sizes
  static const String fontFamily = 'Inter';
  static const String monoFamily = 'IBM Plex Mono';

  // Scale: 4 sizes only (Tschichold — hierarchy through contrast)
  static const double sizeDisplay = 28.0;
  static const double sizeTitle = 20.0;
  static const double sizeBody = 15.0;
  static const double sizeLabel = 12.0;

  static const double weightLight = 300;
  static const double weightRegular = 400;
  static const double weightMedium = 500;
  static const double weightSemibold = 600;

  // Letter spacing: tighter for large, tracked for labels
  static const double trackingDisplay = -0.5;
  static const double trackingTitle = -0.2;
  static const double trackingBody = 0.0;
  static const double trackingLabel = 0.6;
  static const double trackingMono = 0.0;

  static TextStyle display({Color? color, bool dark = true}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeDisplay,
        fontWeight: FontWeight.w600,
        letterSpacing: trackingDisplay,
        height: 1.2,
        color: color ?? (dark ? SilatColors.fg0 : SilatColors.lfg0),
      );

  static TextStyle title({Color? color, bool dark = true}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeTitle,
        fontWeight: FontWeight.w500,
        letterSpacing: trackingTitle,
        height: 1.3,
        color: color ?? (dark ? SilatColors.fg0 : SilatColors.lfg0),
      );

  static TextStyle body({Color? color, bool dark = true}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeBody,
        fontWeight: FontWeight.w400,
        letterSpacing: trackingBody,
        height: 1.5,
        color: color ?? (dark ? SilatColors.fg1 : SilatColors.lfg1),
      );

  static TextStyle label({Color? color, bool dark = true}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: sizeLabel,
        fontWeight: FontWeight.w500,
        letterSpacing: trackingLabel,
        height: 1.4,
        color: color ?? (dark ? SilatColors.fg2 : SilatColors.lfg2),
      );

  static TextStyle mono({Color? color, bool dark = true}) => TextStyle(
        fontFamily: monoFamily,
        fontSize: sizeLabel,
        fontWeight: FontWeight.w400,
        letterSpacing: trackingMono,
        height: 1.4,
        color: color ?? (dark ? SilatColors.fg2 : SilatColors.lfg2),
      );
}

abstract final class SilatSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 40.0;
  static const double xxl = 64.0;
}

abstract final class SilatRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double pill = 100.0;
}

// ---------------------------------------------------------------------------
// ThemeData builders
// ---------------------------------------------------------------------------

ThemeData silatDark() {
  const bg = SilatColors.bg0;
  const surface = SilatColors.bg1;
  const primary = SilatColors.terracotta;
  const onPrimary = SilatColors.fg0;
  const text = SilatColors.fg0;
  const textSub = SilatColors.fg1;

  final base = ThemeData.dark(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: onPrimary,
      secondary: SilatColors.slate,
      onSecondary: SilatColors.fg0,
      surface: surface,
      onSurface: text,
      error: SilatColors.error,
      outline: SilatColors.bg3,
    ),
    textTheme: _buildTextTheme(dark: true),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: SilatTypography.title(dark: true),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SilatRadius.md),
        side: const BorderSide(color: SilatColors.bg3, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: SilatColors.bg3,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SilatColors.bg2,
      hintStyle: SilatTypography.body(color: SilatColors.fg2, dark: true),
      labelStyle: SilatTypography.label(dark: true),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SilatRadius.md),
        borderSide: const BorderSide(color: SilatColors.bg3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SilatRadius.md),
        borderSide: const BorderSide(color: SilatColors.bg3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SilatRadius.md),
        borderSide: const BorderSide(color: SilatColors.terracotta, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: SilatSpacing.md,
        vertical: SilatSpacing.sm + SilatSpacing.xs,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        textStyle: SilatTypography.body(dark: true)
            .copyWith(fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(
          horizontal: SilatSpacing.lg,
          vertical: SilatSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SilatRadius.md),
        ),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: SilatColors.slate,
        textStyle: SilatTypography.body(dark: true),
        padding: const EdgeInsets.symmetric(
          horizontal: SilatSpacing.sm,
          vertical: SilatSpacing.xs,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: SilatColors.bg2,
      labelStyle: SilatTypography.label(dark: true),
      side: const BorderSide(color: SilatColors.bg3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SilatRadius.sm),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: SilatSpacing.sm,
        vertical: SilatSpacing.xs,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: SilatColors.bg1,
      selectedItemColor: primary,
      unselectedItemColor: textSub,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: SilatTypography.label(dark: true),
      unselectedLabelStyle: SilatTypography.label(dark: true),
    ),
  );
}

ThemeData silatLight() {
  const bg = SilatColors.lbg0;
  const surface = SilatColors.lbg1;
  const primary = SilatColors.terracotta;
  const text = SilatColors.lfg0;

  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: SilatColors.fg0,
      secondary: SilatColors.slate,
      onSecondary: SilatColors.fg0,
      surface: surface,
      onSurface: text,
      error: SilatColors.error,
      outline: SilatColors.lbg3,
    ),
    textTheme: _buildTextTheme(dark: false),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: SilatTypography.title(dark: false),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SilatRadius.md),
        side: const BorderSide(color: SilatColors.lbg3, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: SilatColors.lbg3,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SilatColors.lbg2,
      hintStyle: SilatTypography.body(color: SilatColors.lfg2, dark: false),
      labelStyle: SilatTypography.label(dark: false),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SilatRadius.md),
        borderSide: const BorderSide(color: SilatColors.lbg3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SilatRadius.md),
        borderSide: const BorderSide(color: SilatColors.lbg3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SilatRadius.md),
        borderSide:
            const BorderSide(color: SilatColors.terracotta, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: SilatSpacing.md,
        vertical: SilatSpacing.sm + SilatSpacing.xs,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: SilatColors.fg0,
        textStyle: SilatTypography.body(dark: false)
            .copyWith(fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(
          horizontal: SilatSpacing.lg,
          vertical: SilatSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SilatRadius.md),
        ),
        elevation: 0,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: SilatColors.lbg2,
      labelStyle: SilatTypography.label(dark: false),
      side: const BorderSide(color: SilatColors.lbg3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SilatRadius.sm),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: SilatColors.lfg2,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}

TextTheme _buildTextTheme({required bool dark}) {
  final fg0 = dark ? SilatColors.fg0 : SilatColors.lfg0;
  final fg1 = dark ? SilatColors.fg1 : SilatColors.lfg1;
  final fg2 = dark ? SilatColors.fg2 : SilatColors.lfg2;

  return TextTheme(
    displayLarge: SilatTypography.display(color: fg0, dark: dark),
    titleLarge: SilatTypography.title(color: fg0, dark: dark),
    titleMedium: SilatTypography.title(color: fg1, dark: dark)
        .copyWith(fontSize: 17),
    bodyLarge: SilatTypography.body(color: fg0, dark: dark),
    bodyMedium: SilatTypography.body(color: fg1, dark: dark),
    bodySmall: SilatTypography.body(color: fg2, dark: dark)
        .copyWith(fontSize: 13),
    labelLarge: SilatTypography.label(color: fg1, dark: dark)
        .copyWith(fontSize: 13),
    labelMedium: SilatTypography.label(color: fg2, dark: dark),
    labelSmall: SilatTypography.label(color: fg2, dark: dark)
        .copyWith(fontSize: 10),
  );
}

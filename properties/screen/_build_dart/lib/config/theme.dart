import 'package:flutter/material.dart';

/// Sewain brand palette & Material theme.
///
/// Brand colors per the design spec: Navy `#0E2340` + Gold `#F4A93B`,
/// shared consistently across the Consumer and Mitra (Partner) sides.
class AppColors {
  AppColors._();

  static const Color navy = Color(0xFF0E2340);
  static const Color navyLight = Color(0xFF1B3A5C);
  static const Color gold = Color(0xFFF4A93B);
  static const Color goldDark = Color(0xFFD98E1E);

  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0E2340);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFE0A200);
  static const Color danger = Color(0xFFDC3545);
  static const Color info = Color(0xFF2F80ED);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const seed = AppColors.navy;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        primary: AppColors.navy,
        secondary: AppColors.gold,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navy,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.6),
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.background,
        selectedColor: AppColors.navy,
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.navy,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Design tokens extracted from the property-detail / rincian-unit mockups
/// under `docs/properties/screen/`.
///
/// The mockups use a red primary (Travelio-style reference), which differs
/// from the shipped Sewain palette (navy `#0E2340` + gold `#F4A93B` in
/// `flutter/lib/config/theme.dart`). Every colour below is funnelled through
/// this one class so re-branding is a single-file edit — see `README.md`.
class DT {
  DT._();

  // ---------------------------------------------------------------- brand
  /// AppBar background, primary CTA fill, active tab underline.
  static const Color brand = Color(0xFFDE4C4C);

  /// Pressed / darker brand shade.
  static const Color brandDark = Color(0xFFC53F3F);

  /// Pale brand tint — selected segmented chips, promo rows, soft buttons.
  static const Color brandSoft = Color(0xFFFDECEC);

  /// Brand at ~40% used for the "NEW" label and muted brand text.
  static const Color brandMuted = Color(0xFFF08080);

  // --------------------------------------------------------------- accent
  /// "Flash Sale", "Apartment" tag text, "3 Unit Tersedia".
  static const Color accent = Color(0xFFF5A623);

  /// "Apartment" tag background.
  static const Color accentSoft = Color(0xFFFFF3DF);

  // ------------------------------------------------------------------ ink
  static const Color textPrimary = Color(0xFF3C3C3C);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textTertiary = Color(0xFFA8A8A8);

  // -------------------------------------------------------------- surface
  static const Color surface = Colors.white;

  /// Page background + the grey gap that separates stacked sections.
  static const Color canvas = Color(0xFFF1F2F4);

  /// Grey tile fill for facility chips, table headers, bed-config blocks.
  static const Color fill = Color(0xFFF4F4F5);

  static const Color divider = Color(0xFFE8E8E8);
  static const Color border = Color(0xFFE3E4E6);

  // ------------------------------------------------------------- semantic
  /// "Anda menghemat - IDR 50,000".
  static const Color success = Color(0xFF2E9E5B);

  /// Review score badge background (5.0 / 5 pill in the review card).
  static const Color successSoft = Color(0xFFE7F5EC);

  static const Color info = Color(0xFF2F80ED);
  static const Color infoSoft = Color(0xFFE3F0FD);

  static const Color depositSoft = Color(0xFFE3F7EA);

  // ----------------------------------------------------------------- text
  static const TextStyle screenTitle = TextStyle(
    fontSize: 22,
    height: 1.3,
    fontWeight: FontWeight.w800,
    color: DT.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: DT.textPrimary,
  );

  static const TextStyle subsectionTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: DT.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: DT.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.55,
    color: DT.textPrimary,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 15,
    height: 1.6,
    color: DT.textSecondary,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w700,
    color: DT.textPrimary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    color: DT.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.5,
    color: DT.textSecondary,
  );

  /// Red "Lihat Semua" / "tampilkan selengkapnya" style links.
  static const TextStyle link = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: DT.brand,
  );

  /// Price in the sticky bottom bar.
  static const TextStyle price = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w700,
    color: DT.textPrimary,
  );

  // --------------------------------------------------------------- metric
  static const double gutter = 16;
  static const double cardRadius = 14;
  static const double tileRadius = 10;

  /// Height of the pinned tab strip on the detail screen — the anchored
  /// scroll offsets subtract this so a section header is never hidden.
  static const double tabStripHeight = 52;

  static BoxDecoration get card => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      );

  /// The 8px grey band the mockups use between full-width sections.
  static Widget get sectionGap => Container(height: 10, color: canvas);

  // ---------------------------------------------------------------- helpers
  /// Opacity without `withOpacity` (deprecated) or `withValues` (needs a
  /// recent SDK) — keeps this folder compiling on either.
  static Color fade(Color c, double opacity) =>
      c.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());

  /// Pastel badge pairs cycled by the "Sekitar" grid — `(fill, glyph)`.
  static const List<List<Color>> pastels = [
    [Color(0xFFFDE7E7), Color(0xFFE57373)],
    [Color(0xFFFFF3DF), Color(0xFFEFA33B)],
    [Color(0xFFE3F0FD), Color(0xFF5B9BE8)],
    [Color(0xFFEFE6FB), Color(0xFF9575CD)],
    [Color(0xFFE3F7EA), Color(0xFF4CAF7D)],
  ];

  static Color pastelFill(int tone) => pastels[tone % pastels.length][0];

  static Color pastelGlyph(int tone) => pastels[tone % pastels.length][1];
}


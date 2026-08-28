import 'package:flutter/material.dart';

/// The app's single dark palette, following a 60/30/10 split:
/// - 60% [background] — the dominant tone, the scaffold body itself.
/// - 30% [surface] (and its lighter/darker steps) — cards, app bars, the
///   bottom nav, dialogs, input fields — everything that reads as a panel
///   sitting on top of the background.
/// - 10% [accent] — the one brand color, reserved for primary actions,
///   selection state, and things that should actually grab the eye
///   (CTAs, the active nav item, "this is due now" highlights).
///
/// Semantic data colors (win/loss green-red, fighter-corner blue/red,
/// event-type icons in the play-by-play feed) are deliberately left
/// outside this system — they encode meaning, not brand, so recoloring
/// them to the single accent would make the data harder to read, not
/// more polished.
class AppColors {
  AppColors._();

  static const background = Color(0xFF0A0A0C);

  static const surfaceContainerLow = Color(0xFF161619);
  static const surface = Color(0xFF1F1F23);
  static const surfaceContainerHigh = Color(0xFF2A2A30);
  static const surfaceContainerHighest = Color(0xFF34343B);

  static const accent = Color(0xFFFF0033);
  static const accentContainer = Color(0xFF3B0A16);
  static const accentContainerStrong = Color(0xFF5C0F20);

  static const textMuted = Color(0xFFA6A6AE);
  static const outline = Color(0xFF2E2E34);
  static const outlineVariant = Color(0xFF1C1C20);
}

class AppTheme {
  AppTheme._();

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.accent,
    onPrimary: Colors.white,
    primaryContainer: AppColors.accentContainer,
    onPrimaryContainer: Colors.white,
    // `secondary` intentionally reuses a neutral surface tone rather than
    // a second hue — the palette has exactly one accent color.
    secondary: AppColors.surfaceContainerHigh,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.surfaceContainerHigh,
    onSecondaryContainer: Colors.white,
    tertiary: AppColors.accent,
    onTertiary: Colors.white,
    // A stronger accent tint for "this needs you now" highlights (a due
    // event on the dashboard/calendar) — same hue, more saturated, so it
    // reads as more urgent than the decorative primaryContainer.
    tertiaryContainer: AppColors.accentContainerStrong,
    onTertiaryContainer: Colors.white,
    error: AppColors.accent,
    onError: Colors.white,
    errorContainer: AppColors.accentContainer,
    onErrorContainer: Colors.white,
    surface: AppColors.surface,
    onSurface: Colors.white,
    surfaceDim: AppColors.background,
    surfaceBright: AppColors.surfaceContainerHigh,
    surfaceContainerLowest: AppColors.background,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surface,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    onSurfaceVariant: AppColors.textMuted,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    shadow: Colors.black,
    scrim: Colors.black87,
    inverseSurface: Colors.white,
    onInverseSurface: AppColors.background,
    inversePrimary: AppColors.accent,
    // Material 3 tints elevated surfaces toward `primary` by default; with
    // a red primary that would wash every card pink. Flat panels, exact
    // hex, is the look we want.
    surfaceTint: Colors.transparent,
  );

  static ThemeData dark() {
    const colorScheme = _colorScheme;
    final pillShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(28));
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.outline),
    );
    final fieldShape = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outline),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: cardShape,
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textMuted,
        textColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : AppColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? Colors.white : AppColors.textMuted);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceContainerHigh,
          disabledForegroundColor: AppColors.textMuted,
          shape: pillShape,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceContainerHigh,
          disabledForegroundColor: AppColors.textMuted,
          elevation: 0,
          shape: pillShape,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: AppColors.outline),
          shape: pillShape,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accent),
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(Colors.white),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: fieldShape,
        enabledBorder: fieldShape,
        focusedBorder: fieldShape.copyWith(
          borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
        ),
        labelStyle: const TextStyle(color: AppColors.textMuted),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.outline,
        thumbColor: AppColors.accent,
        overlayColor: AppColors.accent.withOpacity(0.2),
        valueIndicatorColor: AppColors.accent,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        circularTrackColor: AppColors.surfaceContainerHigh,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        space: 1,
        thickness: 1,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        selectedColor: AppColors.accent,
        labelStyle: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        side: BorderSide(color: AppColors.outline),
        shape: StadiumBorder(),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      badgeTheme: const BadgeThemeData(
        backgroundColor: AppColors.accent,
        textColor: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      tabBarTheme: const TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.accent,
      ),
    );
  }
}

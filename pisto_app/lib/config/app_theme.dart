import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _primary = Color(0xFF1A56DB);
  static const _secondary = Color(0xFF0E9F6E);
  static const _tertiary = Color(0xFF6B7280);

  static const chartOrange = Color(0xFFE67E22);
  static const chartPurple = Color(0xFF9B59B6);

  static ThemeData get light => FlexThemeData.light(
        colors: const FlexSchemeColor(
          primary: _primary,
          primaryContainer: Color(0xFFDBEAFE),
          secondary: _secondary,
          secondaryContainer: Color(0xFFDEF7EC),
          tertiary: _tertiary,
          tertiaryContainer: Color(0xFFF3F4F6),
        ),
        keyColors: const FlexKeyColors(
          useKeyColors: true,
          useSecondary: true,
          useTertiary: true,
          keepPrimary: true,
          keepSecondary: true,
          keepPrimaryContainer: true,
          keepSecondaryContainer: true,
        ),
        tones: FlexTones.soft(Brightness.light),
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 4,
        appBarStyle: FlexAppBarStyle.surface,
        subThemesData: const FlexSubThemesData(
          interactionEffects: true,
          blendOnLevel: 6,
          useM2StyleDividerInM3: false,
          defaultRadius: 10,
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorRadius: 10,
          inputDecoratorIsFilled: true,
          inputDecoratorBackgroundAlpha: 0x0A,
          inputDecoratorFocusedHasBorder: true,
          inputDecoratorUnfocusedHasBorder: true,
          inputDecoratorBorderWidth: 1.0,
          inputDecoratorFocusedBorderWidth: 2.0,
          cardRadius: 12,
          cardElevation: 0,
          filledButtonRadius: 10,
          elevatedButtonRadius: 10,
          outlinedButtonRadius: 10,
          textButtonRadius: 10,
          chipRadius: 8,
          dialogRadius: 16,
          bottomSheetRadius: 20,
          popupMenuRadius: 10,
          navigationRailBackgroundSchemeColor: SchemeColor.surfaceContainerLow,
          navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
          navigationRailIndicatorSchemeColor: SchemeColor.primaryContainer,
          navigationRailIndicatorRadius: 12,
          navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
          navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
          navigationBarIndicatorRadius: 12,
          tabBarItemSchemeColor: SchemeColor.primary,
          tabBarIndicatorSchemeColor: SchemeColor.primary,
          appBarScrolledUnderElevation: 0.5,
        ),
        textTheme: _textTheme,
        primaryTextTheme: _textTheme,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
      );

  static ThemeData get dark => FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary: Color(0xFF76A9FA),
          primaryContainer: Color(0xFF1E40AF),
          secondary: Color(0xFF31C48D),
          secondaryContainer: Color(0xFF065F46),
          tertiary: Color(0xFF9CA3AF),
          tertiaryContainer: Color(0xFF374151),
        ),
        keyColors: const FlexKeyColors(
          useKeyColors: true,
          useSecondary: true,
          useTertiary: true,
          keepPrimary: true,
          keepSecondary: true,
          keepPrimaryContainer: true,
          keepSecondaryContainer: true,
        ),
        tones: FlexTones.soft(Brightness.dark),
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 8,
        appBarStyle: FlexAppBarStyle.surface,
        subThemesData: const FlexSubThemesData(
          interactionEffects: true,
          blendOnLevel: 12,
          useM2StyleDividerInM3: false,
          defaultRadius: 10,
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorRadius: 10,
          inputDecoratorIsFilled: true,
          inputDecoratorBackgroundAlpha: 0x14,
          inputDecoratorFocusedHasBorder: true,
          inputDecoratorUnfocusedHasBorder: true,
          inputDecoratorBorderWidth: 1.0,
          inputDecoratorFocusedBorderWidth: 2.0,
          cardRadius: 12,
          cardElevation: 0,
          filledButtonRadius: 10,
          elevatedButtonRadius: 10,
          outlinedButtonRadius: 10,
          textButtonRadius: 10,
          chipRadius: 8,
          dialogRadius: 16,
          bottomSheetRadius: 20,
          popupMenuRadius: 10,
          navigationRailBackgroundSchemeColor: SchemeColor.surfaceContainerLow,
          navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
          navigationRailIndicatorSchemeColor: SchemeColor.primaryContainer,
          navigationRailIndicatorRadius: 12,
          navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
          navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
          navigationBarIndicatorRadius: 12,
          tabBarItemSchemeColor: SchemeColor.primary,
          tabBarIndicatorSchemeColor: SchemeColor.primary,
          appBarScrolledUnderElevation: 0.5,
        ),
        textTheme: _textTheme,
        primaryTextTheme: _textTheme,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
      );

  static TextTheme get _textTheme => GoogleFonts.interTextTheme();
}

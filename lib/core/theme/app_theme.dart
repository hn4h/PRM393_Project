import 'package:flutter/material.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: AppColors.primary,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    // Explicit text theme with light-mode colors
    textTheme: TextTheme(
      displayLarge: AppTextStyles.display1.copyWith(color: AppColors.textPrimary),
      displayMedium: AppTextStyles.display2.copyWith(color: AppColors.textPrimary),
      headlineLarge: AppTextStyles.headline1.copyWith(color: AppColors.textPrimary),
      headlineMedium: AppTextStyles.headline2.copyWith(color: AppColors.textPrimary),
      headlineSmall: AppTextStyles.headline3.copyWith(color: AppColors.textPrimary),
      bodyLarge: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
      bodyMedium: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
      bodySmall: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      labelLarge: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.headline3.copyWith(
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        textStyle: AppTextStyles.buttonPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.buttonSecondary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.buttonSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
      hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textHint),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 2,
      shadowColor: AppColors.shadow,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      labelStyle: AppTextStyles.chip,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide.none,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: AppTextStyles.body2,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    // List tile text colors for light
    listTileTheme: ListTileThemeData(
      textColor: AppColors.textPrimary,
      iconColor: AppColors.textSecondary,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkScaffoldBackground,
    // Explicit text theme with dark-mode colors — white/light text on dark bg
    textTheme: TextTheme(
      displayLarge: AppTextStyles.display1.copyWith(color: AppColors.darkTextPrimary),
      displayMedium: AppTextStyles.display2.copyWith(color: AppColors.darkTextPrimary),
      headlineLarge: AppTextStyles.headline1.copyWith(color: AppColors.darkTextPrimary),
      headlineMedium: AppTextStyles.headline2.copyWith(color: AppColors.darkTextPrimary),
      headlineSmall: AppTextStyles.headline3.copyWith(color: AppColors.darkTextPrimary),
      bodyLarge: AppTextStyles.body1.copyWith(color: AppColors.darkTextPrimary),
      bodyMedium: AppTextStyles.body2.copyWith(color: AppColors.darkTextPrimary),
      bodySmall: AppTextStyles.caption.copyWith(color: AppColors.darkTextSecondary),
      labelLarge: AppTextStyles.label.copyWith(color: AppColors.darkTextSecondary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.headline3.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.darkTextSecondary,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        textStyle: AppTextStyles.buttonPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        textStyle: AppTextStyles.buttonSecondary,
        side: const BorderSide(color: AppColors.primaryLight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        textStyle: AppTextStyles.buttonSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: AppTextStyles.label.copyWith(color: AppColors.darkTextSecondary),
      hintStyle: AppTextStyles.caption.copyWith(color: AppColors.darkTextHint),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCardBackground,
      elevation: 2,
      shadowColor: AppColors.darkShadow,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
      labelStyle: AppTextStyles.chip.copyWith(color: AppColors.primaryLight),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide.none,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primaryLight,
      unselectedLabelColor: AppColors.darkTextSecondary,
      labelStyle: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: AppTextStyles.body2,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
      ),
    ),
    // List tile text colors for dark — ensures list items are readable
    listTileTheme: ListTileThemeData(
      textColor: AppColors.darkTextPrimary,
      iconColor: AppColors.darkTextSecondary,
    ),
    // Switch / toggle colors
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
        return AppColors.darkTextSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.5);
        }
        return AppColors.darkBorder;
      }),
    ),
    // Dialog theme for dark
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      titleTextStyle: AppTextStyles.headline3.copyWith(color: AppColors.darkTextPrimary),
      contentTextStyle: AppTextStyles.body1.copyWith(color: AppColors.darkTextPrimary),
    ),
    // Dropdown menu theme
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: AppTextStyles.body2.copyWith(color: AppColors.darkTextPrimary),
    ),
  );
}

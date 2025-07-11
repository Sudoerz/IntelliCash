import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:intellicash/core/extensions/color.extensions.dart';

import 'app_colors.dart';

bool isAppUsingDynamicColors = false;

bool isAppInDarkBrightness(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;
bool isAppInLightBrightness(BuildContext context) =>
    !isAppInDarkBrightness(context);

extension TextThemeExtension on TextTheme {
  /// Returns a new [TextTheme] where selected body and label text styles have their
  /// color updated to the specified [color].
  ///
  /// The styles affected by this change are:
  /// - [bodyLarge]
  /// - [bodyMedium]
  /// - [bodySmall]
  /// - [labelMedium]
  /// - [labelSmall]
  TextTheme withDifferentBodyColors(Color color) {
    TextStyle? applyColor(TextStyle? style) => style?.copyWith(color: color);

    return copyWith(
      bodyLarge: applyColor(bodyLarge),
      bodyMedium: applyColor(bodyMedium),
      bodySmall: applyColor(bodySmall),
      labelMedium: applyColor(labelMedium),
      labelSmall: applyColor(labelSmall),
    );
  }
}

ThemeData getThemeData(
  BuildContext context, {
  required bool isDark,
  required bool amoledMode,
  required ColorScheme? lightDynamic,
  required ColorScheme? darkDynamic,
  required String accentColor,
}) {
  ThemeData theme;

  ColorScheme lightColorScheme;
  ColorScheme darkColorScheme;

  if (lightDynamic != null && darkDynamic != null && accentColor == 'auto') {
    // On Android S+ devices, use the provided dynamic color scheme.
    // (Recommended) Harmonize the dynamic color scheme' built-in semantic colors.
    lightColorScheme = ColorScheme.fromSeed(
      seedColor: lightDynamic.primary,
      brightness: Brightness.light,
    ).harmonized();

    // Repeat for the dark color scheme.
    darkColorScheme = ColorScheme.fromSeed(
      seedColor: darkDynamic.primary,
      brightness: Brightness.dark,
      surface: amoledMode ? Colors.black : null,
    );

    // TODO: We can directly use the dynamic palette here, in the following way

    // lightColorScheme = lightDynamic.harmonized();
    // darkColorScheme = darkDynamic.harmonized();

    // if (amoledMode) {
    //   darkColorScheme = darkColorScheme.copyWith(surface: Colors.black);
    // }

    // However, the colorSchemes provided by the `dynamic_color` package do not generate the
    // new surface colors of Flutter 3.22. See https://github.com/material-foundation/flutter-packages/issues/582#issuecomment-2209591668
    // for more info

    isAppUsingDynamicColors = true; // ignore, only for demo purposes
  } else {
    // Otherwise, use fallback schemes:

    /// Fallback scheme for a not-dynamic mode in dark or light mode:
    ColorScheme fallbackScheme = ColorScheme.fromSeed(
      seedColor: accentColor == 'auto' ? brandBlue : ColorHex.get(accentColor),
      brightness: isDark ? Brightness.dark : Brightness.light,
      surface: isDark && amoledMode ? Colors.black : null,
    );

    lightColorScheme = fallbackScheme;
    darkColorScheme = fallbackScheme;
  }

  AppColors customAppColors =
      AppColors.fromColorScheme(isDark ? darkColorScheme : lightColorScheme);

  theme = ThemeData(
      colorScheme: isDark ? darkColorScheme : lightColorScheme,
      brightness: isDark ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      fontFamily: 'Jost',
      extensions: [customAppColors]);

  final textTheme =
      theme.textTheme.withDifferentBodyColors(customAppColors.textBody);

  final listTileSmallText = textTheme.bodyMedium?.copyWith(
    fontSize: 14,
    wordSpacing: 0,
    decorationThickness: 1,
    fontFamily: 'Jost',
  );

  return theme.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: theme.colorScheme.surface,
    dividerTheme: const DividerThemeData(space: 0),
    cardColor: theme.colorScheme.surfaceContainer,
    cardTheme: const CardThemeData(),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest,
      isDense: true,
      hintStyle: TextStyle(color: customAppColors.textHint),
      floatingLabelStyle: TextStyle(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
    ),
    bottomSheetTheme: theme.bottomSheetTheme.copyWith(
      elevation: 0,
      dragHandleSize: const Size(25, 4),
      modalBackgroundColor: customAppColors.modalBackground,
      dragHandleColor: Colors.grey[300],
      clipBehavior: Clip.hardEdge,
    ),
    listTileTheme: theme.listTileTheme.copyWith(
      minVerticalPadding: 8,
      subtitleTextStyle:
          listTileSmallText?.copyWith(fontWeight: FontWeight.w300),
      leadingAndTrailingTextStyle: listTileSmallText,
    ),
  );
}

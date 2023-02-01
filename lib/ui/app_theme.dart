import 'package:flex_color_scheme/flex_color_scheme.dart';

class AppTheme {
  static final theme = FlexThemeData.light(
    scheme: FlexScheme.ebonyClay,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 9,
    transparentStatusBar: false,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      blendOnColors: false,
      inputDecoratorRadius: 10.0,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
  );
  static final darkTheme = FlexThemeData.dark(
    scheme: FlexScheme.ebonyClay,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 15,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      inputDecoratorRadius: 10.0,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
  );
}

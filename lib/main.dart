import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/game_board_screen.dart';
import 'screens/main_menu.dart';
import 'screens/placement_screen.dart';
import 'state/game_controller.dart';
import 'utils/constants.dart';
import 'utils/translations.dart';

// Entry Point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setHighRefreshRate();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    Get.put(GameController());
    runApp(const BattleshipApp());
  });
}

Future<void> setHighRefreshRate() async {
  try {
    final List<DisplayMode> modes = await FlutterDisplayMode.supported;

    final DisplayMode highRefreshMode = modes.firstWhere(
      (m) => m.refreshRate >= 120,
      orElse: () =>
          modes.reduce((a, b) => a.refreshRate > b.refreshRate ? a : b),
    );

    await FlutterDisplayMode.setPreferredMode(highRefreshMode);
  } catch (e) {
    debugPrint("ไม่สามารถเปิดโหมด 120fps ได้: $e");
  }
}

// Main Application
class BattleshipApp extends StatelessWidget {
  const BattleshipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Paper Battleship',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData.light().copyWith(
        primaryColor: AppColors.ink,
        scaffoldBackgroundColor: AppColors.paper,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.ink),
        textTheme:
            GoogleFonts.promptTextTheme(ThemeData.light().textTheme).apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const MainMenuScreen(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 400),
        ),
        GetPage(
          name: '/placement',
          page: () => const PlacementScreen(),
          transition: Transition.zoom,
          transitionDuration: const Duration(milliseconds: 400),
        ),
        GetPage(
          name: '/game',
          page: () => const GameBoardScreen(),
          transition: Transition.rightToLeftWithFade,
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/main_menu.dart';
import 'screens/placement_screen.dart';
import 'screens/game_board_screen.dart';
import 'state/game_controller.dart';
import 'utils/translations.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    Get.put(GameController());
    runApp(const BattleshipApp());
  });
}

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
        ),
        GetPage(
          name: '/placement',
          page: () => const PlacementScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/game',
          page: () => const GameBoardScreen(),
          transition: Transition.rightToLeft,
        ),
      ],
    );
  }
}

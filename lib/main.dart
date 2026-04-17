import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/game_board_screen.dart';
import 'screens/main_menu.dart';
import 'screens/placement_screen.dart';
import 'state/game_controller.dart';
import 'utils/constants.dart';
import 'utils/translations.dart';

// Entry Point
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

// Custom Transitions
class ModernPremiumTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.03, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }
}

class CinematicPanTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(0.05, 0.0), end: Offset.zero)
                .animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
        ),
        child: child,
      ),
    );
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
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: '/placement',
          page: () => const PlacementScreen(),
          customTransition: ModernPremiumTransition(),
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: '/game',
          page: () => const GameBoardScreen(),
          customTransition: CinematicPanTransition(),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      ],
    );
  }
}

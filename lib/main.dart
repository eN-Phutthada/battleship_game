import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_menu.dart';
import 'screens/placement_screen.dart';
import 'screens/game_board_screen.dart';
import 'state/game_controller.dart';
import 'utils/translations.dart';

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
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),

      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF000080),
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
        textTheme: GoogleFonts.promptTextTheme(ThemeData.dark().textTheme),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const MainMenuScreen()),
        GetPage(name: '/placement', page: () => const PlacementScreen()),
        GetPage(name: '/game', page: () => const GameBoardScreen()),
      ],
    );
  }
}

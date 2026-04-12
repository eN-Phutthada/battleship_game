import 'dart:math';
import 'package:battleship_game/state/game_controller.dart';
import 'package:battleship_game/state/multiplayer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../widgets/shared_widgets.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  int enemyCount = 1;
  String botSpeed = 'NORMAL';
  bool isMuted = false;
  BotDifficulty botDifficulty = BotDifficulty.normal;

  final TextEditingController _nameController = TextEditingController();
  late AnimationController _animController;
  final mpCtrl = Get.put(MultiplayerController());

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleLanguage() {
    HapticFeedback.lightImpact();
    if (Get.locale?.languageCode == 'th') {
      Get.updateLocale(const Locale('en', 'US'));
    } else {
      Get.updateLocale(const Locale('th', 'TH'));
    }
  }

  Widget _buildStep(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.ink, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _showHowToPlay() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 16,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 800,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.paper,
              border: Border.all(color: AppColors.ink, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black26, offset: Offset(8, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book,
                          color: AppColors.ink,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'how_to_play'.tr,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.ink,
                        size: 28,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const Divider(color: AppColors.ink, thickness: 2, height: 16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'deployment_phase'.tr,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w900,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildStep(Icons.landscape, 'help_step_1'.tr),
                              const SizedBox(height: 8),
                              _buildStep(Icons.fort, 'help_step_2'.tr),
                              const SizedBox(height: 8),
                              _buildStep(
                                Icons.directions_boat,
                                'help_step_3'.tr,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'ammo_legend_title'.tr,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w900,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ammo_legend_desc'.tr,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        color: AppColors.ink,
                        width: 40,
                        thickness: 1,
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'combat_rules'.tr,
                                      style: const TextStyle(
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w900,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'rule_1'.tr,
                                            style: TextStyle(
                                              color: Colors.red[800],
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'rule_2'.tr,
                                            style: TextStyle(
                                              color: Colors.red[800],
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'rule_3'.tr,
                                            style: TextStyle(
                                              color: Colors.red[800],
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.ink,
                                  shape: const RoundedRectangleBorder(),
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'roger_that'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMultiplayerLAN() {
    HapticFeedback.heavyImpact();
    final TextEditingController ipInput = TextEditingController();
    String myName = _nameController.text.trim().isEmpty
        ? "COMMANDER"
        : _nameController.text.trim().toUpperCase();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Obx(
        () => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 10,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 550),
            decoration: BoxDecoration(
              color: AppColors.paper,
              border: Border.all(color: AppColors.ink, width: 3),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black26, offset: Offset(8, 8)),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.wifi_tethering,
                            color: AppColors.ink,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'network_lobby'.tr,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.ink),
                        onPressed: () {
                          mpCtrl.leaveLobby();
                          Get.back();
                        },
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.ink, thickness: 2, height: 25),
                  if (!mpCtrl.isConnected.value && !mpCtrl.isHosting.value)
                    _buildSetupUI(ipInput, myName)
                  else
                    _buildActiveLobbyUI(myName),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _diffBtn(BotDifficulty diff, String label) {
    bool isSel = botDifficulty == diff;
    return Expanded(
      child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => botDifficulty = diff);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
                color: isSel ? AppColors.ink : Colors.transparent,
                border: Border.all(color: AppColors.ink),
                borderRadius: BorderRadius.circular(4)),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: isSel ? Colors.white : AppColors.ink,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          )),
    );
  }

  Widget _buildSetupUI(TextEditingController ipInput, String myName) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.ink.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "${'your_ip'.tr} ${mpCtrl.myIp.value}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  const Icon(
                    Icons.maps_home_work_outlined,
                    size: 40,
                    color: AppColors.ink,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => mpCtrl.startHost(myName),
                    child: Text(
                      'host_game_btn'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'host_desc'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.ink.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: SizedBox(
                height: 120,
                child: VerticalDivider(color: AppColors.ink, thickness: 0.5),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  if (mpCtrl.isScanning.value)
                    const SizedBox(
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.ink,
                        ),
                      ),
                    )
                  else
                    IconButton.filledTonal(
                      icon: const Icon(
                        Icons.search,
                        size: 24,
                        color: AppColors.ink,
                      ),
                      onPressed: () => mpCtrl.scanForLobbies(),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.ink.withOpacity(0.1),
                      ),
                    ),
                  Text(
                    'quick_scan'.tr,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (mpCtrl.discoveredLobbies.isNotEmpty)
                    ...mpCtrl.discoveredLobbies
                        .map(
                          (lobby) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: InkWell(
                              onTap: () =>
                                  mpCtrl.joinBattle(lobby['ip']!, myName),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.orange[800]!,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.orange.withOpacity(0.1),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.bolt,
                                      color: Colors.orange,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "${lobby['name']}",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.ink,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList()
                  else
                    Text(
                      'no_signals'.tr,
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: AppColors.ink.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            children: [
              const Expanded(
                child: Divider(color: AppColors.ink, thickness: 0.5),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'join_via_ip'.tr,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(color: AppColors.ink, thickness: 0.5),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: ipInput,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: "192.168.x.x",
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.ink.withOpacity(0.4),
                  ),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.ink),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: AppColors.ink,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.ink, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => mpCtrl.joinBattle(ipInput.text, myName),
                child: Text(
                  'join_btn'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveLobbyUI(String myName) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 18),
              const SizedBox(width: 10),
              Text(
                mpCtrl.isHosting.value
                    ? 'room_open'.trParams({'ip': mpCtrl.myIp.value})
                    : 'connected_station'.tr,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          constraints: const BoxConstraints(maxHeight: 180),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: mpCtrl.lobbyPlayers.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              var p = mpCtrl.lobbyPlayers[index];
              bool isMe = p['name'] == myName;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isMe ? AppColors.ink : AppColors.ink.withOpacity(0.2),
                    width: isMe ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      p['isHost'] == true ? Icons.stars : Icons.person,
                      color: p['isHost'] == true
                          ? Colors.orange[800]
                          : AppColors.ink,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      p['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                    ),
                    const Spacer(),
                    if (isMe)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'you_tag'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => mpCtrl.leaveLobby(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.redPen, width: 2),
                ),
                child: Text(
                  mpCtrl.isHosting.value ? 'abandon_btn'.tr : 'leave_btn'.tr,
                  style: const TextStyle(
                    color: AppColors.redPen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (mpCtrl.isHosting.value)
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.rocket_launch, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mpCtrl.lobbyPlayers.length > 1
                        ? Colors.green[700]
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: mpCtrl.lobbyPlayers.length > 1
                      ? () => mpCtrl.broadcastStart()
                      : null,
                  label: Text(
                    'start_mission'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    const LinearProgressIndicator(
                      color: AppColors.ink,
                      backgroundColor: Colors.black12,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'waiting_commander'.tr,
                      style: const TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: AnimatedPaperBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            final value = _animController.value * 2 * pi;
                            return Transform.translate(
                              offset: Offset(0, 10 * sin(value)),
                              child: Transform.rotate(
                                angle: -0.1 + (0.05 * cos(value)),
                                child: const Icon(
                                  Icons.directions_boat_outlined,
                                  size: 90,
                                  color: AppColors.ink,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.elasticOut,
                          builder: (context, val, child) => Transform.scale(
                            scale: val,
                            child: const Text(
                              'PAPER\nBATTLESHIP',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: AppColors.ink,
                                letterSpacing: 4,
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.wavy,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 2,
                    height: double.infinity,
                    color: AppColors.ink.withOpacity(0.3),
                    margin: const EdgeInsets.symmetric(vertical: 40),
                  ),
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'mission_briefing'.tr,
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: _toggleLanguage,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: AppColors.ink,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            Get.locale?.languageCode == 'th'
                                                ? 'TH'
                                                : 'EN',
                                            style: const TextStyle(
                                              color: AppColors.ink,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            isMuted = !isMuted;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: AppColors.ink,
                                              width: 2,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isMuted
                                                ? Icons.volume_off
                                                : Icons.volume_up,
                                            color: AppColors.ink,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: _showHowToPlay,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                              color: AppColors.ink,
                                              width: 2,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.question_mark,
                                            color: AppColors.ink,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: AppColors.ink,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: _nameController,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    letterSpacing: 2,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'commander_name'.tr,
                                    prefixIcon: const Icon(
                                      Icons.badge,
                                      color: AppColors.ink,
                                    ),
                                    labelStyle: TextStyle(
                                      color: AppColors.ink.withOpacity(0.6),
                                      letterSpacing: 1,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: AppColors.ink,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.smart_toy,
                                          color: AppColors.ink,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'local_campaign'.tr,
                                          style: const TextStyle(
                                            color: AppColors.ink,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text('difficulty'.tr,
                                        style: const TextStyle(
                                            color: AppColors.ink,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        _diffBtn(
                                            BotDifficulty.easy, 'diff_easy'.tr),
                                        const SizedBox(width: 6),
                                        _diffBtn(BotDifficulty.normal,
                                            'diff_normal'.tr),
                                        const SizedBox(width: 6),
                                        _diffBtn(
                                            BotDifficulty.hard, 'diff_hard'.tr),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Column(
                                      children: [
                                        Text(
                                          'enemies'.tr,
                                          style: const TextStyle(
                                            color: AppColors.ink,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                color: AppColors.ink,
                                              ),
                                              onPressed: () {
                                                HapticFeedback.lightImpact();
                                                setState(() {
                                                  if (enemyCount > 1) {
                                                    enemyCount--;
                                                  }
                                                });
                                              },
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: AppColors.ink,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                "$enemyCount",
                                                style: const TextStyle(
                                                  color: AppColors.ink,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                                color: AppColors.ink,
                                              ),
                                              onPressed: () {
                                                HapticFeedback.lightImpact();
                                                setState(() {
                                                  if (enemyCount < 7) {
                                                    enemyCount++;
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        HapticFeedback.heavyImpact();
                                        Get.find<GameController>()
                                            .botDifficulty = botDifficulty;
                                        Get.toNamed(
                                          '/placement',
                                          arguments: {
                                            'enemyCount': enemyCount,
                                            'playerName': _nameController.text
                                                    .trim()
                                                    .isEmpty
                                                ? "COMMANDER"
                                                : _nameController.text
                                                    .trim()
                                                    .toUpperCase(),
                                            'botSpeed': botSpeed,
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.rocket_launch,
                                        color: AppColors.paper,
                                      ),
                                      label: Text(
                                        'engage_bots'.tr,
                                        style: const TextStyle(
                                          color: AppColors.paper,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.ink,
                                        minimumSize: const Size(
                                          double.infinity,
                                          50,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: AppColors.ink.withOpacity(0.5),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.satellite_alt,
                                          color: AppColors.ink,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'network_battle'.tr,
                                          style: const TextStyle(
                                            color: AppColors.ink,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    OutlinedButton.icon(
                                      onPressed: _showMultiplayerLAN,
                                      icon: const Icon(
                                        Icons.cell_tower,
                                        color: AppColors.ink,
                                      ),
                                      label: Text(
                                        'host_join'.tr,
                                        style: const TextStyle(
                                          color: AppColors.ink,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: AppColors.ink,
                                          width: 2,
                                        ),
                                        minimumSize: const Size(
                                          double.infinity,
                                          45,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 8,
                left: 16,
                child: Text(
                  "v1.0.0 - Commander Edition",
                  style: TextStyle(
                    color: AppColors.ink.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:battleship_game/state/game_controller.dart';
import 'package:battleship_game/state/multiplayer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../widgets/shared_widgets.dart';

// ✅ เพิ่ม Enum สำหรับจัดการขนาดพื้นที่รบ
enum BoardSize { standard, large, huge }

extension BoardSizeExt on BoardSize {
  int get cols =>
      this == BoardSize.standard ? 8 : (this == BoardSize.large ? 10 : 12);
  int get rows =>
      this == BoardSize.standard ? 6 : (this == BoardSize.large ? 8 : 10);
  String get label => this == BoardSize.standard
      ? '8x6'
      : (this == BoardSize.large ? '10x8' : '12x10');
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  // --- Game Settings ---
  int enemyCount = 1;
  bool isMuted = false;
  BotDifficulty botDifficulty = BotDifficulty.normal;
  AssistLevel assistLevel = AssistLevel.standard;
  BoardSize boardSize = BoardSize.standard; // ✅ ตัวแปรเก็บขนาดตาราง

  // --- Controllers ---
  final TextEditingController _nameController = TextEditingController();
  late AnimationController _animController;
  final mpCtrl = Get.put(MultiplayerController());

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleLanguage() {
    HapticFeedback.lightImpact();
    final locales = ['en', 'th', 'es', 'ja'];
    String currentLang = Get.locale?.languageCode ?? 'en';

    int nextIdx = (locales.indexOf(currentLang) + 1) % locales.length;
    String nextLang = locales[nextIdx];

    switch (nextLang) {
      case 'th':
        Get.updateLocale(const Locale('th', 'TH'));
        break;
      case 'es':
        Get.updateLocale(const Locale('es', 'ES'));
        break;
      case 'ja':
        Get.updateLocale(const Locale('ja', 'JP'));
        break;
      default:
        Get.updateLocale(const Locale('en', 'US'));
        break;
    }
  }

  Widget _buildStep(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.ink, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.bold,
                      fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildHelpSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.ink, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                decoration: TextDecoration.underline)),
      ],
    );
  }

  Widget _buildDescItem(String text) {
    return Text(text,
        style: const TextStyle(
            color: AppColors.ink,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            height: 1.3));
  }

  void _showHowToPlay() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            constraints: const BoxConstraints(maxWidth: 900, maxHeight: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.paper,
              border: Border.all(color: AppColors.ink, width: 3),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Colors.black26, offset: Offset(8, 8))
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
                        const Icon(Icons.menu_book,
                            color: AppColors.ink, size: 32),
                        const SizedBox(width: 12),
                        Text('how_to_play'.tr,
                            style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: 1.5)),
                      ],
                    ),
                    IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close,
                            color: AppColors.ink, size: 32),
                        onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
                const Divider(color: AppColors.ink, thickness: 2, height: 24),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHelpSectionTitle(
                                    Icons.map, 'deployment_phase'.tr),
                                const SizedBox(height: 8),
                                _buildStep(Icons.landscape, 'help_step_1'.tr),
                                _buildStep(Icons.fort, 'help_step_2'.tr),
                                _buildStep(
                                    Icons.directions_boat, 'help_step_3'.tr),
                                const SizedBox(height: 20),
                                _buildHelpSectionTitle(
                                    Icons.gavel, 'combat_rules'.tr),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.05),
                                      border: Border.all(
                                          color: Colors.red.withOpacity(0.5),
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('rule_1'.tr,
                                          style: TextStyle(
                                              color: Colors.red[800],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900)),
                                      const SizedBox(height: 8),
                                      Text('rule_2'.tr,
                                          style: TextStyle(
                                              color: Colors.red[800],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900)),
                                      const SizedBox(height: 8),
                                      Text('rule_3'.tr,
                                          style: TextStyle(
                                              color: Colors.red[800],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(
                          color: AppColors.ink, width: 30, thickness: 1.5),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildHelpSectionTitle(Icons.smart_toy,
                                          'help_diff_title'.tr),
                                      const SizedBox(height: 8),
                                      _buildDescItem('help_diff_easy'.tr),
                                      const Divider(
                                          color: Colors.black12, height: 16),
                                      _buildDescItem('help_diff_normal'.tr),
                                      const Divider(
                                          color: Colors.black12, height: 16),
                                      _buildDescItem('help_diff_hard'.tr),
                                      const SizedBox(height: 20),
                                      _buildHelpSectionTitle(Icons.handshake,
                                          'help_assist_title'.tr),
                                      const SizedBox(height: 8),
                                      _buildDescItem('help_ast_casual'.tr),
                                      const Divider(
                                          color: Colors.black12, height: 16),
                                      _buildDescItem('help_ast_standard'.tr),
                                      const Divider(
                                          color: Colors.black12, height: 16),
                                      _buildDescItem('help_ast_hardcore'.tr),
                                      const Divider(
                                          color: Colors.black12, height: 16),
                                      _buildDescItem('help_ast_reallife'.tr),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.thumb_up,
                                    color: Colors.white, size: 18),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.ink,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6))),
                                onPressed: () => Navigator.of(context).pop(),
                                label: Text('roger_that'.tr,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                        fontSize: 16)),
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

  Widget _lobbyAssistBtn(AssistLevel level, String label) {
    bool isSel = mpCtrl.currentAssistLevel.value == level;
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
            onTap: () {
              if (mpCtrl.isHosting.value) {
                HapticFeedback.lightImpact();
                // ✅ อัปเดตทั้งกฎการเล่นและขนาดตารางไปพร้อมกัน
                mpCtrl.updateLobbySettings(level, mpCtrl.currentColumns.value,
                    mpCtrl.currentRows.value);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                  color: isSel ? AppColors.redPen : Colors.transparent,
                  border: Border.all(
                      color: isSel ? AppColors.redPen : Colors.black26),
                  borderRadius: BorderRadius.circular(4)),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isSel ? Colors.white : Colors.black38,
                        fontWeight: FontWeight.w900)),
              ),
            )),
      ),
    );
  }

  // ✅ เพิ่มปุ่มเลือกขนาดตารางสำหรับโหมด Lobby
  Widget _lobbySizeBtn(BoardSize size) {
    bool isSel = mpCtrl.currentColumns.value == size.cols;
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
            onTap: () {
              if (mpCtrl.isHosting.value) {
                HapticFeedback.lightImpact();
                mpCtrl.updateLobbySettings(
                    mpCtrl.currentAssistLevel.value, size.cols, size.rows);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                  color: isSel ? Colors.green[800] : Colors.transparent,
                  border: Border.all(
                      color: isSel ? Colors.green[800]! : Colors.black26),
                  borderRadius: BorderRadius.circular(4)),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(size.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isSel ? Colors.white : Colors.black38,
                        fontWeight: FontWeight.w900)),
              ),
            )),
      ),
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
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 550, maxHeight: 600),
            decoration: BoxDecoration(
                color: AppColors.paper,
                border: Border.all(color: AppColors.ink, width: 3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, offset: Offset(8, 8))
                ]),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wifi_tethering,
                              color: AppColors.ink, size: 24),
                          const SizedBox(width: 10),
                          Text('network_lobby'.tr,
                              style: const TextStyle(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  letterSpacing: 1.5)),
                        ],
                      ),
                      IconButton(
                          icon: const Icon(Icons.close, color: AppColors.ink),
                          onPressed: () {
                            mpCtrl.leaveLobby();
                            Get.back();
                          }),
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

  Widget _buildSetupUI(TextEditingController ipInput, String myName) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: AppColors.ink.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20)),
          child: Text("${'your_ip'.tr} ${mpCtrl.myIp.value}",
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink)),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.maps_home_work_outlined,
                      size: 40, color: AppColors.ink),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    onPressed: () => mpCtrl.startHost(myName),
                    child: Text('host_game_btn'.tr,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(height: 8),
                  Text('host_desc'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.ink.withOpacity(0.6),
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                    height: 120,
                    child:
                        VerticalDivider(color: AppColors.ink, thickness: 0.5))),
            Expanded(
              child: Column(
                children: [
                  if (mpCtrl.isScanning.value)
                    const SizedBox(
                        height: 40,
                        child: Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.ink)))
                  else
                    IconButton.filledTonal(
                        icon: const Icon(Icons.search,
                            size: 24, color: AppColors.ink),
                        onPressed: () => mpCtrl.scanForLobbies(),
                        style: IconButton.styleFrom(
                            backgroundColor: AppColors.ink.withOpacity(0.1))),
                  Text('quick_scan'.tr,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink)),
                  const SizedBox(height: 10),
                  if (mpCtrl.discoveredLobbies.isNotEmpty)
                    ...mpCtrl.discoveredLobbies
                        .map((lobby) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: InkWell(
                                onTap: () =>
                                    mpCtrl.joinBattle(lobby['ip']!, myName),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.orange[800]!,
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(6),
                                      color: Colors.orange.withOpacity(0.1)),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.bolt,
                                          color: Colors.orange, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text("${lobby['name']}",
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w900,
                                                  color: AppColors.ink),
                                              overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                ),
                              ),
                            ))
                        .toList()
                  else
                    Text('no_signals'.tr,
                        style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: AppColors.ink.withOpacity(0.5))),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(children: [
            const Expanded(
                child: Divider(color: AppColors.ink, thickness: 0.5)),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('join_via_ip'.tr,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink))),
            const Expanded(child: Divider(color: AppColors.ink, thickness: 0.5))
          ]),
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
                    color: AppColors.ink, fontWeight: FontWeight.bold),
                onSubmitted: (value) => mpCtrl.joinBattle(value, myName),
                decoration: InputDecoration(
                    hintText: "192.168.x.x",
                    hintStyle: TextStyle(
                        fontSize: 12, color: AppColors.ink.withOpacity(0.4)),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.ink),
                        borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: AppColors.ink, width: 2),
                        borderRadius: BorderRadius.circular(8))),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.ink, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: () => mpCtrl.joinBattle(ipInput.text, myName),
                child: Text('join_btn'.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, color: AppColors.ink)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveLobbyUI(String myName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3))),
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
                      fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text('assist_level'.tr,
                style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
            if (!mpCtrl.isHosting.value)
              const Text(" (HOST ONLY)",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 9,
                      fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _lobbyAssistBtn(AssistLevel.casual, 'ast_casual'.tr),
            const SizedBox(width: 4),
            _lobbyAssistBtn(AssistLevel.standard, 'ast_standard'.tr),
            const SizedBox(width: 4),
            _lobbyAssistBtn(AssistLevel.hardcore, 'ast_hardcore'.tr),
            const SizedBox(width: 4),
            _lobbyAssistBtn(AssistLevel.realLife, 'ast_reallife'.tr),
          ],
        ),
        const SizedBox(height: 10),

        // ✅ เพิ่มตัวเลือก Grid Size ในโหมด Network
        Row(
          children: [
            Text('grid_size'.tr,
                style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
            if (!mpCtrl.isHosting.value)
              const Text(" (HOST ONLY)",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 9,
                      fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _lobbySizeBtn(BoardSize.standard),
            const SizedBox(width: 4),
            _lobbySizeBtn(BoardSize.large),
            const SizedBox(width: 4),
            _lobbySizeBtn(BoardSize.huge),
          ],
        ),
        const SizedBox(height: 10),

        Container(
          constraints: const BoxConstraints(maxHeight: 120),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: mpCtrl.lobbyPlayers.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              var p = mpCtrl.lobbyPlayers[index];
              bool isMe = p['name'] == myName;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isMe
                            ? AppColors.ink
                            : AppColors.ink.withOpacity(0.2),
                        width: isMe ? 2 : 1)),
                child: Row(
                  children: [
                    Icon(p['isHost'] == true ? Icons.stars : Icons.person,
                        color: p['isHost'] == true
                            ? Colors.orange[800]
                            : AppColors.ink,
                        size: 20),
                    const SizedBox(width: 12),
                    Text(p['name'] ?? 'Unknown',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: AppColors.ink)),
                    const Spacer(),
                    if (isMe)
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppColors.ink,
                              borderRadius: BorderRadius.circular(4)),
                          child: Text('you_tag'.tr,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold))),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => mpCtrl.leaveLobby(),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.redPen, width: 2)),
                child: Text(
                    mpCtrl.isHosting.value ? 'abandon_btn'.tr : 'leave_btn'.tr,
                    style: const TextStyle(
                        color: AppColors.redPen, fontWeight: FontWeight.w900)),
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
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: mpCtrl.lobbyPlayers.length > 1
                      ? () => mpCtrl.broadcastStart()
                      : null,
                  label: Text('start_mission'.tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                ),
              )
            else
              Expanded(
                  flex: 2,
                  child: Column(children: [
                    const LinearProgressIndicator(
                        color: AppColors.ink, backgroundColor: Colors.black12),
                    const SizedBox(height: 5),
                    Text('waiting_commander'.tr,
                        style: const TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: AppColors.ink,
                            fontWeight: FontWeight.bold))
                  ])),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('mission_briefing'.tr,
            style: const TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2)),
        Row(
          children: [
            _buildActionBtn(
              onTap: _toggleLanguage,
              child: Text(Get.locale?.languageCode.toUpperCase() ?? 'EN',
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
            const SizedBox(width: 8),
            _buildActionBtn(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => isMuted = !isMuted);
              },
              child: Icon(isMuted ? Icons.volume_off : Icons.volume_up,
                  color: AppColors.ink, size: 18),
            ),
            const SizedBox(width: 8),
            _buildActionBtn(
              onTap: _showHowToPlay,
              child: const Icon(Icons.question_mark,
                  color: AppColors.ink, size: 18),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBtn({required VoidCallback onTap, required Widget child}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
                color: AppColors.ink.withOpacity(0.2),
                offset: const Offset(2, 2))
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildCommanderInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(4, 4))
        ],
      ),
      child: TextField(
        controller: _nameController,
        textAlign: TextAlign.center,
        maxLength: 12,
        style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 2),
        decoration: InputDecoration(
          counterText: "",
          labelText: 'commander_name'.tr,
          prefixIcon: const Icon(Icons.badge, color: AppColors.ink),
          labelStyle: TextStyle(
              color: AppColors.ink.withOpacity(0.6),
              letterSpacing: 1,
              fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSegmentBtn<T>(
      T value, String label, T groupValue, Function(T) onChanged,
      {Color color = AppColors.ink,
      bool isFirst = false,
      bool isLast = false}) {
    bool isSelected = value == groupValue;
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.horizontal(
            left: Radius.circular(isFirst ? 6 : 0),
            right: Radius.circular(isLast ? 6 : 0)),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onChanged(value);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.transparent,
              border: Border(
                top: BorderSide(color: color),
                bottom: BorderSide(color: color),
                left: BorderSide(color: color),
                right: BorderSide(color: color, width: isLast ? 1 : 0),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontSize: 10,
                        fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocalCampaignCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(4, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.smart_toy, color: AppColors.ink, size: 22),
              const SizedBox(width: 8),
              Text('local_campaign'.tr,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2)),
            ],
          ),
          const Divider(color: AppColors.ink, height: 24, thickness: 1.5),

          Text('difficulty'.tr,
              style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 12)),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildSegmentBtn(BotDifficulty.easy, 'diff_easy'.tr,
                  botDifficulty, (val) => setState(() => botDifficulty = val),
                  isFirst: true),
              _buildSegmentBtn(BotDifficulty.normal, 'diff_normal'.tr,
                  botDifficulty, (val) => setState(() => botDifficulty = val)),
              _buildSegmentBtn(BotDifficulty.hard, 'diff_hard'.tr,
                  botDifficulty, (val) => setState(() => botDifficulty = val),
                  isLast: true),
            ],
          ),
          const SizedBox(height: 16),

          Text('assist_level'.tr,
              style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 12)),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildSegmentBtn(AssistLevel.casual, 'ast_casual'.tr, assistLevel,
                  (val) => setState(() => assistLevel = val),
                  color: AppColors.redPen, isFirst: true),
              _buildSegmentBtn(AssistLevel.standard, 'ast_standard'.tr,
                  assistLevel, (val) => setState(() => assistLevel = val),
                  color: AppColors.redPen),
              _buildSegmentBtn(AssistLevel.hardcore, 'ast_hardcore'.tr,
                  assistLevel, (val) => setState(() => assistLevel = val),
                  color: AppColors.redPen),
              _buildSegmentBtn(AssistLevel.realLife, 'ast_reallife'.tr,
                  assistLevel, (val) => setState(() => assistLevel = val),
                  color: AppColors.redPen, isLast: true),
            ],
          ),
          const SizedBox(height: 16),

          // ✅ เพิ่ม Grid Size Row สำหรับโหมด Local
          Text('grid_size'.tr,
              style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 12)),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildSegmentBtn(BoardSize.standard, BoardSize.standard.label,
                  boardSize, (val) => setState(() => boardSize = val),
                  color: Colors.green[800]!, isFirst: true),
              _buildSegmentBtn(BoardSize.large, BoardSize.large.label,
                  boardSize, (val) => setState(() => boardSize = val),
                  color: Colors.green[800]!),
              _buildSegmentBtn(BoardSize.huge, BoardSize.huge.label, boardSize,
                  (val) => setState(() => boardSize = val),
                  color: Colors.green[800]!, isLast: true),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('enemies'.tr,
                      style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.ink),
                        borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 36, minHeight: 36),
                            icon: const Icon(Icons.remove,
                                color: AppColors.ink, size: 18),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                if (enemyCount > 1) enemyCount--;
                              });
                            }),
                        Text("$enemyCount",
                            style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 18,
                                fontWeight: FontWeight.w900)),
                        IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 36, minHeight: 36),
                            icon: const Icon(Icons.add,
                                color: AppColors.ink, size: 18),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                if (enemyCount < 7) enemyCount++;
                              });
                            }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Get.find<GameController>().botDifficulty = botDifficulty;
                    Get.find<GameController>().assistLevel = assistLevel;
                    Get.toNamed('/placement', arguments: {
                      'enemyCount': enemyCount,
                      'playerName': _nameController.text.trim().isEmpty
                          ? "COMMANDER"
                          : _nameController.text.trim().toUpperCase(),
                      'columns': boardSize.cols, // ✅ ส่งคอลัมน์
                      'rows': boardSize.rows, // ✅ ส่งแถว
                    });
                  },
                  icon: const Icon(Icons.rocket_launch, color: AppColors.paper),
                  label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('engage_bots'.tr,
                          style: const TextStyle(
                              color: AppColors.paper,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2))),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
            color: AppColors.ink.withOpacity(0.4),
            width: 2,
            style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.satellite_alt, color: AppColors.ink, size: 20),
              const SizedBox(width: 8),
              Text('network_battle'.tr,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _showMultiplayerLAN,
            icon: const Icon(Icons.cell_tower, color: AppColors.ink),
            label: Text('host_join'.tr,
                style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.ink, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ],
      ),
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
                              offset: Offset(0, 8 * sin(value)),
                              child: Transform.rotate(
                                  angle: -0.1 + (0.05 * cos(value)),
                                  child: const Icon(
                                      Icons.directions_boat_outlined,
                                      size: 100,
                                      color: AppColors.ink)),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.elasticOut,
                          builder: (context, val, child) => Transform.scale(
                            scale: val,
                            child: const Text('PAPER\nBATTLESHIP',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.ink,
                                    letterSpacing: 4,
                                    decoration: TextDecoration.underline,
                                    decorationStyle: TextDecorationStyle.wavy,
                                    height: 1.2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      width: 2,
                      height: double.infinity,
                      color: AppColors.ink.withOpacity(0.2),
                      margin: const EdgeInsets.symmetric(vertical: 40)),
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildHeaderActions(),
                              const SizedBox(height: 24),
                              _buildCommanderInput(),
                              const SizedBox(height: 24),
                              _buildLocalCampaignCard(),
                              const SizedBox(height: 16),
                              _buildNetworkCard(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 12,
                left: 20,
                child: Text("v1.0.0 - Commander Edition",
                    style: TextStyle(
                        color: AppColors.ink.withOpacity(0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

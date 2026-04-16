import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../state/sound_controller.dart';
import '../../state/game_controller.dart';
import '../../state/multiplayer_controller.dart';
import '../../screens/main_menu.dart'; // นำเข้าเพื่อเรียกใช้ BoardSize และ CustomSegmentedControl
import 'real_life_warning_dialog.dart';

class MultiplayerDialog extends StatefulWidget {
  final String playerName;

  const MultiplayerDialog({super.key, required this.playerName});

  @override
  State<MultiplayerDialog> createState() => _MultiplayerDialogState();
}

class _MultiplayerDialogState extends State<MultiplayerDialog> {
  late final TextEditingController _ipInput;
  final MultiplayerController mpCtrl = Get.find<MultiplayerController>();
  final SoundController _sound = Get.find<SoundController>();

  // สถานะเก็บขนาดกระดานในหน้า Dialog
  BoardSize _boardSize = BoardSize.standard;

  @override
  void initState() {
    super.initState();
    _ipInput = TextEditingController();
  }

  @override
  void dispose() {
    _ipInput.dispose();
    super.dispose();
  }

  void _checkRealLifeMode(AssistLevel level, VoidCallback onProceed) {
    if (level == AssistLevel.realLife) {
      _sound.vibrateHeavy();
      _sound.playError();
      Get.dialog(RealLifeWarningDialog(onProceed: onProceed),
          barrierDismissible: false);
    } else {
      onProceed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(
                maxWidth: 550, maxHeight: 750), // ขยาย maxHeight รับ Settings
            decoration: BoxDecoration(
                color: AppColors.paper,
                border: Border.all(color: AppColors.ink, width: 3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: AppColors.ink, offset: Offset(6, 6))
                ]),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wifi_tethering,
                              color: AppColors.ink, size: 28),
                          const SizedBox(width: 10),
                          Text('network_lobby'.tr,
                              style: const TextStyle(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  letterSpacing: 1.5)),
                        ],
                      ),
                      IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColors.ink, size: 28),
                          onPressed: () {
                            _sound.playClick();
                            mpCtrl.leaveLobby();
                            Get.back();
                          }),
                    ],
                  ),
                  const Divider(color: AppColors.ink, thickness: 2, height: 25),
                  if (!mpCtrl.isConnected.value && !mpCtrl.isHosting.value)
                    _buildSetupUI()
                  else
                    _buildActiveLobbyUI(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildSetupUI() {
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
                        elevation: 0,
                        backgroundColor: AppColors.ink,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    onPressed: () {
                      _sound.playClick();
                      mpCtrl.startHost(widget.playerName);
                    },
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
                        onPressed: () {
                          _sound.playClick();
                          mpCtrl.scanForLobbies();
                        },
                        style: IconButton.styleFrom(
                            backgroundColor: AppColors.ink.withOpacity(0.1))),
                  Text('quick_scan'.tr,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink)),
                  const SizedBox(height: 10),
                  if (mpCtrl.discoveredLobbies.isNotEmpty)
                    ...mpCtrl.discoveredLobbies.map((lobby) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: InkWell(
                            onTap: () {
                              _sound.playClick();
                              mpCtrl.joinBattle(
                                  lobby['ip']!, widget.playerName);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.orange[800]!, width: 1.5),
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
                controller: _ipInput,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    color: AppColors.ink, fontWeight: FontWeight.bold),
                onSubmitted: (value) {
                  _sound.playClick();
                  mpCtrl.joinBattle(value, widget.playerName);
                },
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
                onPressed: () {
                  _sound.playClick();
                  mpCtrl.joinBattle(_ipInput.text, widget.playerName);
                },
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

  Widget _buildActiveLobbyUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. Connection Status ---
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
        const SizedBox(height: 15),

        // --- 2. Game Settings (Host Only) ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.ink, width: 2.5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.settings, color: AppColors.ink, size: 20),
                  const SizedBox(width: 8),
                  Text('mission_briefing'.tr,
                      style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                ],
              ),
              const Divider(color: AppColors.ink, thickness: 1.5, height: 24),
              _buildConfigRow(
                'assist_level'.tr,
                IgnorePointer(
                  ignoring: !mpCtrl.isHosting.value, // ล็อคปุ่มถ้าไม่ใช่ Host
                  child: Opacity(
                    opacity: mpCtrl.isHosting.value ? 1.0 : 0.5,
                    child: CustomSegmentedControl<AssistLevel>(
                      selectedValue: mpCtrl.currentAssistLevel.value,
                      activeColor: AppColors.redPen,
                      items: {
                        AssistLevel.casual: 'ast_casual'.tr,
                        AssistLevel.standard: 'ast_standard'.tr,
                        AssistLevel.hardcore: 'ast_hardcore'.tr,
                        AssistLevel.realLife: 'ast_reallife'.tr,
                      },
                      onChanged: (val) {
                        mpCtrl.currentAssistLevel.value = val;
                        // ระบบ MultiplayerController ควรส่งค่าใหม่นี้ไปให้ Client ด้วย
                      },
                    ),
                  ),
                ),
              ),
              _buildConfigRow(
                'grid_size'.tr,
                IgnorePointer(
                  ignoring: !mpCtrl.isHosting.value, // ล็อคปุ่มถ้าไม่ใช่ Host
                  child: Opacity(
                    opacity: mpCtrl.isHosting.value ? 1.0 : 0.5,
                    child: CustomSegmentedControl<BoardSize>(
                      selectedValue: _boardSize, // ใช้ตัวแปร Local ในหน้านี้
                      activeColor: Colors.green[800]!,
                      items: {
                        BoardSize.standard: BoardSize.standard.label,
                        BoardSize.large: BoardSize.large.label,
                        BoardSize.huge: BoardSize.huge.label,
                      },
                      onChanged: (val) {
                        setState(() => _boardSize = val);
                        // หมายเหตุ: หาก Controller ของคุณมีการเก็บ boardSize ด้วย
                        // สามารถเรียก mpCtrl.currentBoardSize.value = val; ได้ที่นี่เลย
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // --- 3. Players List ---
        Container(
          constraints: const BoxConstraints(maxHeight: 150),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: mpCtrl.lobbyPlayers.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              var p = mpCtrl.lobbyPlayers[index];
              bool isMe = p['name'] == widget.playerName;
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

        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _sound.playClick();
                  mpCtrl.leaveLobby();
                },
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
                      elevation: 0,
                      backgroundColor: mpCtrl.lobbyPlayers.length > 1
                          ? Colors.green[700]
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: mpCtrl.lobbyPlayers.length > 1
                      ? () {
                          _checkRealLifeMode(mpCtrl.currentAssistLevel.value,
                              () {
                            _sound.playClick();

                            // ส่งข้อมูล Grid Size ที่เลือกล่าสุดไปให้ Controller ประมวลผลตอนเริ่มเกม
                            // หมายเหตุ: โค้ดเดิมคือ mpCtrl.broadcastStart() คุณอาจต้องแก้ไขฟังก์ชัน
                            // ใน Controller ให้รองรับการรับค่า cols, rows ด้วย (ถ้ายังไม่มี)
                            mpCtrl.broadcastStart();
                          });
                        }
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

  // --- Helper Widget สำหรับหัวข้อการตั้งค่า ---
  Widget _buildConfigRow(String title, Widget control) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.2)),
        const SizedBox(height: 8),
        control,
        const SizedBox(height: 16),
      ],
    );
  }
}

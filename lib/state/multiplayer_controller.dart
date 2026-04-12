import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'game_controller.dart' show AssistLevel, GameController;

class MultiplayerController extends GetxController {
  ServerSocket? _server;
  RawDatagramSocket? _udpSocket;
  final List<Socket> _clientSockets = [];

  final info = NetworkInfo();
  var myIp = "".obs;
  var isHosting = false.obs;
  var isConnected = false.obs;
  var isScanning = false.obs;

  var discoveredLobbies = <Map<String, String>>[].obs;
  var lobbyPlayers = <Map<String, dynamic>>[].obs;
  String currentMyName = "";

  var currentAssistLevel = AssistLevel.standard.obs;

  var currentColumns = 8.obs;
  var currentRows = 6.obs;

  @override
  void onInit() {
    super.onInit();
    _getIp();
  }

  Future<void> _getIp() async {
    myIp.value = await info.getWifiIP() ?? "127.0.0.1";
  }

  Future<void> startHost(String myName) async {
    currentMyName = myName;
    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, 4545);
      isHosting.value = true;
      lobbyPlayers.assignAll([
        {'name': myName, 'ip': myIp.value, 'isHost': true}
      ]);

      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4546);
      _udpSocket!.broadcastEnabled = true;

      _server!.listen((Socket client) {
        _clientSockets.add(client);
        _setupSocketListener(client);
      });

      _broadcastPresence(myName);
    } catch (e) {
      Get.snackbar("Error", "Lobby failed: $e");
    }
  }

  void _broadcastPresence(String name) async {
    while (isHosting.value) {
      String msg = "BATTLESHIP_LOBBY|$name|${myIp.value}";
      _udpSocket?.send(
          utf8.encode(msg), InternetAddress("255.255.255.255"), 4546);
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> scanForLobbies() async {
    HapticFeedback.mediumImpact();
    isScanning.value = true;
    discoveredLobbies.clear();
    try {
      RawDatagramSocket scanner =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4546);
      scanner.listen((RawSocketEvent event) {
        Datagram? dg = scanner.receive();
        if (dg != null) {
          String msg = utf8.decode(dg.data);
          if (msg.startsWith("BATTLESHIP_LOBBY")) {
            var parts = msg.split("|");
            if (!discoveredLobbies.any((l) => l['ip'] == parts[2])) {
              discoveredLobbies.add({'name': parts[1], 'ip': parts[2]});
            }
          }
        }
      });
      await Future.delayed(const Duration(seconds: 5));
      scanner.close();
      isScanning.value = false;
    } catch (e) {
      isScanning.value = false;
    }
  }

  Future<void> joinBattle(String hostIp, String myName) async {
    currentMyName = myName;
    try {
      Socket socket = await Socket.connect(hostIp, 4545,
          timeout: const Duration(seconds: 5));
      _clientSockets.add(socket);
      isConnected.value = true;
      _sendToSocket(socket, {'type': 'JOIN_REQUEST', 'name': myName});
      _setupSocketListener(socket);
    } catch (e) {
      Get.snackbar("Connection Failed", "Cannot find Host at $hostIp");
    }
  }

  void _setupSocketListener(Socket socket) {
    socket.listen((data) {
      String message = utf8.decode(data);
      _handleIncomingMessage(message, socket);
    }, onDone: () {
      _clientSockets.remove(socket);
      if (!isHosting.value) {
        isConnected.value = false;
        Get.snackbar("Disconnected", "Lost connection to Host");
      }
    });
  }

  void updateAssistLevel(AssistLevel level) {
    currentAssistLevel.value = level;
    broadcastMessage({
      'type': 'LOBBY_UPDATE',
      'players': lobbyPlayers.toList(),
      'assistLevel': level.index
    });
  }

  // ✅ เปลี่ยนกฎใน Lobby (เรียกใช้โดย Host)
  void updateLobbySettings(AssistLevel level, int cols, int rows) {
    currentAssistLevel.value = level;
    currentColumns.value = cols;
    currentRows.value = rows;
    broadcastMessage({
      'type': 'LOBBY_UPDATE',
      'players': lobbyPlayers.toList(),
      'assistLevel': level.index,
      'columns': cols,
      'rows': rows
    });
  }

  void _handleIncomingMessage(String raw, Socket sender) {
    try {
      var data = jsonDecode(raw);
      if (data['type'] == 'JOIN_REQUEST' && isHosting.value) {
        lobbyPlayers.add({
          'name': data['name'],
          'ip': sender.remoteAddress.address,
          'isHost': false
        });
        broadcastMessage({
          'type': 'LOBBY_UPDATE',
          'players': lobbyPlayers.toList(),
          'assistLevel': currentAssistLevel.value.index,
          'columns': currentColumns.value,
          'rows': currentRows.value
        });
      }
      if (data['type'] == 'LOBBY_UPDATE') {
        lobbyPlayers
            .assignAll(List<Map<String, dynamic>>.from(data['players']));
        if (data['assistLevel'] != null)
          currentAssistLevel.value = AssistLevel.values[data['assistLevel']];
        if (data['columns'] != null) currentColumns.value = data['columns'];
        if (data['rows'] != null) currentRows.value = data['rows'];
      }
      if (data['type'] == 'START_GAME') {
        Get.find<GameController>().assistLevel =
            AssistLevel.values[data['assistLevel']];
        Get.toNamed('/placement', arguments: {
          'mode': 'LAN', 'playerName': currentMyName, 'isHost': isHosting.value,
          'opponents':
              lobbyPlayers.where((p) => p['name'] != currentMyName).toList(),
          'columns': currentColumns.value,
          'rows': currentRows.value // ✅ ส่งขนาดตารางไปหน้าจัดวาง
        });
      }
    } catch (e) {
      print("Error parsing socket: $e");
    }
  }

  void broadcastStart() {
    if (isHosting.value) {
      broadcastMessage({
        'type': 'START_GAME',
        'assistLevel': currentAssistLevel.value.index
      });
    }
  }

  void broadcastMessage(Map<String, dynamic> json) {
    String raw = jsonEncode(json);
    for (var s in _clientSockets) {
      s.write(raw);
    }
  }

  void _sendToSocket(Socket s, Map<String, dynamic> json) {
    s.write(jsonEncode(json));
  }

  void leaveLobby() {
    HapticFeedback.mediumImpact();
    for (var s in _clientSockets) {
      s.destroy();
    }
    _clientSockets.clear();
    if (_server != null) {
      _server!.close();
      _server = null;
    }
    _udpSocket?.close();
    isHosting.value = false;
    isConnected.value = false;
    lobbyPlayers.clear();
    _getIp();
  }

  @override
  void onClose() {
    leaveLobby();
    super.onClose();
  }
}

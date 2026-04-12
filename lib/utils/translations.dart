import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        // ==========================================
        // 🇺🇸 ENGLISH (en_US)
        // ==========================================
        'en_US': {
          // --- COMMON ---
          'attention': 'ATTENTION!',
          'roger_that': 'ROGER THAT',
          'stay': 'STAY',
          'retreat': 'RETREAT',
          'size': 'SIZE:',
          'horz': 'HORZ',
          'vert': 'VERT',

          // --- MAIN MENU ---
          'mission_briefing': 'MISSION BRIEFING',
          'commander_name': 'COMMANDER CALLSIGN',
          'local_campaign': 'LOCAL CAMPAIGN (VS BOTS)',
          'enemies': 'ENEMIES:',
          'bot_speed': 'BOT SPEED',
          'speed_slow': 'SLOW',
          'speed_normal': 'NORMAL',
          'speed_fast': 'FAST',
          'difficulty': 'BOT DIFFICULTY',
          'diff_easy': 'EASY',
          'diff_normal': 'NORMAL',
          'diff_hard': 'HARD',
          'assist_level': 'ASSIST LEVEL',
          'ast_casual': 'CASUAL',
          'ast_standard': 'STANDARD',
          'ast_hardcore': 'HARDCORE',
          'ast_reallife': 'REAL LIFE',
          'grid_size': 'GRID SIZE',
          'engage_bots': 'ENGAGE BOTS',

          // --- MULTIPLAYER LOBBY ---
          'network_battle': 'NETWORK BATTLE (PvP)',
          'host_join': 'HOST / JOIN BATTLE',
          'coming_soon': 'Multiplayer module is currently under construction.',
          'network_lobby': 'NETWORK LOBBY',
          'your_ip': 'YOUR IP:',
          'host_game_btn': 'HOST GAME',
          'host_desc': 'Start a new session\nand invite allies',
          'quick_scan': 'QUICK SCAN',
          'no_signals': 'No active signals...',
          'join_via_ip': 'OR JOIN VIA IP',
          'join_btn': 'JOIN',
          'room_open': 'ROOM OPEN AT: @ip',
          'connected_station': 'CONNECTED TO BATTLESTATION',
          'you_tag': 'YOU',
          'abandon_btn': 'ABORT',
          'leave_btn': 'LEAVE',
          'start_mission': 'START MISSION',
          'waiting_commander': 'WAITING FOR COMMANDER...',

          // --- HOW TO PLAY (HELP) ---
          'how_to_play': 'HOW TO PLAY',
          'deployment_phase': 'DEPLOYMENT PHASE:',
          'help_step_1': 'Draw 12 Land blocks (Max 2 islands)',
          'help_step_2': 'Deploy 3 Turrets on Land',
          'help_step_3': 'Deploy 5 Ships on Water',
          'ammo_legend_title': 'AMMO LEGEND:',
          'ammo_legend_desc':
              ' 🟦 Base Fleet Ammo\n 🟧 Land Hit Bonus\n 🩵 Locked Target',
          'combat_rules': 'COMBAT RULES:',
          'rule_1': '💥 Ammo = 1 + Active Turrets + Land Bonus',
          'rule_2':
              '🎯 Salvo Fire: Lock multiple targets with your available ammo, then FIRE ALL!',
          'rule_3':
              '⚖️ Rule: You must distribute your shots evenly across all alive enemies.',
          'help_diff_title': 'BOT DIFFICULTY:',
          'help_diff_easy':
              '🟢 EASY: Shoots randomly. May waste ammo on revealed spots.',
          'help_diff_normal':
              '🟡 NORMAL: Shoots randomly but avoids revealed sectors.',
          'help_diff_hard':
              '🔴 HARD: The Hunter! Focuses fire around hit targets to sink ships fast.',
          'help_assist_title': 'ASSIST LEVELS:',
          'help_ast_casual':
              '🟢 CASUAL: Shows everything. Prevents shooting revealed sectors. Full logs.',
          'help_ast_standard':
              '🟡 STANDARD: Misses fade. Wastes ammo on revealed sectors. Full logs.',
          'help_ast_hardcore':
              '🔴 HARDCORE: Land & Misses hidden. Logs hide ship/turret details.',
          'help_ast_reallife':
              '⚫ REAL LIFE: Blind mode! No marks remain. (LONG PRESS to draw manual markers). Minimal logs.',

          // --- PLACEMENT PHASE ---
          'tools': 'TOOLS',
          'land': 'LAND',
          'turret': 'TURRET',
          'fleet': 'FLEET',
          'command': 'COMMAND',
          'auto': 'AUTO',
          'clear': 'CLEAR',
          'engage': 'ENGAGE',
          'req_land': 'Need @count more land blocks',
          'req_turret': 'Need @count more turrets',
          'req_ship': 'Deploy all ships to proceed',
          'req_island': 'Land too scattered! (Max 2 islands)',
          'all_ready': 'ALL SYSTEMS READY!',

          // --- GAME BOARD ---
          'targets': 'TARGETS',
          'global_radar': 'GLOBAL RADAR',
          'radar_desc': 'Only successful hits and allied fleets are tracked',
          'close_radar': 'CLOSE RADAR',
          'my_fleet': 'MY FLEET',
          'me': 'ME',
          'defending': 'DEFENDING: MY SECTOR',
          'targeting': 'TARGETING: @name',
          'ammo_ready': 'AMMO: ',
          'ammo_legend': '🟦 FLEET   🟧 BONUS   🩵 LOCKED',
          'targets_locked': 'TARGETS LOCKED',
          'fire_all': 'FIRE ALL!',
          'turn_announce': "@name's TURN",
          'hint_reallife':
              '💡 HINT: Long-press a sector to manually mark X or O.',
          'simulating': 'SIMULATING ENEMY PLACEMENT...',
          'distribute_shots': 'You must distribute shots evenly!',
          'abort_title': 'ABORT MISSION?',
          'abort_desc':
              'Are you sure you want to retreat to the main menu? All progress will be lost.',
          'war_over': 'WAR IS OVER',
          'wins': '@name WINS!',
          'return_base': 'RETURN TO BASE',

          // --- BATTLE LOGS ---
          'battle_log': 'BATTLE LOG',
          'casual_block':
              'Sector already revealed! (Casual Mode prevents wasted ammo)',
          'wasted_shot':
              '⚠️ Wasted shot! You fired at an already revealed sector.',
          'wasted_shot_bot': '🤣 @shooter wasted a shot on a known sector!',
          'log_sunk_me': '🎉 You completely sank @target\'s ship! (Size @size)',
          'log_sunk_enemy': '💥 @shooter sank @target\'s ship!',
          'log_sunk_you': '🚨 MAYDAY! @shooter sank your ship!',
          'log_hit_me': '🎯 Direct hit on @target\'s ship!',
          'log_hit_enemy': '🎯 @shooter hit @target\'s ship!',
          'log_hit_you': '⚠️ Warning! @shooter hit your ship!',
          'log_turret_me': '🛡️ You destroyed @target\'s turret!',
          'log_turret_enemy': '🛡️ @shooter destroyed @target\'s turret!',
          'log_turret_you': '🧨 Watch out! @shooter destroyed your turret!',
          'log_hardcore_hit': '🎯 Target Hit! (@target)',
          'log_hardcore_miss': '💦 Target Missed! (@target)',
          'log_reallife_hit': '🎯 Hit at Sector @coord (@target)',
          'log_reallife_miss': '💦 Miss at Sector @coord (@target)',
        },

        // ==========================================
        // 🇹🇭 THAI (th_TH)
        // ==========================================
        'th_TH': {
          // --- COMMON ---
          'attention': 'ข้อควรระวัง!',
          'roger_that': 'รับทราบ!',
          'stay': 'สู้ต่อ',
          'retreat': 'ถอยทัพ',
          'size': 'ขนาด:',
          'horz': 'แนวนอน',
          'vert': 'แนวตั้ง',

          // --- MAIN MENU ---
          'mission_briefing': 'รายละเอียดภารกิจ',
          'commander_name': 'ชื่อผู้บัญชาการ',
          'local_campaign': 'รบออฟไลน์ (ปะทะ AI)',
          'enemies': 'จำนวนศัตรู:',
          'bot_speed': 'ความเร็ว AI',
          'speed_slow': 'ช้า',
          'speed_normal': 'ปกติ',
          'speed_fast': 'เร็ว',
          'difficulty': 'ระดับความยาก',
          'diff_easy': 'ง่าย',
          'diff_normal': 'ปานกลาง',
          'diff_hard': 'ยาก',
          'assist_level': 'ระดับการช่วยเหลือ',
          'ast_casual': 'แคชชวล',
          'ast_standard': 'มาตรฐาน',
          'ast_hardcore': 'ฮาร์ดคอร์',
          'ast_reallife': 'มืดบอด',
          'grid_size': 'ขนาดพื้นที่รบ',
          'engage_bots': 'เริ่มประจัญบาน',

          // --- MULTIPLAYER LOBBY ---
          'network_battle': 'รบออนไลน์ (PvP)',
          'host_join': 'สร้าง / เข้าร่วมห้อง',
          'coming_soon': 'ระบบออนไลน์กำลังอยู่ในช่วงพัฒนา',
          'network_lobby': 'ห้องรอรบออนไลน์',
          'your_ip': 'ไอพีของคุณ:',
          'host_game_btn': 'สร้างห้องรบ',
          'host_desc': 'เปิดฐานทัพใหม่\nและรอเพื่อนเข้าร่วม',
          'quick_scan': 'สแกนหาห้อง',
          'no_signals': 'ไม่พบสัญญาณตอบรับ...',
          'join_via_ip': 'หรือเข้าร่วมด้วยไอพี',
          'join_btn': 'เข้ากลุ่ม',
          'room_open': 'เปิดห้องที่: @ip',
          'connected_station': 'เชื่อมต่อสถานีรบสำเร็จ',
          'you_tag': 'เรา',
          'abandon_btn': 'ยกเลิก',
          'leave_btn': 'ออก',
          'start_mission': 'เริ่มภารกิจ',
          'waiting_commander': 'กำลังรอผู้บัญชาการสั่งการ...',

          // --- HOW TO PLAY (HELP) ---
          'how_to_play': 'คู่มือการรบ',
          'deployment_phase': 'ขั้นตอนการวางกำลัง:',
          'help_step_1': 'วาดแผ่นดิน 12 บล็อก (สูงสุด 2 เกาะ)',
          'help_step_2': 'สร้างป้อมปืน 3 ป้อมบนแผ่นดิน',
          'help_step_3': 'จัดวางกองเรือ 5 ลำบนผืนน้ำ',
          'ammo_legend_title': 'สัญลักษณ์กระสุน:',
          'ammo_legend_desc':
              ' 🟦 กระสุนกองเรือหลัก\n 🟧 โบนัสยิงแผ่นดิน\n 🩵 ล็อกเป้าหมายแล้ว',
          'combat_rules': 'กฎการปะทะ:',
          'rule_1': '💥 กระสุน = 1 + ป้อมปืนที่เหลือ + โบนัส',
          'rule_2':
              '🎯 ยิงรัว (Salvo): ล็อกหลายเป้าหมายตามกระสุนที่มี แล้วกดยิงรวดเดียว!',
          'rule_3':
              '⚖️ กฎเหล็ก: คุณต้องกระจายการยิงให้ศัตรูที่รอดชีวิตอย่างเท่าเทียมกัน',
          'help_diff_title': 'ระดับความยากของ AI:',
          'help_diff_easy':
              '🟢 ง่าย: สุ่มยิงมั่ว 100% (อาจยิงเสียกระสุนฟรีในจุดเดิม)',
          'help_diff_normal':
              '🟡 ปานกลาง: สุ่มยิงแบบฉลาด หลีกเลี่ยงพิกัดที่เคยยิงไปแล้ว',
          'help_diff_hard':
              '🔴 ยาก: นักล่า! เมื่อยิงโดนเรือจะสาดกระสุนรอบๆ เพื่อจมเรือทันที',
          'help_assist_title': 'ระดับการช่วยเหลือ:',
          'help_ast_casual':
              '🟢 แคชชวล: กระดานจำรอยโดนและพลาด ห้ามยิงพิกัดซ้ำ ประวัติบอกครบถ้วน',
          'help_ast_standard':
              '🟡 มาตรฐาน: กระดานจำเฉพาะรอยโดน ยิงซ้ำพิกัดเดิมเสียกระสุน ประวัติบอกครบถ้วน',
          'help_ast_hardcore':
              '🔴 ฮาร์ดคอร์: ซ่อนแผ่นดินศัตรู ประวัติไม่บอกว่าจมเรือหรือพังป้อม',
          'help_ast_reallife':
              '⚫ มืดบอด: ซ่อนทุกอย่าง! (กดค้างที่ตารางเพื่อเขียน X, O บันทึกเอง) ประวัติบอกแค่พิกัด',

          // --- PLACEMENT PHASE ---
          'tools': 'เครื่องมือ',
          'land': 'แผ่นดิน',
          'turret': 'ป้อมปืน',
          'fleet': 'กองเรือ',
          'command': 'คำสั่ง',
          'auto': 'สุ่มวาง',
          'clear': 'ล้างกระดาน',
          'engage': 'ยืนยัน',
          'req_land': 'ขาดแผ่นดินอีก @count บล็อก',
          'req_turret': 'ขาดป้อมปืนอีก @count อัน',
          'req_ship': 'ต้องจัดวางเรือให้ครบทุกลำ',
          'req_island': 'แผ่นดินกระจายเกินไป! (สูงสุด 2 เกาะ)',
          'all_ready': 'ระบบพร้อมรบ!',

          // --- GAME BOARD ---
          'targets': 'เป้าหมาย',
          'global_radar': 'เรดาร์รวม',
          'radar_desc': 'แสดงเฉพาะพิกัดที่ยิงโดนเป้าหมายและกองเรือฝั่งเรา',
          'close_radar': 'ปิดเรดาร์',
          'my_fleet': 'กองเรือเรา',
          'me': 'เรา',
          'defending': 'ป้องกัน: น่านน้ำของเรา',
          'targeting': 'ล็อกเป้า: @name',
          'ammo_ready': 'กระสุน: ',
          'ammo_legend': '🟦 กองเรือ   🟧 โบนัส   🩵 ล็อกเป้า',
          'targets_locked': 'ล็อกเป้าหมายแล้ว',
          'fire_all': 'ยิงทั้งหมด!',
          'turn_announce': "เทิร์นของ @name",
          'hint_reallife':
              '💡 คำแนะนำ: กดค้างที่ตารางเพื่อบันทึกเครื่องหมาย X หรือ O เอง',
          'simulating': 'กำลังจำลองการวางกำลังศัตรู...',
          'distribute_shots': 'คุณต้องกระจายการยิงให้เท่าๆ กัน!',
          'abort_title': 'ยกเลิกภารกิจ?',
          'abort_desc':
              'คุณแน่ใจหรือไม่ว่าจะถอยทัพกลับสู่เมนูหลัก? ความคืบหน้าทั้งหมดจะสูญหาย',
          'war_over': 'สงครามจบลงแล้ว',
          'wins': '@name เป็นผู้ชนะ!',
          'return_base': 'กลับฐานทัพ',

          // --- BATTLE LOGS ---
          'battle_log': 'บันทึกการรบ',
          'casual_block':
              'พิกัดนี้ถูกเปิดไปแล้ว! (โหมดแคชชวลป้องกันการเสียกระสุน)',
          'wasted_shot': '⚠️ เสียกระสุนฟรี! ยิงซ้ำพิกัดที่เปิดไปแล้ว',
          'wasted_shot_bot': '🤣 @shooter ยิงเสียของไปโดนจุดที่เปิดแล้ว!',
          'log_sunk_me': '🎉 คุณจมเรือของ @target สำเร็จ! (ขนาด @size)',
          'log_sunk_enemy': '💥 @shooter จมเรือของ @target!',
          'log_sunk_you': '🚨 แย่แล้ว! @shooter จมเรือของคุณ!',
          'log_hit_me': '🎯 ยิงโดนเรือของ @target เต็มๆ!',
          'log_hit_enemy': '🎯 @shooter ยิงโดนเรือของ @target!',
          'log_hit_you': '⚠️ คำเตือน! @shooter ยิงโดนเรือคุณ!',
          'log_turret_me': '🛡️ คุณทำลายป้อมปืนของ @target!',
          'log_turret_enemy': '🛡️ @shooter ทำลายป้อมปืนของ @target!',
          'log_turret_you': '🧨 ระวัง! @shooter ทำลายป้อมปืนของคุณ!',
          'log_hardcore_hit': '🎯 ยิงโดนเป้าหมาย! (@target)',
          'log_hardcore_miss': '💦 ยิงพลาดเป้า! (@target)',
          'log_reallife_hit': '🎯 ยิงโดนเป้าหมายที่พิกัด @coord (@target)',
          'log_reallife_miss': '💦 ยิงพลาดเป้าที่พิกัด @coord (@target)',
        },

        // ==========================================
        // 🇪🇸 SPANISH (es_ES) - ADDED
        // ==========================================
        'es_ES': {
          // --- COMMON ---
          'attention': '¡ATENCIÓN!',
          'roger_that': 'RECIBIDO',
          'stay': 'QUEDARSE',
          'retreat': 'RETIRADA',
          'size': 'TAMAÑO:',
          'horz': 'HORZ',
          'vert': 'VERT',

          // --- MAIN MENU ---
          'mission_briefing': 'REPORTE DE MISIÓN',
          'commander_name': 'IDENTIFICADOR',
          'local_campaign': 'CAMPAÑA LOCAL (VS BOTS)',
          'enemies': 'ENEMIGOS:',
          'bot_speed': 'VELOCIDAD AI',
          'speed_slow': 'LENTO',
          'speed_normal': 'NORMAL',
          'speed_fast': 'RÁPIDO',
          'difficulty': 'DIFICULTAD',
          'diff_easy': 'FÁCIL',
          'diff_normal': 'NORMAL',
          'diff_hard': 'DIFÍCIL',
          'assist_level': 'ASISTENCIA',
          'ast_casual': 'CASUAL',
          'ast_standard': 'ESTÁNDAR',
          'ast_hardcore': 'EXTREMO',
          'ast_reallife': 'VIDA REAL',
          'grid_size': 'TAMAÑO DE LA CUADRÍCULA',
          'engage_bots': 'ATACAR BOTS',

          // --- MULTIPLAYER LOBBY ---
          'network_battle': 'BATALLA EN RED (PvP)',
          'host_join': 'CREAR / UNIRSE',
          'coming_soon': 'El módulo multijugador está en construcción.',
          'network_lobby': 'LOBBY DE RED',
          'your_ip': 'TU IP:',
          'host_game_btn': 'CREAR PARTIDA',
          'host_desc': 'Inicia una nueva sesión\ne invita aliados',
          'quick_scan': 'ESCANEO RÁPIDO',
          'no_signals': 'Sin señales activas...',
          'join_via_ip': 'O UNIRSE POR IP',
          'join_btn': 'UNIRSE',
          'room_open': 'SALA ABIERTA EN: @ip',
          'connected_station': 'CONECTADO A LA ESTACIÓN',
          'you_tag': 'TÚ',
          'abandon_btn': 'ABORTAR',
          'leave_btn': 'SALIR',
          'start_mission': 'INICIAR MISIÓN',
          'waiting_commander': 'ESPERANDO AL COMANDANTE...',

          // --- HOW TO PLAY (HELP) ---
          'how_to_play': 'CÓMO JUGAR',
          'deployment_phase': 'FASE DE DESPLIEGUE:',
          'help_step_1': 'Dibuja 12 bloques de Tierra (Máx 2 islas)',
          'help_step_2': 'Despliega 3 Torretas en Tierra',
          'help_step_3': 'Despliega 5 Barcos en Agua',
          'ammo_legend_title': 'LEYENDA DE MUNICIÓN:',
          'ammo_legend_desc':
              ' 🟦 Munición Base\n 🟧 Bono por Tierra\n 🩵 Objetivo Fijado',
          'combat_rules': 'REGLAS DE COMBATE:',
          'rule_1': '💥 Munición = 1 + Torretas Activas + Bono',
          'rule_2': '🎯 Salva: ¡Fija objetivos, luego DISPARA TODO!',
          'rule_3': '⚖️ Regla: Distribuye tus disparos equitativamente.',
          'help_diff_title': 'DIFICULTAD DEL BOT:',
          'help_diff_easy':
              '🟢 FÁCIL: Dispara al azar. Puede desperdiciar munición.',
          'help_diff_normal':
              '🟡 NORMAL: Dispara al azar pero evita sectores revelados.',
          'help_diff_hard':
              '🔴 DIFÍCIL: ¡El Cazador! Enfoca el fuego alrededor del objetivo.',
          'help_assist_title': 'NIVELES DE ASISTENCIA:',
          'help_ast_casual':
              '🟢 CASUAL: Muestra todo. Evita disparos repetidos. Registros completos.',
          'help_ast_standard':
              '🟡 ESTÁNDAR: Fallos desaparecen. Pierde munición repetida. Registros completos.',
          'help_ast_hardcore':
              '🔴 EXTREMO: Tierra y Fallos ocultos. Registros sin detalles.',
          'help_ast_reallife':
              '⚫ VIDA REAL: ¡Ciego! (MANTÉN PRESIONADO para marcar). Registros mínimos.',

          // --- PLACEMENT PHASE ---
          'tools': 'HERRAMIENTAS',
          'land': 'TIERRA',
          'turret': 'TORRETA',
          'fleet': 'FLOTA',
          'command': 'COMANDO',
          'auto': 'AUTO',
          'clear': 'LIMPIAR',
          'engage': 'INICIAR',
          'req_land': 'Faltan @count bloques de tierra',
          'req_turret': 'Faltan @count torretas',
          'req_ship': 'Despliega todos los barcos',
          'req_island': '¡Tierra muy dispersa! (Máx 2 islas)',
          'all_ready': '¡SISTEMAS LISTOS!',

          // --- GAME BOARD ---
          'targets': 'OBJETIVOS',
          'global_radar': 'RADAR GLOBAL',
          'radar_desc': 'Solo se rastrean impactos y flotas aliadas',
          'close_radar': 'CERRAR RADAR',
          'my_fleet': 'MI FLOTA',
          'me': 'YO',
          'defending': 'DEFENDIENDO: MI SECTOR',
          'targeting': 'APUNTANDO: @name',
          'ammo_ready': 'MUNICIÓN: ',
          'ammo_legend': '🟦 FLOTA   🟧 BONO   🩵 FIJADO',
          'targets_locked': 'OBJETIVOS FIJADOS',
          'fire_all': '¡DISPARAR!',
          'turn_announce': 'TURNO DE @name',
          'hint_reallife':
              '💡 PISTA: Mantén presionado un sector para marcar X o O.',
          'simulating': 'SIMULANDO DESPLIEGUE ENEMIGO...',
          'distribute_shots': '¡Debes distribuir los disparos equitativamente!',
          'abort_title': '¿ABORTAR MISIÓN?',
          'abort_desc':
              '¿Seguro que quieres retirarte? Se perderá el progreso.',
          'war_over': 'LA GUERRA HA TERMINADO',
          'wins': '¡@name GANA!',
          'return_base': 'VOLVER A LA BASE',

          // --- BATTLE LOGS ---
          'battle_log': 'REGISTRO DE BATALLA',
          'casual_block': '¡Sector ya revelado! (Modo Casual activado)',
          'wasted_shot': '⚠️ ¡Disparo desperdiciado! Sector ya revelado.',
          'wasted_shot_bot': '🤣 ¡@shooter desperdició un disparo!',
          'log_sunk_me': '🎉 ¡Hundiste el barco de @target! (Tamaño @size)',
          'log_sunk_enemy': '💥 ¡@shooter hundió el barco de @target!',
          'log_sunk_you': '🚨 ¡MAYDAY! ¡@shooter hundió tu barco!',
          'log_hit_me': '🎯 ¡Impacto directo en @target!',
          'log_hit_enemy': '🎯 ¡@shooter impactó a @target!',
          'log_hit_you': '⚠️ ¡Advertencia! ¡@shooter te impactó!',
          'log_turret_me': '🛡️ ¡Destruiste la torreta de @target!',
          'log_turret_enemy': '🛡️ ¡@shooter destruyó la torreta de @target!',
          'log_turret_you': '🧨 ¡Cuidado! ¡@shooter destruyó tu torreta!',
          'log_hardcore_hit': '🎯 ¡Objetivo impactado! (@target)',
          'log_hardcore_miss': '💦 ¡Objetivo fallado! (@target)',
          'log_reallife_hit': '🎯 Impacto en Sector @coord (@target)',
          'log_reallife_miss': '💦 Fallo en Sector @coord (@target)',
        },

        // ==========================================
        // 🇯🇵 JAPANESE (ja_JP) - ADDED
        // ==========================================
        'ja_JP': {
          // --- COMMON ---
          'attention': '注意！',
          'roger_that': '了解',
          'stay': '留まる',
          'retreat': '撤退',
          'size': 'サイズ:',
          'horz': '横',
          'vert': '縦',

          // --- MAIN MENU ---
          'mission_briefing': 'ミッション概要',
          'commander_name': '指揮官コールサイン',
          'local_campaign': 'ローカル (VS ボット)',
          'enemies': '敵の数:',
          'bot_speed': 'ボット速度',
          'speed_slow': '遅い',
          'speed_normal': '普通',
          'speed_fast': '速い',
          'difficulty': '難易度',
          'diff_easy': '簡単',
          'diff_normal': '普通',
          'diff_hard': '難しい',
          'assist_level': 'アシストレベル',
          'ast_casual': 'カジュアル',
          'ast_standard': 'スタンダード',
          'ast_hardcore': 'ハードコア',
          'ast_reallife': 'リアルライフ',
          'grid_size': 'グリッドサイズ',
          'engage_bots': '交戦開始',

          // --- MULTIPLAYER LOBBY ---
          'network_battle': 'ネットワークバトル (PvP)',
          'host_join': '作成 / 参加',
          'coming_soon': 'マルチプレイヤーは現在開発中です。',
          'network_lobby': 'ネットワークロビー',
          'your_ip': 'あなたのIP:',
          'host_game_btn': 'ゲームを作成',
          'host_desc': '新しいセッションを開始し\n味方を招待する',
          'quick_scan': 'クイックスキャン',
          'no_signals': 'アクティブな信号がありません...',
          'join_via_ip': 'またはIPで参加',
          'join_btn': '参加',
          'room_open': 'ルームオープン: @ip',
          'connected_station': 'バトルステーションに接続完了',
          'you_tag': 'あなた',
          'abandon_btn': '中止',
          'leave_btn': '退出',
          'start_mission': 'ミッション開始',
          'waiting_commander': '指揮官を待っています...',

          // --- HOW TO PLAY (HELP) ---
          'how_to_play': '遊び方',
          'deployment_phase': '配置フェーズ:',
          'help_step_1': '12個の陸地を描く (最大2つの島)',
          'help_step_2': '陸地に3つの砲塔を配置',
          'help_step_3': '水上に5隻の船を配置',
          'ammo_legend_title': '弾薬の凡例:',
          'ammo_legend_desc': ' 🟦 基本艦隊弾薬\n 🟧 陸地ヒットボーナス\n 🩵 ロックオン',
          'combat_rules': '戦闘ルール:',
          'rule_1': '💥 弾薬 = 1 + アクティブな砲塔 + ボーナス',
          'rule_2': '🎯 一斉射撃: ターゲットをロックして、全弾発射！',
          'rule_3': '⚖️ ルール: 生存している敵全体に均等に撃つ必要があります。',
          'help_diff_title': 'ボットの難易度:',
          'help_diff_easy': '🟢 簡単: ランダムに撃つ。同じ場所を撃つ可能性あり。',
          'help_diff_normal': '🟡 普通: ランダムに撃つが、判明した場所は避ける。',
          'help_diff_hard': '🔴 難しい: ハンター！ ヒットした周辺を集中砲火。',
          'help_assist_title': 'アシストレベル:',
          'help_ast_casual': '🟢 カジュアル: 全て表示。同じ場所を撃つのを防ぐ。',
          'help_ast_standard': '🟡 スタンダード: ミスは消える。同じ場所を撃つと弾を消費。',
          'help_ast_hardcore': '🔴 ハードコア: 陸地とミスは非表示。ログの詳細は隠される。',
          'help_ast_reallife': '⚫ リアルライフ: ブラインド！ (長押しで手動マーク)。',

          // --- PLACEMENT PHASE ---
          'tools': 'ツール',
          'land': '陸地',
          'turret': '砲塔',
          'fleet': '艦隊',
          'command': 'コマンド',
          'auto': '自動',
          'clear': 'クリア',
          'engage': '交戦',
          'req_land': 'あと @count 個の陸地が必要です',
          'req_turret': 'あと @count 個の砲塔が必要です',
          'req_ship': '全ての船を配置してください',
          'req_island': '陸地が分散しすぎています！ (最大2つの島)',
          'all_ready': '全システム準備完了！',

          // --- GAME BOARD ---
          'targets': 'ターゲット',
          'global_radar': 'グローバルレーダー',
          'radar_desc': '成功したヒットと味方の艦隊のみ追跡されます',
          'close_radar': '閉じる',
          'my_fleet': '私の艦隊',
          'me': '私',
          'defending': '防衛中: 私のセクター',
          'targeting': 'ターゲット: @name',
          'ammo_ready': '弾薬: ',
          'ammo_legend': '🟦 艦隊   🟧 ボーナス   🩵 ロック中',
          'targets_locked': 'ターゲットロック完了',
          'fire_all': '全弾発射！',
          'turn_announce': '@name のターン',
          'hint_reallife': '💡 ヒント: セクターを長押しして手動でXまたはOをマーク。',
          'simulating': '敵の配置をシミュレート中...',
          'distribute_shots': '均等に撃つ必要があります！',
          'abort_title': 'ミッションを中止しますか？',
          'abort_desc': 'メインメニューに撤退しますか？進行状況は失われます。',
          'war_over': '戦争終結',
          'wins': '@name の勝利！',
          'return_base': '基地に帰還',

          // --- BATTLE LOGS ---
          'battle_log': 'バトルログ',
          'casual_block': '既に判明しているセクターです！',
          'wasted_shot': '⚠️ 無駄撃ち！ 既に判明しているセクターを撃ちました。',
          'wasted_shot_bot': '🤣 @shooter が既知のセクターに無駄撃ち！',
          'log_sunk_me': '🎉 @target の船を完全に沈めました！ (サイズ @size)',
          'log_sunk_enemy': '💥 @shooter が @target の船を沈めました！',
          'log_sunk_you': '🚨 メーデー！ @shooter があなたの船を沈めました！',
          'log_hit_me': '🎯 @target の船に直撃！',
          'log_hit_enemy': '🎯 @shooter が @target の船にヒット！',
          'log_hit_you': '⚠️ 警告！ @shooter があなたの船にヒット！',
          'log_turret_me': '🛡️ @target の砲塔を破壊しました！',
          'log_turret_enemy': '🛡️ @shooter が @target の砲塔を破壊しました！',
          'log_turret_you': '🧨 気をつけて！ @shooter があなたの砲塔を破壊しました！',
          'log_hardcore_hit': '🎯 ターゲットにヒット！ (@target)',
          'log_hardcore_miss': '💦 ターゲットを外しました！ (@target)',
          'log_reallife_hit': '🎯 セクター @coord でヒット (@target)',
          'log_reallife_miss': '💦 セクター @coord でミス (@target)',
        },
      };
}

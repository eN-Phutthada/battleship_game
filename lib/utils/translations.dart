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
          'game_title': 'PAPER\nBATTLESHIP',
          'ee_sub': 'Submarine deployed! ⚓',
          'ee_rocket': 'Space Force deployed! 🚀',
          'ee_boat': 'Back to basics! ⛵',
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
          'settings': 'SETTINGS',
          'haptic_feedback': 'VIBRATION / HAPTICS',
          'bgm_volume': 'MUSIC VOLUME',
          'sfx_volume': 'EFFECTS VOLUME',
          'language': 'LANGUAGE',

          // --- MULTIPLAYER LOBBY ---
          'network_battle': 'NETWORK BATTLE (PvP)',
          'lan_desc': 'Play with friends on the same Wi-Fi (LAN)',
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
          'help_step_1':
              'Draw Land blocks based on grid capacity (Max 2 islands)',
          'help_step_2': 'Deploy Turrets on Land',
          'help_step_3': 'Deploy all Ships on Water',
          'ammo_legend_title': 'AMMO LEGEND:',
          'ammo_legend_desc':
              ' 🟦 Base Fleet Ammo\n 🟧 Land Hit Bonus\n 🩵 Locked Target',
          'combat_rules': 'COMBAT RULES:',
          'rule_1': '💥 Ammo per turn = 1 (Base) + Active Turrets + Land Bonus',
          'rule_2':
              '🎯 Salvo Fire: Lock multiple targets with your available ammo, then FIRE ALL!',
          'rule_3':
              '⚖️ Rule: You must distribute your shots evenly across all alive enemies (No ganging up).',

          'help_diff_title': 'BOT DIFFICULTY:',
          'help_diff_easy':
              '🟢 EASY: Shoots randomly. May waste ammo on already revealed spots.',
          'help_diff_normal':
              '🟡 NORMAL: Shoots randomly but actively avoids revealed sectors.',
          'help_diff_hard':
              '🔴 HARD: The Hunter! Focuses fire around hit targets to sink ships fast.',

          'help_assist_title': 'ASSIST LEVELS:',
          'help_ast_casual':
              '🟢 CASUAL: Board tracks all marks. Prevents wasting ammo on revealed sectors. Detailed combat logs.',
          'help_ast_standard':
              '🟡 STANDARD: Miss marks fade away. Wasting ammo on revealed sectors is possible. Detailed combat logs.',
          'help_ast_hardcore':
              '🔴 HARDCORE: Misses and enemy land are hidden. Wasting ammo is possible. Vague combat logs.',
          'help_ast_reallife':
              '⚫ REAL LIFE: Completely blind board. Long-press to manually mark X/O. Coordinate-based logs.',

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
          'radar_desc':
              'Tracks only your fleet and successful hits on enemies.',
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
              '💡 HINT: Tap (during enemy turns) or Long-press to mark X/O. Game pauses after bot turns.',
          'btn_ack': 'ACKNOWLEDGE',
          'simulating': 'SIMULATING ENEMY PLACEMENT...',
          'distribute_shots':
              'You must distribute your shots evenly among all alive targets!',
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

          'wasted_shot': '⚠️ [YOU] Wasted a shot on a revealed sector!',
          'wasted_shot_bot': '🤣 [@shooter] Wasted a shot on a known sector!',

          'log_sunk_me':
              '🎉 [YOU] completely sank @target\'s ship! (Size @size)',
          'log_sunk_enemy': '💥 [@shooter] sank @target\'s ship!',
          'log_sunk_you': '🚨 [@shooter] sank YOUR ship!',

          'log_hit_me': '🎯 [YOU] hit @target\'s ship!',
          'log_hit_enemy': '🎯 [@shooter] hit @target\'s ship!',
          'log_hit_you': '⚠️ [@shooter] hit YOUR ship!',

          'log_turret_me': '🛡️ [YOU] destroyed @target\'s turret!',
          'log_turret_enemy': '🛡️ [@shooter] destroyed @target\'s turret!',
          'log_turret_you': '🧨 [@shooter] destroyed YOUR turret!',

          'log_hardcore_hit':
              '🎯 [?] Confirmed hit on @target! (Structure hidden)',
          'log_hardcore_miss': '💦 [?] Attack missed on @target!',

          'log_reallife_hit': '🎯 [@shooter] hit @target at @coord',
          'log_reallife_miss': '💦 [@shooter] missed @target at @coord',
          'log_reallife_sunk': '💥 [@shooter] sunk @target at @coord',
          'log_reallife_land': '⛰️ [@shooter] hit land on @target at @coord',

          // --- ERRORS ---
          'err_empty_name': 'Please enter your Commander Callsign!',
          'err_max_land': 'Land block quota reached!',
          'err_land_on_ship': 'Cannot place land over a ship!',
          'err_turret_on_water': 'Turrets must be placed on land!',
          'err_max_turret': 'Turret quota reached!',
          'err_ship_on_land': 'Ships must be placed on water (No land)!',
          'err_ship_overlap': 'Ships cannot overlap each other!',
          'err_ship_out_of_bounds':
              'Ship placement out of bounds!\n🔄 Try rotating it.',

          // --- CREDITS & WARNINGS ---
          'credits': 'CREDITS:',
          'credit_desc':
              'Game rules inspired by RUBSARB production\n"เรือรบรุ่นหนูลองยา : Battleship Beta Test Mark 1.1" (YouTube)',
          'rl_warning_title': '🚨 REAL LIFE MODE WARNING',
          'rl_warning_desc':
              'In this mode, the system will NOT automatically record your hits or misses on the enemy board.\n\nYou must remember them or manually mark your shots by LONG PRESSING on the grid.\n\nAre you ready for the ultimate challenge?',
          'accept_btn': 'ACCEPT',
          'cancel_btn': 'CANCEL',
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
          'game_title': 'ยุทธนาวี\nกระดาษ',
          'ee_sub': 'ปลดล็อกเรือดำน้ำสำเร็จ! ⚓',
          'ee_rocket': 'กองกำลังอวกาศพร้อมรบ! 🚀',
          'ee_boat': 'กลับสู่ความคลาสสิก! ⛵',
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
          'settings': 'การตั้งค่า',
          'haptic_feedback': 'ระบบสั่น (Haptics)',
          'bgm_volume': 'ระดับเสียงดนตรี',
          'sfx_volume': 'ระดับเสียงเอฟเฟกต์',
          'language': 'ภาษา (Language)',

          // --- MULTIPLAYER LOBBY ---
          'network_battle': 'รบออนไลน์ (PvP)',
          'lan_desc': 'เล่นกับเพื่อนผ่านวงแลน (Wi-Fi) เดียวกันเท่านั้น',
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
          'help_step_1': 'วาดแผ่นดินตามโควต้าของขนาดกระดาน (สูงสุด 2 เกาะ)',
          'help_step_2': 'สร้างป้อมปืนบนแผ่นดิน',
          'help_step_3': 'จัดวางกองเรือทั้งหมดลงบนผืนน้ำ',
          'ammo_legend_title': 'สัญลักษณ์กระสุน:',
          'ammo_legend_desc':
              ' 🟦 กระสุนกองเรือหลัก\n 🟧 โบนัสยิงแผ่นดิน\n 🩵 ล็อกเป้าหมายแล้ว',
          'combat_rules': 'กฎการปะทะ:',
          'rule_1':
              '💥 กระสุนต่อเทิร์น = 1 (ฐาน) + ป้อมปืนที่รอดชีวิต + โบนัสยิงแผ่นดิน',
          'rule_2':
              '🎯 ยิงรัว (Salvo): ล็อกหลายเป้าหมายตามกระสุนที่มี แล้วกดยิงรวดเดียว!',
          'rule_3':
              '⚖️ กฎเหล็ก: ต้องกระจายเป้าหมายการยิงให้ศัตรูที่รอดชีวิตเท่าๆ กัน (ห้ามรุม)',

          'help_diff_title': 'ระดับความยากของ AI:',
          'help_diff_easy':
              '🟢 ง่าย: สุ่มยิงมั่ว 100% (อาจยิงเสียกระสุนฟรีในจุดที่เปิดแล้ว)',
          'help_diff_normal':
              '🟡 ปานกลาง: สุ่มยิงแบบฉลาด หลีกเลี่ยงพิกัดที่เคยยิงไปแล้ว',
          'help_diff_hard':
              '🔴 ยาก: นักล่า! เมื่อยิงโดนเรือจะสาดกระสุนรอบๆ เพื่อจมเรือทันที',

          'help_assist_title': 'ระดับการช่วยเหลือ:',
          'help_ast_casual':
              '🟢 แคชชวล: กระดานจำรอยให้ทั้งหมด ระบบป้องกันการยิงซ้ำพิกัดเดิม ประวัติรบแจ้งผลแบบละเอียด',
          'help_ast_standard':
              '🟡 มาตรฐาน: รอยยิงพลาดจะจางหายไป ระวังยิงซ้ำพิกัดเดิมเสียกระสุนฟรี ประวัติรบแจ้งผลแบบละเอียด',
          'help_ast_hardcore':
              '🔴 ฮาร์ดคอร์: ซ่อนแผ่นดินศัตรูและรอยพลาด ยิงซ้ำเสียกระสุนฟรี ประวัติรบแจ้งผลแบบคลุมเครือ',
          'help_ast_reallife':
              '⚫ มืดบอด: ซ่อนทุกอย่างบนกระดาน (กดค้างที่ช่องเพื่อจด X/O เอง) ประวัติรบแจ้งแค่พิกัดที่ยิง',

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
          'radar_desc': 'แสดงเฉพาะกองเรือฝั่งเราและรอยที่ยิงโดนศัตรู',
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
              '💡 คำแนะนำ: กดจิ้ม (ในตาของศัตรู) หรือกดค้างเพื่อบันทึก X/O เกมจะหยุดรอให้จดจนกว่าจะกดยืนยัน',
          'btn_ack': 'บันทึกเสร็จสิ้น (ข้ามเทิร์น)',
          'simulating': 'กำลังจำลองการวางกำลังศัตรู...',
          'distribute_shots':
              'คุณต้องกระจายการยิงเป้าหมายให้ศัตรูเท่าๆ กันทุกคน!',
          'abort_title': 'ยกเลิกภารกิจ?',
          'abort_desc':
              'คุณแน่ใจหรือไม่ว่าจะถอยทัพกลับสู่เมนูหลัก? ความคืบหน้าทั้งหมดจะสูญหาย',
          'war_over': 'สงครามจบลงแล้ว',
          'wins': '@name เป็นผู้ชนะ!',
          'return_base': 'กลับฐานทัพ',

          // --- BATTLE LOGS ---
          'battle_log': 'บันทึกการรบ',
          'casual_block':
              'พิกัดนี้ยิงไปแล้ว! (โหมดแคชชวลช่วยป้องกันการยิงซ้ำเสียกระสุนฟรี)',

          'wasted_shot': '⚠️ [คุณ] เสียกระสุนฟรี! ยิงซ้ำพิกัดเดิม',
          'wasted_shot_bot': '🤣 [@shooter] ยิงเสียของไปโดนจุดที่เปิดแล้ว!',

          'log_sunk_me': '🎉 [คุณ] จมเรือของ @target สำเร็จ! (ขนาด @size)',
          'log_sunk_enemy': '💥 [@shooter] จมเรือของ @target!',
          'log_sunk_you': '🚨 [@shooter] จมเรือของ [คุณ]!',

          'log_hit_me': '🎯 [คุณ] ยิงโดนเรือของ @target!',
          'log_hit_enemy': '🎯 [@shooter] ยิงโดนเรือของ @target!',
          'log_hit_you': '⚠️ [@shooter] ยิงโดนเรือของ [คุณ]!',

          'log_turret_me': '🛡️ [คุณ] ทำลายป้อมปืนของ @target!',
          'log_turret_enemy': '🛡️ [@shooter] ทำลายป้อมปืนของ @target!',
          'log_turret_you': '🧨 [@shooter] ทำลายป้อมปืนของ [คุณ]!',

          'log_hardcore_hit': '🎯 [?] ยิงโดนเป้าหมาย @target! (ซ่อนประเภท)',
          'log_hardcore_miss': '💦 [?] ยิงพลาดเป้าหมาย @target!',

          'log_reallife_hit': '🎯 [@shooter] ยิง @target โดนพิกัด @coord',
          'log_reallife_miss': '💦 [@shooter] ยิง @target พลาดพิกัด @coord',
          'log_reallife_sunk': '💥 [@shooter] ยิง @target จมที่พิกัด @coord',
          'log_reallife_land':
              '⛰️ [@shooter] ยิง @target โดนแผ่นดินพิกัด @coord',

          // --- ERRORS ---
          'err_empty_name': 'กรุณาระบุชื่อผู้บัญชาการก่อนเริ่มภารกิจ!',
          'err_max_land': 'โควต้าสร้างแผ่นดินเต็มแล้ว!',
          'err_land_on_ship': 'ไม่สามารถวางแผ่นดินทับกองเรือได้!',
          'err_turret_on_water': 'ป้อมปืนต้องวางบนแผ่นดินเท่านั้น!',
          'err_max_turret': 'โควต้าสร้างป้อมปืนเต็มแล้ว!',
          'err_ship_on_land': 'กองเรือต้องวางบนผืนน้ำ (ห้ามทับแผ่นดิน)!',
          'err_ship_overlap': 'ไม่สามารถวางกองเรือทับกันได้!',
          'err_ship_out_of_bounds':
              'กองเรือล้นออกนอกกระดาน!\n🔄 ลองกดปุ่มหมุนทิศทางดูนะ',

          // --- CREDITS & WARNINGS ---
          'credits': 'เครดิต (CREDITS):',
          'credit_desc':
              'กฎกติกาการเล่นได้รับแรงบันดาลใจจากช่อง RUBSARB production\nคลิป "เรือรบรุ่นหนูลองยา : Battleship Beta Test Mark 1.1" (YouTube)',
          'rl_warning_title': '🚨 คำเตือน: โหมดมืดบอด (REAL LIFE)',
          'rl_warning_desc':
              'ในโหมดนี้ ระบบจะ "ไม่บันทึก" รอยยิงโดนหรือพลาดบนกระดานศัตรูให้คุณ!\n\nคุณจะต้องจดจำพิกัดเอง หรือ "กดค้าง" ที่ตารางเพื่อวาดเครื่องหมาย X และ O ด้วยตัวเอง\n\nคุณพร้อมรับความท้าทายนี้หรือไม่?',
          'accept_btn': 'พร้อมลุย!',
          'cancel_btn': 'ยกเลิก',
        },

        // ==========================================
        // 🇪🇸 SPANISH (es_ES)
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
          'game_title': 'BATALLA\nNAVAL',
          'ee_sub': '¡Submarino desplegado! ⚓',
          'ee_rocket': '¡Fuerza espacial lista! 🚀',
          'ee_boat': '¡De vuelta a lo básico! ⛵',
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
          'settings': 'AJUSTES',
          'haptic_feedback': 'VIBRACIÓN',
          'bgm_volume': 'VOLUMEN MÚSICA',
          'sfx_volume': 'VOLUMEN EFECTOS',
          'language': 'IDIOMA',

          // --- MULTIPLAYER LOBBY ---
          'network_battle': 'BATALLA EN RED (PvP)',
          'lan_desc': 'Juega con amigos en la misma red Wi-Fi (LAN)',
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
          'help_step_1':
              'Dibuja bloques de Tierra según la cuadrícula (Máx 2 islas)',
          'help_step_2': 'Despliega Torretas en Tierra',
          'help_step_3': 'Despliega todos los Barcos en Agua',
          'ammo_legend_title': 'LEYENDA DE MUNICIÓN:',
          'ammo_legend_desc':
              ' 🟦 Munición Base\n 🟧 Bono por Tierra\n 🩵 Objetivo Fijado',
          'combat_rules': 'REGLAS DE COMBATE:',
          'rule_1':
              '💥 Munición por turno = 1 (Base) + Torretas Activas + Bono',
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
              '🟢 CASUAL: El tablero recuerda todo. Evita disparos repetidos. Registros detallados.',
          'help_ast_standard':
              '🟡 ESTÁNDAR: Los fallos desaparecen. Pierdes munición si repites. Registros detallados.',
          'help_ast_hardcore':
              '🔴 EXTREMO: Tierra enemiga y fallos ocultos. Pierdes munición si repites. Registros vagos.',
          'help_ast_reallife':
              '⚫ VIDA REAL: Tablero ciego. Mantén presionado para marcar X/O. Registros por coordenadas.',

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
              '💡 PISTA: Toca (turno enemigo) o mantén presionado para marcar X/O. El juego se pausa.',
          'btn_ack': 'ENTENDIDO',
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

          'wasted_shot': '⚠️ [TÚ] ¡Disparo desperdiciado en sector revelado!',
          'wasted_shot_bot': '🤣 [@shooter] desperdició un disparo!',

          'log_sunk_me': '🎉 [TÚ] hundiste el barco de @target (Tamaño @size)',
          'log_sunk_enemy': '💥 [@shooter] hundió el barco de @target',
          'log_sunk_you': '🚨 [@shooter] hundió TU barco',

          'log_hit_me': '🎯 [TÚ] impactaste el barco de @target',
          'log_hit_enemy': '🎯 [@shooter] impactó el barco de @target',
          'log_hit_you': '⚠️ [@shooter] impactó TU barco',

          'log_turret_me': '🛡️ [TÚ] destruiste la torreta de @target',
          'log_turret_enemy': '🛡️ [@shooter] destruyó la torreta de @target',
          'log_turret_you': '🧨 [@shooter] destruyó TU torreta',

          'log_hardcore_hit': '🎯 [?] Impacto en @target (Estructura oculta)',
          'log_hardcore_miss': '💦 [?] Fallo en @target',

          'log_reallife_hit': '🎯 [@shooter] impactó a @target en @coord',
          'log_reallife_miss': '💦 [@shooter] falló a @target en @coord',
          'log_reallife_sunk': '💥 [@shooter] hundió a @target en @coord',
          'log_reallife_land':
              '⛰️ [@shooter] dio en tierra de @target en @coord',

          // --- ERRORS ---
          'err_empty_name':
              '¡Por favor, ingrese su identificador de comandante!',
          'err_max_land': '¡Límite máximo de bloques de tierra alcanzado!',
          'err_land_on_ship': '¡No se puede colocar tierra sobre un barco!',
          'err_turret_on_water': '¡Las torretas deben construirse en tierra!',
          'err_max_turret': '¡Límite máximo de torretas alcanzado!',
          'err_ship_on_land':
              '¡Los barcos deben colocarse en el agua (no sobre tierra)!',
          'err_ship_overlap': '¡Los barcos no pueden superponerse!',
          'err_ship_out_of_bounds':
              '¡Barco fuera de los límites!\n🔄 Intenta rotarlo.',

          // --- CREDITS & WARNINGS ---
          'credits': 'CRÉDITOS:',
          'credit_desc':
              'Reglas del juego inspiradas en RUBSARB production\n"เรือรบรุ่นหนูลองยา : Battleship Beta Test Mark 1.1" (YouTube)',
          'rl_warning_title': '🚨 ADVERTENCIA: MODO VIDA REAL',
          'rl_warning_desc':
              'En este modo, el sistema NO registrará automáticamente tus impactos o fallos.\n\nDebes recordarlos o marcarlos manualmente MANTENIENDO PRESIONADO en la cuadrícula.\n\n¿Estás listo para el desafío?',
          'accept_btn': 'ACEPTAR',
          'cancel_btn': 'CANCELAR',
        },

        // ==========================================
        // 🇯🇵 JAPANESE (ja_JP)
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
          'game_title': 'ペーパー\n海戦',
          'ee_sub': '潜水艦配備完了！ ⚓',
          'ee_rocket': '宇宙軍出撃！ 🚀',
          'ee_boat': '基本に帰還！ ⛵',
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
          'settings': '設定',
          'haptic_feedback': '振動 (ハプティクス)',
          'bgm_volume': 'BGM 音量',
          'sfx_volume': '効果音 音量',
          'language': '言語 (Language)',

          // --- MULTIPLAYER LOBBY ---
          'network_battle': 'ネットワークバトル (PvP)',
          'lan_desc': '同じWi-Fiネットワークで友達と対戦 (LAN)',
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
          'help_step_1': 'グリッドに応じた数の陸地を描く (最大2つの島)',
          'help_step_2': '陸地に砲塔を配置',
          'help_step_3': '水上にすべての船を配置',
          'ammo_legend_title': '弾薬の凡例:',
          'ammo_legend_desc': ' 🟦 基本艦隊弾薬\n 🟧 陸地ヒットボーナス\n 🩵 ロックオン',
          'combat_rules': '戦闘ルール:',
          'rule_1': '💥 弾薬 = 1 (基本) + アクティブな砲塔 + ボーナス',
          'rule_2': '🎯 一斉射撃: ターゲットをロックして、全弾発射！',
          'rule_3': '⚖️ ルール: 生存している敵全体に均等に撃つ必要があります。',

          'help_diff_title': 'ボットの難易度:',
          'help_diff_easy': '🟢 簡単: ランダムに撃つ。同じ場所を撃つ可能性あり。',
          'help_diff_normal': '🟡 普通: ランダムに撃つが、判明した場所は避ける。',
          'help_diff_hard': '🔴 難しい: ハンター！ ヒットした周辺を集中砲火。',

          'help_assist_title': 'アシストレベル:',
          'help_ast_casual': '🟢 カジュアル: 盤面は全てを記録。無駄撃ちを自動で防止。詳細な戦闘ログ。',
          'help_ast_standard': '🟡 スタンダード: ミスの跡が消える。同じ場所を撃つと弾を消費。詳細な戦闘ログ。',
          'help_ast_hardcore': '🔴 ハードコア: 敵の陸地とミスは非表示。同じ場所を撃つと弾を消費。曖昧な戦闘ログ。',
          'help_ast_reallife': '⚫ リアルライフ: 完全なブラインド盤面（長押しで手動マーク）。座標ベースのログ。',

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
          'hint_reallife': '💡 ヒント: 敵のターン中にタップ、または長押しでX/Oをマーク。記録のために一時停止します。',
          'btn_ack': '確認 (ターン終了)',
          'simulating': '敵の配置をシミュレート中...',
          'distribute_shots': '生きているすべての敵に均等に撃つ必要があります！',
          'abort_title': 'ミッションを中止しますか？',
          'abort_desc': 'メインメニューに撤退しますか？進行状況は失われます。',
          'war_over': '戦争終結',
          'wins': '@name の勝利！',
          'return_base': '基地に帰還',

          // --- BATTLE LOGS ---
          'battle_log': 'バトルログ',
          'casual_block': '既に判明しているセクターです！',

          'wasted_shot': '⚠️ [あなた] 既に判明しているセクターに無駄撃ち！',
          'wasted_shot_bot': '🤣 [@shooter] が既知のセクターに無駄撃ち！',

          'log_sunk_me': '🎉 [あなた] が @target の船を撃沈！ (サイズ @size)',
          'log_sunk_enemy': '💥 [@shooter] が @target の船を撃沈！',
          'log_sunk_you': '🚨 [@shooter] が [あなた] の船を撃沈！',

          'log_hit_me': '🎯 [あなた] が @target の船に命中！',
          'log_hit_enemy': '🎯 [@shooter] が @target の船に命中！',
          'log_hit_you': '⚠️ [@shooter] が [あなた] の船に命中！',

          'log_turret_me': '🛡️ [あなた] が @target の砲塔を破壊！',
          'log_turret_enemy': '🛡️ [@shooter] が @target の砲塔を破壊！',
          'log_turret_you': '🧨 [@shooter] が [あなた] の砲塔を破壊！',

          'log_hardcore_hit': '🎯 [?] @target に命中！（詳細非表示）',
          'log_hardcore_miss': '💦 [?] @target への攻撃ミス！',

          'log_reallife_hit': '🎯 [@shooter] が @target の @coord に命中',
          'log_reallife_miss': '💦 [@shooter] が @target の @coord でミス',
          'log_reallife_sunk': '💥 [@shooter] が @target の @coord で撃沈',
          'log_reallife_land': '⛰️ [@shooter] が @target の @coord で陸地に命中',

          // --- ERRORS ---
          'err_empty_name': '指揮官コールサインを入力してください！',
          'err_max_land': '陸地ブロックの最大数に達しました！',
          'err_land_on_ship': '船の上に陸地を配置することはできません！',
          'err_turret_on_water': '砲塔は陸地に配置する必要があります！',
          'err_max_turret': '砲塔の最大数に達しました！',
          'err_ship_on_land': '船は水上に配置する必要があります（陸地は不可）！',
          'err_ship_overlap': '船を重ねて配置することはできません！',
          'err_ship_out_of_bounds': '船がボードからはみ出しています！\n🔄 回転させてみてください。',

          // --- CREDITS & WARNINGS ---
          'credits': 'クレジット:',
          'credit_desc':
              'ゲームルールは RUBSARB production に触発されました\n「เรือรบรุ่นหนูลองยา : Battleship Beta Test Mark 1.1」(YouTube)',
          'rl_warning_title': '🚨 警告: リアルライフモード',
          'rl_warning_desc':
              'このモードでは、システムは敵ボードのヒットやミスを自動的に記録しません。\n\n自分で覚えるか、グリッドを「長押し」して手動でマークする必要があります。\n\n究極の挑戦の準備はできていますか？',
          'accept_btn': '挑戦する',
          'cancel_btn': 'キャンセル',
        },
      };
}

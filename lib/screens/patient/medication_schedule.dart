import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // ✅ จะหาย Error เมื่อทำขั้นตอนที่ 1
import '../../app_theme.dart';
import '../../widgets/menu_card.dart';

class MedicationScheduleScreen extends StatefulWidget {
  const MedicationScheduleScreen({super.key});

  @override
  State<MedicationScheduleScreen> createState() => _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  // ✅ แก้ไข: เอา final ออกสำหรับ _calendarFormat เพราะเราต้องเปลี่ยนค่าเวลาสลับมุมมอง (เดือน/สัปดาห์)
  // แต่ถ้าคุณกะจะให้โชว์แค่รายเดือนอย่างเดียวและไม่เปลี่ยนค่าเลย สามารถใส่ final ได้ตาม Diagnostic ครับ
  CalendarFormat _calendarFormat = CalendarFormat.month; 
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // ✅ แก้ไข: เพิ่ม final ให้รายการยา ตามหลักการจัดการข้อมูลที่ส่งเข้า List
  final List<MedicationSchedule> _schedules = []; 
  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // ฟังก์ชันเช็คว่าวันที่นั้นมีกินยาไหม (แสดงจุดบนปฏิทิน)
  List<MedicationSchedule> _getEventsForDay(DateTime day) {
    return _schedules.where((schedule) {
      final endDay = schedule.startDate.add(Duration(days: schedule.durationWeeks * 7));
      return day.isAfter(schedule.startDate.subtract(const Duration(days: 1))) && 
             day.isBefore(endDay.add(const Duration(days: 1)));
    }).toList();
  }

  void _showImportDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 32),
        decoration: const BoxDecoration(
          color: kBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('นำเข้ารายการยา', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark)),
            const SizedBox(height: 24),
            buildInputCard('รหัสรายการยา', _codeCtrl, Icons.qr_code_scanner_rounded),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final code = _codeCtrl.text.trim();
                if (code.isEmpty) {
                  return;
                }

                setState(() {
                  try {
                    if (code.startsWith('MED_LIST')) {
                      final parts = code.split('|');
                      for (int i = 1; i < parts.length; i++) {
                        final drugData = parts[i].split(':');
                        if (drugData.length >= 2) {
                          _schedules.add(MedicationSchedule(
                            drugName: drugData[0],
                            doseDisplay: drugData[1],
                            instruction: drugData.length > 2 ? drugData[2] : 'ตามแพทย์สั่ง',
                            startDate: DateTime.now(),
                            durationWeeks: 4, 
                          ));
                        }
                      }
                    } else if (code.startsWith('MED')) {
                      _schedules.add(MedicationSchedule.fromCode(code));
                    }
                    _codeCtrl.clear();
                    Navigator.pop(ctx);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('รหัสไม่ถูกต้อง')),
                    );
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('ตกลง นำเข้าข้อมูล', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDay(_selectedDay!);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextDark),
        title: const Text('ตารางทานยา', style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner_rounded, color: kPrimary), onPressed: _showImportDialog),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(),
            child: TableCalendar( // ✅ จะหาย Error เมื่อลง Library
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day), // ✅ จะหาย Error
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) { // ✅ เพิ่มเพื่อให้เปลี่ยน Format รายสัปดาห์/เดือนได้
                setState(() {
                  _calendarFormat = format;
                });
              },
              eventLoader: _getEventsForDay,
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(color: kPrimaryLight, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                markerDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(formatButtonVisible: true, titleCentered: true),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('รายการยาที่ต้องทาน', style: TextStyle(fontWeight: FontWeight.bold, color: kTextGrey)),
            ),
          ),

          Expanded(
            child: selectedEvents.isEmpty 
              ? const Center(child: Text('ไม่มีรายการยาในวันที่เลือก', style: TextStyle(color: kTextGrey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: selectedEvents.length,
                  itemBuilder: (context, index) {
                    final item = selectedEvents[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: AppTheme.cardDecoration(radius: 16),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: kBackground, 
                          child: Icon(Icons.medication, color: kPrimary)
                        ),
                        title: Text(item.drugName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item.doseDisplay ?? ""}\n${item.instruction}', 
                          style: const TextStyle(fontSize: 12)),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

// --- Data Model ---
class MedicationSchedule {
  final String drugName;
  final String instruction;
  final DateTime startDate;
  final int durationWeeks;
  final String? doseDisplay;

  MedicationSchedule({
    required this.drugName,
    required this.instruction,
    required this.startDate,
    required this.durationWeeks,
    this.doseDisplay,
  });

  static MedicationSchedule fromCode(String code) {
    final parts = code.split('|');
    if (parts.length >= 5 && parts[0] == 'MED') {
      return MedicationSchedule(
        drugName: parts[1].trim(),
        instruction: parts[2].trim(),
        startDate: DateTime.tryParse(parts[3]) ?? DateTime.now(),
        durationWeeks: int.tryParse(parts[4].trim()) ?? 1,
      );
    }
    throw const FormatException();
  }
}
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../app_theme.dart';

class MedicationScheduleScreen extends StatefulWidget {
  const MedicationScheduleScreen({super.key});

  @override
  State<MedicationScheduleScreen> createState() => _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // รายการยาทั้งหมดที่แยกออกมาแล้ว
  final List<MedicationSchedule> _schedules = [];
  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // ฟังก์ชันเช็คว่าวันที่เลือกมีกินยาตัวไหนบ้าง (ใช้แสดงจุดและรายการใต้ปฏิทิน)
  List<MedicationSchedule> _getEventsForDay(DateTime day) {
    return _schedules.where((schedule) {
      // คำนวณวันสุดท้ายที่ต้องกินยา (เริ่ม + จำนวนสัปดาห์)
      final endDay = schedule.startDate.add(Duration(days: schedule.durationWeeks * 7));
      
      // เช็คว่า 'วันนั้น' อยู่ระหว่างวันที่เริ่ม กับ วันที่สิ้นสุดหรือไม่
      final isWithinRange = (day.isAtSameMomentAs(schedule.startDate) || day.isAfter(schedule.startDate)) &&
          (day.isBefore(endDay) || day.isAtSameMomentAs(endDay));
          
      return isWithinRange;
    }).toList();
  }

  // ฟังก์ชันนำเข้าโค้ดและแยกรายการยา (Split Code)
  void _importMedCode() {
    final code = _codeCtrl.text.trim();
    if (!code.startsWith("MED|")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รูปแบบโค้ดไม่ถูกต้อง')),
      );
      return;
    }

    try {
      setState(() {
        // แยกข้อมูลด้วย | 
        final parts = code.split('|');
        // parts[0] คือ "MED" ดังนั้นเริ่มวนลูปที่ index 1
        for (int i = 1; i < parts.length; i++) {
          final medData = parts[i].split(':');
          if (medData.length >= 3) {
            _schedules.add(MedicationSchedule(
              drugName: medData[0], // ชื่อยา
              doseDisplay: medData[1], // โดส
              instruction: medData[2], // วิธีใช้
              startDate: DateTime.now(), // สมมติให้เริ่มวันนี้ (หรือปรับตามต้องการ)
              durationWeeks: 4, // สมมติให้กิน 4 สัปดาห์ตามโปรโตคอล ALL
            ));
          }
        }
        _codeCtrl.clear();
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการนำเข้าข้อมูล')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('ตารางทานยา', style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded, color: kPrimary),
            onPressed: _showImportDialog,
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay, // ส่วนที่ทำให้เกิด "จุดกลมๆ" บนปฏิทิน
            onFormatChanged: (format) => setState(() => _calendarFormat = format),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: kPrimaryLight, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: kPrimary, shape: BoxShape.circle),
              markerDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle), // สีของจุดยา
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: selectedEvents.isEmpty
                ? const Center(child: Text('ไม่มีรายการยาในวันนี้', style: TextStyle(color: kTextGrey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final item = selectedEvents[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: AppTheme.cardDecoration(radius: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: kPrimary.withValues(alpha: 0.1),
                            child: const Icon(Icons.medication, color: kPrimary),
                          ),
                          title: Text(item.drugName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item.doseDisplay}\n${item.instruction}', 
                            style: const TextStyle(fontSize: 12, color: kTextGrey)),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('นำเข้าตารางยา'),
        content: TextField(
          controller: _codeCtrl,
          decoration: const InputDecoration(
            hintText: 'วางโค้ด MED|... ที่นี่',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
          ElevatedButton(onPressed: _importMedCode, child: const Text('นำเข้า')),
        ],
      ),
    );
  }
}

// --- Data Model ที่ปรับปรุงให้รองรับการ Split ข้อมูล ---
class MedicationSchedule {
  final String drugName;
  final String instruction;
  final String doseDisplay;
  final DateTime startDate;
  final int durationWeeks;

  MedicationSchedule({
    required this.drugName,
    required this.instruction,
    required this.doseDisplay,
    required this.startDate,
    required this.durationWeeks,
  });
}
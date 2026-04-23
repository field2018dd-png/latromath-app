import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/menu_card.dart';

class MedicationScheduleScreen extends StatefulWidget {
  const MedicationScheduleScreen({super.key});

  @override
  State<MedicationScheduleScreen> createState() => _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final List<MedicationSchedule> _schedules = []; 
  final _codeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextDark),
        title: const Text('ตารางทานยา',
            style: TextStyle(
                color: kTextDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: kPrimary),
            onPressed: _showImportDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: AppTheme.cardDecoration(radius: 24),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded,
                            color: kTextDark),
                        onPressed: () => setState(() => _focusedDay =
                            DateTime(_focusedDay.year, _focusedDay.month - 1)),
                      ),
                      Text(
                        '${_monthName(_focusedDay.month)} ${_focusedDay.year + 543}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: kTextDark),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded,
                            color: kTextDark),
                        onPressed: () => setState(() => _focusedDay =
                            DateTime(_focusedDay.year, _focusedDay.month + 1)),
                      ),
                    ],
                  ),
                  Row(
                    children: const ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส']
                        .map((d) => Expanded(
                              child: Center(
                                child: Text(d,
                                    style: TextStyle(
                                        color: kTextGrey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  _buildCalendarGrid(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('รายการยา',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kTextDark)),
                GestureDetector(
                  onTap: _showImportDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      // FIXED: withOpacity -> withValues
                      color: kPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded, color: kPrimary, size: 16),
                        SizedBox(width: 4),
                        Text('นำเข้าโค้ด',
                            style: TextStyle(
                                color: kPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_schedules.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: AppTheme.cardDecoration(radius: 20),
                child: const Column(
                  children: [
                    Icon(Icons.medication_outlined,
                        size: 48, color: kTextGrey),
                    SizedBox(height: 12),
                    Text('ยังไม่มีตารางยา',
                        style: TextStyle(color: kTextGrey, fontSize: 15)),
                    SizedBox(height: 4),
                    Text('กดปุ่ม "นำเข้าโค้ด" เพื่อเพิ่มตารางยาจากหมอ',
                        style: TextStyle(color: kTextGrey, fontSize: 12),
                        textAlign: TextAlign.center),
                  ],
                ),
              )
            else
              ..._schedules.map((s) => _buildMedCard(s)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final daysInMonth =
        DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    final cells = <Widget>[];
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    final today = DateTime.now();
    for (int d = 1; d <= daysInMonth; d++) {
      final day = DateTime(_focusedDay.year, _focusedDay.month, d);
      final isToday = day.year == today.year &&
          day.month == today.month &&
          day.day == today.day;
      final isSelected = _selectedDay != null &&
          day.year == _selectedDay!.year &&
          day.month == _selectedDay!.month &&
          day.day == _selectedDay!.day;
      
      final hasMed = _schedules.any((s) =>
          day.isAfter(s.startDate.subtract(const Duration(days: 1))) &&
          day.isBefore(s.startDate.add(Duration(days: s.durationWeeks * 7))));

      cells.add(GestureDetector(
        onTap: () => setState(() => _selectedDay = day),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            // FIXED: withOpacity -> withValues
            color: isSelected ? kPrimary : isToday ? kPrimary.withValues(alpha: 0.1) : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '$d',
                style: TextStyle(
                  color: isSelected ? Colors.white : kTextDark,
                  fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              if (hasMed && !isSelected)
                Positioned(
                  bottom: 4,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                        color: kPrimary, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ),
      ));
    }

    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      final rowCells = cells.sublist(i, i + 7 < cells.length ? i + 7 : cells.length);
      while (rowCells.length < 7) {
        rowCells.add(const SizedBox());
      }
      rows.add(
        SizedBox(
          height: 36,
          child: Row(children: rowCells.map((c) => Expanded(child: c)).toList()),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildMedCard(MedicationSchedule s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(radius: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // FIXED: withOpacity -> withValues
              color: kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication_rounded, color: kPrimary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.drugName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: kTextDark)),
                const SizedBox(height: 4),
                Text(s.instruction,
                    style: const TextStyle(fontSize: 13, color: kTextGrey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: kTextGrey, size: 20),
            onPressed: () => setState(() => _schedules.remove(s)),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    _codeCtrl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('นำเข้าตารางยา',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kTextDark)),
            const SizedBox(height: 8),
            const Text('วางโค้ดที่ได้รับจากแพทย์ (MED|ชื่อยา|คำแนะนำ|วันที่|สัปดาห์)',
                style: TextStyle(color: kTextGrey, fontSize: 13)),
            const SizedBox(height: 16),
            buildInputCard('โค้ดจากแพทย์', _codeCtrl, Icons.qr_code_rounded),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'นำเข้า',
              onPressed: () {
                try {
                  final med = MedicationSchedule.fromCode(_codeCtrl.text.trim());
                  setState(() {
                    _schedules.add(med);
                  });
                  Navigator.pop(ctx);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('โค้ดไม่ถูกต้อง')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const names = ['', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'];
    return names[m];
  }
}

class MedicationSchedule {
  final String drugName;
  final String instruction;
  final DateTime startDate;
  final int durationWeeks;

  MedicationSchedule({
    required this.drugName,
    required this.instruction,
    required this.startDate,
    required this.durationWeeks,
  });

  static MedicationSchedule fromCode(String code) {
    // FIXED: Updated parser to handle the 'MED|...|...' pipe-separated format
    final parts = code.split('|');
    
    if (parts.length >= 5 && parts[0] == 'MED') {
      return MedicationSchedule(
        drugName: parts[1].trim(),
        instruction: parts[2].trim(),
        startDate: DateTime.tryParse(parts[3]) ?? DateTime.now(),
        durationWeeks: int.tryParse(parts[4].trim()) ?? 1,
      );
    } 

    // Fallback for old comma-style codes (Drug, Instruction, Weeks)
    final commaParts = code.split(',');
    if (commaParts.length >= 3) {
      return MedicationSchedule(
        drugName: commaParts[0].trim(),
        instruction: commaParts[1].trim(),
        startDate: DateTime.now(),
        durationWeeks: int.tryParse(commaParts[2].trim()) ?? 1,
      );
    }

    throw Exception("Invalid format");
  }
}
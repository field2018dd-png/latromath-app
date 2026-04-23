import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_theme.dart';
import '../../widgets/menu_card.dart';
import '../../models/appointment_model.dart';

class PatientAppointmentForm extends StatefulWidget {
  const PatientAppointmentForm({super.key});

  @override
  State<PatientAppointmentForm> createState() => _PatientAppointmentFormState();
}

class _PatientAppointmentFormState extends State<PatientAppointmentForm> {
  final _patientNameCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String? _generatedCode;

  void _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kPrimary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  void _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kPrimary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  void _generateCode() {
    if (_patientNameCtrl.text.isEmpty ||
        _detailCtrl.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
            behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final dt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final apt = AppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientName: _patientNameCtrl.text.trim(),
      detail: _detailCtrl.text.trim(),
      dateTime: dt,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    setState(() => _generatedCode = apt.toCode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextDark),
        title: const Text('ใบนัดผู้ป่วย',
            style: TextStyle(
                color: kTextDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ข้อมูลการนัดหมาย',
                style: TextStyle(
                    fontSize: 13,
                    color: kTextGrey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1)),
            const SizedBox(height: 12),

            buildInputCard(
                'ชื่อ-นามสกุลผู้ป่วย', _patientNameCtrl, Icons.person_outline),
            buildInputCard(
                'วัตถุประสงค์การนัด / สิ่งที่จะทำ',
                _detailCtrl,
                Icons.medical_information_outlined),
            buildInputCard('หมายเหตุ / รายละเอียดเพิ่มเติม', _notesCtrl,
                Icons.notes_rounded),

            const SizedBox(height: 8),

            // Date/Time pickers
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      decoration: AppTheme.cardDecoration(radius: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: kPrimary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('วันนัด',
                                    style: TextStyle(
                                        color: kTextGrey, fontSize: 12)),
                                Text(
                                  _selectedDate == null
                                      ? 'เลือกวันที่'
                                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year + 543}',
                                  style: TextStyle(
                                    color: _selectedDate == null
                                        ? kTextGrey
                                        : kTextDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      decoration: AppTheme.cardDecoration(radius: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              color: kPrimary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('เวลา',
                                    style: TextStyle(
                                        color: kTextGrey, fontSize: 12)),
                                Text(
                                  _selectedTime == null
                                      ? 'เลือกเวลา'
                                      : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')} น.',
                                  style: TextStyle(
                                    color: _selectedTime == null
                                        ? kTextGrey
                                        : kTextDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
              ],
            ),

            const SizedBox(height: 24),
            PrimaryButton(
              label: 'สร้างใบนัด',
              icon: Icons.event_available_rounded,
              onPressed: _generateCode,
            ),

            if (_generatedCode != null) ...[
              const SizedBox(height: 28),

              // Appointment slip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: kPrimary.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.receipt_long_rounded,
                              color: kPrimary, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Text('ใบนัดหมาย',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: kTextDark)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _slipRow(Icons.person_outline, 'ผู้ป่วย',
                        _patientNameCtrl.text),
                    _slipRow(Icons.medical_information_outlined, 'นัดเพื่อ',
                        _detailCtrl.text),
                    if (_selectedDate != null && _selectedTime != null)
                      _slipRow(
                        Icons.calendar_today_rounded,
                        'วันเวลา',
                        '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year + 543}  ${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')} น.',
                      ),
                    if (_notesCtrl.text.isNotEmpty)
                      _slipRow(Icons.notes_rounded, 'หมายเหตุ',
                          _notesCtrl.text),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Code box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kPrimary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('โค้ดนัดหมาย',
                        style: TextStyle(
                            color: kTextGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SelectableText(
                      _generatedCode!,
                      style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: kTextDark),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: _generatedCode!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('คัดลอกโค้ดแล้ว'),
                              behavior: SnackBarBehavior.floating),
                        );
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: kPrimary.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share_rounded,
                                color: kPrimary, size: 20),
                            SizedBox(width: 8),
                            Text('แชร์ใบนัด',
                                style: TextStyle(
                                    color: kPrimary,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: _generatedCode!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('คัดลอกโค้ดสำเร็จ'),
                              behavior: SnackBarBehavior.floating),
                        );
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [kPrimary, kPrimaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('เจน Code',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _slipRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: kTextGrey),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: kTextGrey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      color: kTextDark,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
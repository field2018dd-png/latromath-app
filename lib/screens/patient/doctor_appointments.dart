import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/menu_card.dart';
import '../../models/appointment_model.dart';

class DoctorAppointments extends StatefulWidget {
  const DoctorAppointments({super.key});

  @override
  State<DoctorAppointments> createState() => _DoctorAppointmentsState();
}

class _DoctorAppointmentsState extends State<DoctorAppointments> {
  final List<AppointmentModel> _appointments = [];
  final _codeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final upcoming = _appointments
        .where((a) => a.dateTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final past = _appointments
        .where((a) => !a.dateTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextDark),
        title: const Text('ตารางนัดหมอ',
            style: TextStyle(
                color: kTextDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: kPrimary),
            onPressed: _showImportDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_appointments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: AppTheme.cardDecoration(radius: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.calendar_today_rounded,
                          size: 40, color: kPrimary),
                    ),
                    const SizedBox(height: 16),
                    const Text('ยังไม่มีนัดหมอ',
                        style: TextStyle(
                            color: kTextDark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('กดปุ่ม + เพื่อเพิ่มการนัดหมาย\nจากโค้ดที่แพทย์ให้',
                        style: TextStyle(color: kTextGrey, fontSize: 13),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'นำเข้าโค้ดนัด',
                      icon: Icons.qr_code_scanner_rounded,
                      onPressed: _showImportDialog,
                    ),
                  ],
                ),
              )
            else ...[
              if (upcoming.isNotEmpty) ...[
                const Text('นัดที่กำลังจะมาถึง',
                    style: TextStyle(
                        fontSize: 13,
                        color: kTextGrey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1)),
                const SizedBox(height: 12),
                ...upcoming.map((a) => _buildApptCard(a, isUpcoming: true)),
                const SizedBox(height: 24),
              ],
              if (past.isNotEmpty) ...[
                const Text('นัดที่ผ่านมา',
                    style: TextStyle(
                        fontSize: 13,
                        color: kTextGrey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1)),
                const SizedBox(height: 12),
                ...past.map((a) => _buildApptCard(a, isUpcoming: false)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApptCard(AppointmentModel a, {required bool isUpcoming}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppTheme.cardDecoration(radius: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isUpcoming ? kPrimary : Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    color: isUpcoming ? Colors.white : kTextGrey, size: 18),
                const SizedBox(width: 10),
                Text(
                  _formatDate(a.dateTime),
                  style: TextStyle(
                    color: isUpcoming ? Colors.white : kTextGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUpcoming
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatTime(a.dateTime),
                    style: TextStyle(
                      color: isUpcoming ? Colors.white : kTextGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: kTextGrey),
                    const SizedBox(width: 6),
                    Text(a.patientName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: kTextDark)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _appointments.remove(a)),
                      child: const Icon(Icons.delete_outline,
                          size: 18, color: kTextGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(a.detail,
                    style: const TextStyle(color: kTextGrey, fontSize: 13)),
                if (a.notes != null && a.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 14, color: kTextGrey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(a.notes!,
                              style: const TextStyle(
                                  fontSize: 12, color: kTextGrey)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
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
            const Text('นำเข้าการนัดหมาย',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: kTextDark)),
            const SizedBox(height: 8),
            const Text('วางโค้ดนัดที่ได้รับจากแพทย์',
                style: TextStyle(color: kTextGrey, fontSize: 13)),
            const SizedBox(height: 16),
            buildInputCard(
                'โค้ดนัดจากแพทย์', _codeCtrl, Icons.qr_code_rounded),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'นำเข้า',
              onPressed: () {
                try {
                  final apt =
                      AppointmentModel.fromCode(_codeCtrl.text.trim());
                  setState(() => _appointments.add(apt));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('เพิ่มการนัดหมายสำเร็จ!'),
                        behavior: SnackBarBehavior.floating),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('โค้ดไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง'),
                        behavior: SnackBarBehavior.floating),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year + 543}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m น.';
  }
}
import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/menu_card.dart';
import '../auth/login_screen.dart';
import 'medication_schedule.dart';
import 'doctor_appointments.dart';

class PatientMenu extends StatelessWidget {
  const PatientMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('สวัสดี 👋',
                            style: TextStyle(
                                fontSize: 14,
                                color: kTextGrey,
                                letterSpacing: 0.5)),
                        SizedBox(height: 4),
                        Text('เมนูผู้ป่วย',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: kTextDark,
                                letterSpacing: -0.5)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: AppTheme.cardDecoration(radius: 14),
                      child: const Icon(Icons.logout_rounded,
                          color: kTextGrey, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, kPrimaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      // FIXED: Used withValues(alpha: 0.3) instead of deprecated withOpacity
                      color: kPrimary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('ข้อมูลสุขภาพของคุณ',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          SizedBox(height: 4),
                          Text('จัดการยาและนัดหมอ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Icon(Icons.health_and_safety_rounded,
                        color: Colors.white38, size: 50),
                  ],
                ),
              ),

              const Text('เมนูหลัก',
                  style: TextStyle(
                      fontSize: 13,
                      color: kTextGrey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              const SizedBox(height: 16),

              MenuCard(
                title: 'ตารางทานยา',
                subtitle: 'ปฏิทินและรายการยาที่ต้องทาน',
                icon: Icons.medication_rounded,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        // FIXED: Now points to the Screen (Widget) instead of the Data Model
                        builder: (_) => const MedicationScheduleScreen())),
              ),
              const SizedBox(height: 16),
              MenuCard(
                title: 'ตารางนัดหมอ',
                subtitle: 'รายการวันนัดและรายละเอียดการนัด',
                icon: Icons.calendar_today_rounded,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DoctorAppointments())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
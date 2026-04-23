import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/menu_card.dart';
import '../auth/login_screen.dart';
import 'drug_calculator.dart';
import 'patient_appointment_form.dart';

class DoctorMenu extends StatelessWidget {
  const DoctorMenu({super.key});

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
                        Text('ยินดีต้อนรับ 👨‍⚕️',
                            style: TextStyle(
                                fontSize: 14,
                                color: kTextGrey,
                                letterSpacing: 0.5)),
                        SizedBox(height: 4),
                        Text('เมนูแพทย์',
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
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
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
                          Text('Latromath Clinical',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 13)),
                          SizedBox(height: 4),
                          Text('คำนวณยาและนัดผู้ป่วย',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Icon(Icons.science_rounded,
                        color: kPrimary.withValues(alpha: 0.7), size: 50),
                  ],
                ),
              ),

              const Text('เครื่องมือแพทย์',
                  style: TextStyle(
                      fontSize: 13,
                      color: kTextGrey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
              const SizedBox(height: 16),

              MenuCard(
                title: 'Drug Calculator',
                subtitle: 'คำนวณขนาดยา ALL สำหรับผู้ป่วย',
                icon: Icons.calculate_rounded,
                iconColor: kPrimary,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DrugCalculator())),
              ),
              const SizedBox(height: 16),
              MenuCard(
                title: 'ตารางนัดผู้ป่วย',
                subtitle: 'สร้างและส่งใบนัดหมายให้ผู้ป่วย',
                icon: Icons.event_note_rounded,
                iconColor: const Color(0xFF1A1A2E),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PatientAppointmentForm())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
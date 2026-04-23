import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/menu_card.dart';
import '../patient/patient_menu.dart';
import '../doctor/doctor_menu.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isDoctor = false;
  bool _obscurePass = true;

  void _signIn() {
    // Demo: navigate based on role toggle
    if (_isDoctor) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const DoctorMenu()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const PatientMenu()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Logo
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: const Icon(Icons.medical_services_rounded,
                      color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 28),
              const Center(
                child: Text(
                  'ยินดีต้อนรับ',
                  style: TextStyle(
                      fontSize: 14, color: kTextGrey, letterSpacing: 2),
                ),
              ),
              const Center(
                child: Text(
                  'Latromath',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Role selector
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    _roleTab('ผู้ป่วย', false, Icons.person_outline),
                    _roleTab('แพทย์', true, Icons.local_hospital_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              buildInputCard(
                  'อีเมล / ชื่อผู้ใช้', _emailCtrl, Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              buildInputCard(
                'รหัสผ่าน',
                _passCtrl,
                Icons.lock_outline,
                obscure: _obscurePass,
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscurePass
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: kTextGrey,
                      size: 20),
                  onPressed: () =>
                      setState(() => _obscurePass = !_obscurePass),
                ),
              ),

              const SizedBox(height: 32),

              PrimaryButton(label: 'เข้าสู่ระบบ', onPressed: _signIn),

              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: RichText(
                    text: const TextSpan(
                      text: 'ยังไม่มีบัญชี? ',
                      style: TextStyle(color: kTextGrey, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'ลงทะเบียน',
                          style: TextStyle(
                              color: kPrimary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleTab(String label, bool isDoctor, IconData icon) {
    final selected = _isDoctor == isDoctor;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isDoctor = isDoctor),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18, color: selected ? Colors.white : kTextGrey),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : kTextGrey,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
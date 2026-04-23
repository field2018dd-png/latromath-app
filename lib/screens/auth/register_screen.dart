import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/menu_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isDoctor = false;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextDark),
        title: const Text('ลงทะเบียน',
            style: TextStyle(
                color: kTextDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ข้อมูลส่วนตัว',
                style: TextStyle(
                    fontSize: 13,
                    color: kTextGrey,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1)),
            const SizedBox(height: 12),

            // Role selector
            Container(
              padding: const EdgeInsets.all(6),
              decoration: AppTheme.cardDecoration(radius: 16),
              child: Row(
                children: [
                  _roleTab('ผู้ป่วย', false, Icons.person_outline),
                  _roleTab('แพทย์', true, Icons.local_hospital_outlined),
                ],
              ),
            ),
            const SizedBox(height: 8),

            buildInputCard('ชื่อ-นามสกุล', _nameCtrl, Icons.badge_outlined),
            buildInputCard('อีเมล', _emailCtrl, Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            buildInputCard('เบอร์โทรศัพท์', _phoneCtrl, Icons.phone_outlined,
                keyboardType: TextInputType.phone),

            if (_isDoctor) ...[
              buildInputCard('รหัสแพทย์ / สถานพยาบาล',
                  TextEditingController(), Icons.local_hospital_outlined),
              buildInputCard(
                  'แผนก', TextEditingController(), Icons.category_outlined),
            ] else ...[
              buildInputCard(
                  'วันเกิด', TextEditingController(), Icons.cake_outlined),
              buildInputCard('กลุ่มเลือด',
                  TextEditingController(), Icons.bloodtype_outlined),
            ],

            buildInputCard(
              'รหัสผ่าน',
              _passCtrl,
              Icons.lock_outline,
              obscure: _obscure,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: kTextGrey,
                    size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            buildInputCard('ยืนยันรหัสผ่าน', _confirmCtrl, Icons.lock_outline,
                obscure: _obscure),

            const SizedBox(height: 32),

            PrimaryButton(
              label: 'สมัครสมาชิก',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('ลงทะเบียนสำเร็จ!'),
                      behavior: SnackBarBehavior.floating),
                );
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 40),
          ],
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
              Icon(icon, size: 18, color: selected ? Colors.white : kTextGrey),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                    color: selected ? Colors.white : kTextGrey,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
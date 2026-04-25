import 'package:flutter/material.dart';
import 'dart:math';
import '../../app_theme.dart';
import '../../models/drug_model.dart';

class DrugCalcDetail extends StatefulWidget {
  final DrugModel drug;
  final String weight;
  final String height;
  final String age;

  const DrugCalcDetail({
    super.key,
    required this.drug,
    this.weight = '',
    this.height = '',
    this.age = '',
  });

  @override
  State<DrugCalcDetail> createState() => _DrugCalcDetailState();
}

class _DrugCalcDetailState extends State<DrugCalcDetail> {
  late TextEditingController _weightCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _ageCtrl;

  double _bsa = 0.0;
  String _calculatedDose = '0';
  String _instruction = '';

  @override
  void initState() {
    super.initState();
    // รับค่าเริ่มต้นที่ส่งมาจากหน้าแรก
    _weightCtrl = TextEditingController(text: widget.weight);
    _heightCtrl = TextEditingController(text: widget.height);
    _ageCtrl = TextEditingController(text: widget.age);
    _calculateAll();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  // ฟังก์ชันคำนวณ BSA และขนาดยา
  void _calculateAll() {
    final w = double.tryParse(_weightCtrl.text) ?? 0;
    final h = double.tryParse(_heightCtrl.text) ?? 0;

    // สูตรคำนวณ BSA (Mosteller)
    if (w > 0 && h > 0) {
      _bsa = sqrt((w * h) / 3600);
    } else {
      _bsa = 0.0;
    }

    _calculateSpecificDrug();
    setState(() {});
  }

  void _calculateSpecificDrug() {
    if (_bsa <= 0) {
      _calculatedDose = "0";
      return;
    }

    // Logic การคำนวณตามไฟล์อ้างอิง Project ALL drug order
    switch (widget.drug.shortName.toUpperCase()) {
      case 'PRED':
        // สูตร: (ROUNDDOWN((BSA * 20)/5,0)) * 5 * 2
        double base = (_bsa * 20) / 5;
        double dose = base.floorToDouble() * 5 * 2;
        _calculatedDose = dose.toStringAsFixed(0);
        _instruction = "PRED(5mg) $_calculatedDose mg PO PC";
        break;

      case 'VCR':
        // สูตร Vincristine 1.5 mg/m2 (Max 2 mg)
        double dose = _bsa * 1.5;
        if (dose > 2.0) dose = 2.0;
        _calculatedDose = dose.toStringAsFixed(2);
        _instruction = "VCR $_calculatedDose mg IV drip in 5 min";
        break;

      case 'MTX':
        // สูตร: (ROUNDDOWN((BSA * 20)/2.5,0)) * 4
        double base = (_bsa * 20) / 2.5;
        double dose = base.floorToDouble() * 4;
        _calculatedDose = dose.toStringAsFixed(0);
        _instruction = "MTX(2.5mg) $_calculatedDose mg PO ทุกวันพุธ";
        break;

      case '6MP':
        // สูตร 6MP 75 mg/m2
        double dose = _bsa * 75;
        _calculatedDose = dose.toStringAsFixed(0);
        _instruction = "6MP(50mg) $_calculatedDose mg PO hs";
        break;

      default:
        _calculatedDose = "N/A";
        _instruction = "ตรวจสอบสูตรคำนวณอีกครั้ง";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextDark),
        title: Text(widget.drug.fullName,
            style: const TextStyle(color: kTextDark, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ส่วนแสดงผลลัพธ์ (BSA & Dose)
            Container(
              width: double.infinity,
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
                    color: kPrimary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text('Body Surface Area (BSA)',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text('${_bsa.toStringAsFixed(4)} m²',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.white24, height: 32),
                  const Text('ขนาดแนะนำ (Recommended Dose)',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text('$_calculatedDose mg',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ส่วนปรับข้อมูลน้ำหนักส่วนสูงในหน้านี้ (ถ้าต้องการแก้)
            _buildInputRow('น้ำหนัก (Weight - kg)', _weightCtrl),
            const SizedBox(height: 16),
            _buildInputRow('ส่วนสูง (Height - cm)', _heightCtrl),
            
            const SizedBox(height: 40),

            // ปุ่มเพิ่มเข้าตะกร้า (ส่งค่ากลับไปหน้าแรก)
            ElevatedButton(
              onPressed: () {
                // ส่ง Map ข้อมูลยากลับไปที่หน้า DrugCalculator
                Navigator.pop(context, {
                  'name': widget.drug.shortName,
                  'dose': '$_calculatedDose mg',
                  'instr': _instruction,
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('เพิ่มลงในตะกร้าเรียบร้อย'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Add to Cart',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: kTextGrey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _calculateAll(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
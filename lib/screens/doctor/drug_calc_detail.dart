import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../app_theme.dart';
import '../../widgets/menu_card.dart';
import '../../models/drug_model.dart';
// Removed unused appointment_model import

class DrugCalcDetail extends StatefulWidget {
  final DrugModel drug;
  const DrugCalcDetail({super.key, required this.drug});

  @override
  State<DrugCalcDetail> createState() => _DrugCalcDetailState();
}

class _DrugCalcDetailState extends State<DrugCalcDetail> {
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  double? _bsa;
  double? _result;
  String? _instruction;
  String? _dispense;

  // ─── BSA (DuBois) ─────────────────────────────────────────────────────────
  double _calcBSA(double wt, double ht) {
    if (wt <= 0 || ht <= 0) return 0;
    return 0.007184 * pow(wt, 0.425) * pow(ht, 0.725);
  }

  // ─── PRED: nearest multiple of 5 ─────────────────────────────────────────
  double _calcPred(double bsa) {
    double raw = bsa * 20;
    double divided = raw / 5;
    double rounded = (divided % 1) < 0.5 ? divided.floorToDouble() : divided.floorToDouble() + 0.5;
    return rounded * 5 * 2; 
  }

  // ─── VCR: round to 0.5 (max 2mg) ─────────────────────────────────────────
  double _calcVCR(double bsa) {
    double raw = bsa * 1.5;
    double result = (raw % 1) < 0.5 ? raw.floorToDouble() : raw.floorToDouble() + 0.5;
    return result > 2.0 ? 2.0 : result;
  }

  // ─── 6MP: ROUNDDOWN(BSA*50*7/50, 0) tab/week ───────────────────────────
  Map<String, dynamic> _calc6MP(double bsa) {
    double tabsPerWeek = (bsa * 50 * 7 / 50).floorToDouble();
    double dispense4wk = tabsPerWeek * 4;
    String instr = _get6MPInstruction(bsa);
    return {
      'result': tabsPerWeek * 50,
      'tabsPerWeek': tabsPerWeek,
      'dispense4wk': dispense4wk,
      'instruction': instr,
    };
  }

  // ─── MTX: round to 0.5 × 4 ─────────────────────
  double _calcMTX(double bsa) {
    double raw = bsa * 20 / 2.5;
    double rounded = (raw % 1) < 0.5 ? raw.floorToDouble() : raw.floorToDouble() + 0.5;
    return rounded * 4;
  }

  // ─── IT MTX: age-based ────────────────────────────────────────────────────
  double _calcITMTX(double age) {
    if (age < 1) return 5;
    if (age < 3) return 7.5;
    return 10;
  }

  // ─── 6MP instruction lookup ────────────────────────────
  String _get6MPInstruction(double bsa) {
    if (bsa < 0.58) return '6MP(50mg) 0.5 tab PO hs #5 (จ-ศ) + 0.25 tab #2 (ส-อา)';
    if (bsa < 0.72) return '6MP(50mg) 1 tab PO hs #1 (จ) + 0.5 tab #6 (อ-อา)';
    if (bsa < 0.86) return '6MP(50mg) 0.75 tab PO hs #7 (ทุกวัน)';
    if (bsa < 1.00) return '6MP(50mg) 1 tab PO hs #6 (จ-ศ) + 0.5 tab #2 (ส-อา)';
    return '6MP(50mg) 1 tab PO hs #7 (ทุกวัน)';
  }

  void _calculate() {
    final wtVal = double.tryParse(_weightCtrl.text) ?? 0;
    final htVal = double.tryParse(_heightCtrl.text) ?? 0;
    final ageVal = double.tryParse(_ageCtrl.text) ?? 0;

    if (wtVal <= 0 || htVal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('กรุณากรอกน้ำหนักและส่วนสูง'),
            behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final bsa = _calcBSA(wtVal, htVal);
    double dose = 0;
    String? instruction;
    String? dispense;

    switch (widget.drug.shortName) {
      case 'PRED':
        dose = _calcPred(bsa);
        final tabsPerDose = dose / 5 / 2;
        instruction = 'PRED(5mg) ${tabsPerDose.toStringAsFixed(1)} tab × 2 PO PC';
        dispense = '${(dose / 5 * 2 * 4).toStringAsFixed(0)} เม็ด / 4 สัปดาห์';
        break;
      case 'VCR':
        dose = _calcVCR(bsa);
        instruction = 'Vincristine ${dose.toStringAsFixed(1)} mg + NSS 30 ml IV drip in 5 min';
        break;
      case '6MP':
        final mp = _calc6MP(bsa);
        dose = mp['result'] as double;
        instruction = mp['instruction'] as String;
        dispense = '${(mp['dispense4wk'] as double).toStringAsFixed(0)} เม็ด / 4 สัปดาห์';
        break;
      case 'MTX':
        final tabs = _calcMTX(bsa);
        dose = tabs * 2.5;
        instruction = 'MTX(2.5mg) ${tabs.toStringAsFixed(1)} tab PO ทุกวันพุธ';
        dispense = '${tabs.toStringAsFixed(0)} เม็ด / 4 สัปดาห์';
        break;
      case 'IT MTX':
        dose = _calcITMTX(ageVal);
        instruction = 'IT MTX ${dose.toStringAsFixed(1)} mg intrathecal';
        break;
      case 'BACT':
        final tmp = (2.5 * wtVal / 80);
        dose = tmp * 80;
        instruction = 'Bactrim ${tmp.toStringAsFixed(2)} tab (TMP) × 2 doses × 3 days/week';
        dispense = '${(tmp * 2 * 3 * 4).toStringAsFixed(1)} tab TMP / 4 สัปดาห์';
        break;
    }

    setState(() {
      _bsa = bsa;
      _result = dose;
      _instruction = instruction;
      _dispense = dispense;
    });
  }

  String _generateMedCode() {
    final startDate = DateTime.now();
    return 'MED|${widget.drug.fullName}|${_instruction ?? ''}|${startDate.toIso8601String()}|4';
  }

  void _showCodeDialog() {
    if (_result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('กรุณาคำนวณขนาดยาก่อน'),
            behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final code = _generateMedCode();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('โค้ดตารางยา',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: kTextDark)),
            const SizedBox(height: 8),
            const Text('ผู้ป่วยนำโค้ดนี้ไป import ในแอป',
                style: TextStyle(color: kTextGrey, fontSize: 13)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kPrimary.withValues(alpha: 0.3)),
              ),
              child: SelectableText(
                code,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: kTextDark),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'คัดลอกโค้ด',
              icon: Icons.copy_rounded,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('คัดลอกโค้ดแล้ว'),
                      behavior: SnackBarBehavior.floating),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextDark),
        title: Text(widget.drug.shortName,
            style: const TextStyle(
                color: kTextDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [kPrimary, kPrimaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medication_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.drug.fullName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text(widget.drug.description,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            const Text('ข้อมูลผู้ป่วย',
                style: TextStyle(
                    fontSize: 13,
                    color: kTextGrey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1)),
            const SizedBox(height: 12),

            buildInputCard(
                'น้ำหนัก (kg)', _weightCtrl, Icons.monitor_weight_outlined,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true)),
            buildInputCard('ส่วนสูง (cm)', _heightCtrl, Icons.height,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true)),
            buildInputCard('อายุ (ปี)', _ageCtrl, Icons.cake_outlined,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true)),

            const SizedBox(height: 24),
            PrimaryButton(label: 'คำนวณขนาดยา', onPressed: _calculate),

            if (_result != null) ...[
              const SizedBox(height: 28),
              if (_bsa != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('BSA: ',
                            style: TextStyle(
                                color: kTextGrey, fontSize: 13)),
                        Text(
                          '${_bsa!.toStringAsFixed(4)} m²',
                          style: const TextStyle(
                              color: kPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: AppTheme.cardDecoration(radius: 24),
                child: Column(
                  children: [
                    const Text('ขนาดยาที่คำนวณ',
                        style: TextStyle(color: kTextGrey, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      widget.drug.shortName == '6MP'
                          ? '${_result!.toStringAsFixed(0)} mg/week'
                          : widget.drug.shortName == 'MTX'
                              ? '${(_result! / 2.5).toStringAsFixed(1)} tab (${_result!.toStringAsFixed(1)} mg)'
                              : '${_result!.toStringAsFixed(2)} mg',
                      style: const TextStyle(
                          fontSize: 38,
                          color: kTextDark,
                          fontWeight: FontWeight.bold),
                    ),
                    if (_instruction != null) ...[
                      const Divider(height: 28),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _instruction!,
                          style: const TextStyle(
                              color: kTextDark,
                              fontSize: 13,
                              height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    if (_dispense != null) ...[
                      const SizedBox(height: 10),
                      Text('จ่าย: $_dispense',
                          style: const TextStyle(
                              color: kPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final text =
                            '${widget.drug.fullName}\n${_instruction ?? ''}\nBSA: ${_bsa?.toStringAsFixed(4)} m²';
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('คัดลอกแล้ว'),
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
                            Text('แชร์',
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
                      onTap: _showCodeDialog,
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
}
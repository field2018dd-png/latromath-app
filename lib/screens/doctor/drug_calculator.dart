import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_theme.dart';
import '../../models/drug_model.dart';
import 'drug_calc_detail.dart';

class DrugCalculator extends StatefulWidget {
  const DrugCalculator({super.key});

  @override
  State<DrugCalculator> createState() => _DrugCalculatorState();
}

class _DrugCalculatorState extends State<DrugCalculator> {
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  // ย้ายตะกร้ามาไว้ที่นี่เพื่อให้ข้อมูลไม่หาย
  final List<Map<String, String>> _cart = [];

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  // ฟังก์ชัน Generate Code สำหรับผู้ป่วย
  void _generateMedCode() {
    if (_cart.isEmpty) return;
    
    // รูปแบบ: MED|ชื่อยา1:โดส1:วิธีใช้1|ชื่อยา2:โดส2:วิธีใช้2
    String code = "MED";
    for (var item in _cart) {
      code += "|${item['name']}:${item['dose']}:${item['instr']}";
    }
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ส่งออกข้อมูลยา'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('คัดลอกโค้ดนี้ไปใส่ในหน้า "ตารางทานยา" ของผู้ป่วย'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: kBackground, borderRadius: BorderRadius.circular(8)),
              child: SelectableText(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('คัดลอกลง Clipboard แล้ว')));
            },
            child: const Text('คัดลอกโค้ด'),
          ),
        ],
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
        title: const Text('Drug Calculator', style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold)),
        actions: [
          // ปุ่มตะกร้าที่หน้าเลือกยา
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_basket_rounded, color: kPrimary),
                onPressed: _showCartDialog,
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8, top: 8,
                  child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text('${_cart.length}', style: const TextStyle(fontSize: 10, color: Colors.white))),
                )
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ส่วนกรอกข้อมูลคนไข้ (เหมือนเดิม)
            _buildPatientInfoCard(),
            const SizedBox(height: 24),
            
            // รายการยา
            ...allDrugs.map((drug) => _buildDrugCard(context, drug)).toList(),
            
            const SizedBox(height: 40),
            // ปุ่มยืนยัน Gen Code
            if (_cart.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _generateMedCode,
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text('ยืนยันรายการและ Generate Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder( // เพื่อให้ลบยาแล้ว UI ใน Dialog อัปเดต
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('รายการยาในตะกร้า'),
          content: SizedBox(
            width: double.maxFinite,
            child: _cart.isEmpty 
              ? const Text('ไม่มีรายการยา')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _cart.length,
                  itemBuilder: (ctx, i) => ListTile(
                    title: Text(_cart[i]['name']!),
                    subtitle: Text(_cart[i]['dose']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() => _cart.removeAt(i));
                        setDialogState(() {});
                      },
                    ),
                  ),
                ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ปิด'))],
        ),
      ),
    );
  }

  // --- UI Helpers (ย่อจากเดิม) ---
  Widget _buildPatientInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(
        children: [
          Row(children: [
            Expanded(child: _buildInput('น้ำหนัก (kg)', _weightCtrl, Icons.monitor_weight)),
            const SizedBox(width: 12),
            Expanded(child: _buildInput('ส่วนสูง (cm)', _heightCtrl, Icons.height)),
          ]),
          const SizedBox(height: 12),
          _buildInput('อายุ (ปี)', _ageCtrl, Icons.cake),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20, color: kPrimary), filled: true, fillColor: kBackground, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
    );
  }

  Widget _buildDrugCard(BuildContext context, DrugModel drug) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: kPrimary, child: Text(drug.shortName[0], style: const TextStyle(color: Colors.white))),
        title: Text(drug.fullName),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          // รับค่าผลลัพธ์จากการคำนวณกลับมาจากหน้า Detail
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DrugCalcDetail(drug: drug, weight: _weightCtrl.text, height: _heightCtrl.text, age: _ageCtrl.text)),
          );

          if (result != null) {
            setState(() {
              _cart.add(result as Map<String, String>);
            });
          }
        },
      ),
    );
  }
}
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../app_theme.dart';
import '../../models/drug_model.dart';

// แยก Class สำหรับจัดการการแชร์ไว้ในไฟล์เดียวกัน เพื่อป้องกัน Error เรื่อง Path
class LocalShareService {
  static final ScreenshotController _controller = ScreenshotController();

  static Future<void> shareAsImage({
    required BuildContext context,
    required Widget content,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true, 
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: kPrimary)),
    );

    try {
      final Uint8List? imageBytes = await _controller.captureFromWidget(
        Material(child: content),
        context: context,
        delay: const Duration(milliseconds: 300),
      );

      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/latromath_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(imageBytes);
        await Share.shareXFiles([XFile(file.path)], text: 'รายการยาจาก Latromath');
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      debugPrint("Share Error: $e");
    }
  }
}

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
  
  static final List<Map<String, String>> _selectedMedicines = [];

  double _calcBSA(double wt, double ht) {
    if (wt <= 0 || ht <= 0) return 0;
    return 0.007184 * pow(wt, 0.425) * pow(ht, 0.725);
  }

  void _calculate() {
    final wt = double.tryParse(_weightCtrl.text) ?? 0;
    final ht = double.tryParse(_heightCtrl.text) ?? 0;
    final age = int.tryParse(_ageCtrl.text) ?? 0; // เรียกใช้ age เพื่อแก้ unused_local_variable

    if (wt <= 0 || ht <= 0) return;

    setState(() {
      _bsa = _calcBSA(wt, ht);
      if (widget.drug.shortName == 'PRED') {
        double raw = _bsa! * 20;
        _result = (raw / 5).round() * 5.0;
        _instruction = "ทานครั้งละ ${(_result! / 5).toStringAsFixed(1)} เม็ด (5mg) วันละ 3 ครั้ง หลังอาหาร";
      } else if (widget.drug.shortName == 'IT MTX') {
        if (age < 1) {
          _result = 5;
        } else if (age < 3) {
          _result = 7.5;
        } else {
          _result = 10;
        }
        _instruction = "ฉีดเข้าช่องไขสันหลัง (Intrathecal)";
      } else {
        _result = _bsa! * 20; 
        _instruction = "ทานตามแพทย์สั่ง";
      }
    });
  }

  void _addToQueue() {
    if (_result == null) return;
    setState(() {
      _selectedMedicines.add({
        'name': widget.drug.fullName,
        'dose': '${_result!.toStringAsFixed(2)} ${widget.drug.unit}',
        'instruction': _instruction ?? '',
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('เพิ่มลงในรายการแล้ว'), behavior: SnackBarBehavior.floating),
    );
  }

  void _generateFinalCode() {
    if (_selectedMedicines.isEmpty) return;
    String code = "MED_LIST";
    for (var med in _selectedMedicines) {
      code += "|${med['name']}:${med['dose']}:${med['instruction']}";
    }
    Clipboard.setData(ClipboardData(text: code));
    _showResultDialog(code);
  }

  Future<void> _shareAsImage() async {
    if (_selectedMedicines.isEmpty) return;
    // เรียกใช้ LocalShareService ที่อยู่ในไฟล์เดียวกัน
    await LocalShareService.shareAsImage(
      context: context,
      content: _buildShareContent(),
    );
  }

  Widget _buildShareContent() {
    return Container(
      width: 600,
      padding: const EdgeInsets.all(50),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ใบสรุปรายการยา', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
          const Text('แอปพลิเคชัน Latromath', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const Divider(height: 40, thickness: 2),
          ..._selectedMedicines.map((med) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med['name']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text('ขนาด: ${med['dose']}', style: const TextStyle(fontSize: 20, color: Colors.blueAccent)),
                Text('วิธีใช้: ${med['instruction']}', style: const TextStyle(fontSize: 18)),
                const Divider(),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget buildInputCard(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kPrimary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text('คำนวณ ${widget.drug.shortName}', style: const TextStyle(color: kTextDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: kTextDark),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_basket_rounded, color: kPrimary), onPressed: _showQueueDialog),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration(),
              child: Column(
                children: [
                  buildInputCard('น้ำหนัก (kg)', _weightCtrl, Icons.monitor_weight_outlined),
                  const SizedBox(height: 12),
                  buildInputCard('ส่วนสูง (cm)', _heightCtrl, Icons.height_rounded),
                  if (widget.drug.shortName == 'IT MTX') ...[
                    const SizedBox(height: 12),
                    buildInputCard('อายุ (ปี)', _ageCtrl, Icons.cake_outlined),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimary, minimumSize: const Size(double.infinity, 50)),
                    child: const Text('คำนวณโดสยา', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            if (_result != null) ...[
              const SizedBox(height: 20),
              _buildResultCard(),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addToQueue,
                  icon: const Icon(Icons.add, color: kPrimary),
                  label: const Text('เพิ่มลงในรายการแชร์', style: TextStyle(color: kPrimary)),
                ),
              ),
            ],

            if (_selectedMedicines.isNotEmpty) ...[
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _generateFinalCode,
                icon: const Icon(Icons.code),
                label: const Text('เสร็จสิ้น & เจน Code'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _shareAsImage,
                icon: const Icon(Icons.share),
                label: const Text('แชร์รายการเป็นรูปภาพ'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          Text('${_result?.toStringAsFixed(2)} ${widget.drug.unit}', 
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kPrimary)),
          Text('BSA: ${_bsa?.toStringAsFixed(2)} m²', style: const TextStyle(color: kTextGrey)),
          const Divider(height: 30),
          // แสดง _instruction เพื่อแก้ unused_field
          Text(_instruction ?? '', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  void _showQueueDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('รายการที่เลือกไว้'),
        content: SizedBox(
          width: double.maxFinite,
          child: _selectedMedicines.isEmpty 
            ? const Text('ยังไม่มีรายการยา')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _selectedMedicines.length,
                itemBuilder: (ctx, i) => ListTile(
                  title: Text(_selectedMedicines[i]['name']!),
                  subtitle: Text(_selectedMedicines[i]['dose']!),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () {
                      setState(() => _selectedMedicines.removeAt(i));
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ปิด'))],
      ),
    );
  }

  void _showResultDialog(String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('คัดลอกสำเร็จ'),
        content: SelectableText(code),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ตกลง'))],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../models/drug_model.dart';
import 'drug_calc_detail.dart';

class DrugCalculator extends StatelessWidget {
  const DrugCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextDark),
        title: const Text('Drug Calculator',
            style: TextStyle(
                color: kTextDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // FIXED: Used withValues(alpha: 0.08) instead of deprecated withOpacity
                color: kPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: kPrimary, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'โปรโตคอล ALL Maintenance\nเลือกยาเพื่อคำนวณขนาดโดส',
                      style: TextStyle(
                          color: kPrimary, fontSize: 13, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('รายการยา',
                style: TextStyle(
                    fontSize: 13,
                    color: kTextGrey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1)),
            const SizedBox(height: 12),
            ...allDrugs.map((drug) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DrugCard(drug: drug),
                )),
          ],
        ),
      ),
    );
  }
}

class _DrugCard extends StatelessWidget {
  final DrugModel drug;
  const _DrugCard({required this.drug});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DrugCalcDetail(drug: drug))),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.cardDecoration(radius: 20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimary, kPrimaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  drug.shortName.length > 4
                      ? drug.shortName.substring(0, 4)
                      : drug.shortName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(drug.fullName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: kTextDark)),
                  const SizedBox(height: 4),
                  Text(drug.description,
                      style:
                          const TextStyle(fontSize: 12, color: kTextGrey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: kTextGrey),
          ],
        ),
      ),
    );
  }
}
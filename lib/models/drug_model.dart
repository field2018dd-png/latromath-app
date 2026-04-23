class DrugModel {
  final String shortName;
  final String fullName;
  final String unit;
  final String description;

  const DrugModel({
    required this.shortName,
    required this.fullName,
    required this.unit,
    required this.description,
  });
}

final List<DrugModel> allDrugs = [
  const DrugModel(
    shortName: 'PRED',
    fullName: 'Prednisolone',
    unit: 'mg',
    description: '20 mg/m² → ปัดเป็นทวีคูณของ 5',
  ),
  const DrugModel(
    shortName: 'VCR',
    fullName: 'Vincristine',
    unit: 'mg',
    description: '1.5 mg/m² (max 2 mg) → ปัดครึ่ง',
  ),
  const DrugModel(
    shortName: '6MP',
    fullName: '6-Mercaptopurine',
    unit: 'tab',
    description: '50 mg/m²/day × 7 วัน → ต่อสัปดาห์',
  ),
  const DrugModel(
    shortName: 'MTX',
    fullName: 'Methotrexate',
    unit: 'mg',
    description: '20 mg/m² → ปัดครึ่ง × 4 สัปดาห์',
  ),
  const DrugModel(
    shortName: 'IT MTX',
    fullName: 'Intrathecal MTX',
    unit: 'mg',
    description: 'ขึ้นกับอายุ: <1y=5mg, 1-3y=7.5mg, ≥3y=10mg',
  ),
  const DrugModel(
    shortName: 'BACT',
    fullName: 'Bactrim (TMP/SMX)',
    unit: 'mg',
    description: 'TMP 2.5 mg/kg/dose × 2 × 3 × 4 สัปดาห์',
  ),
];
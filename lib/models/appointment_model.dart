class AppointmentModel {
  final String id;
  final String patientName;
  final String detail;
  final DateTime dateTime;
  final String? notes;

  AppointmentModel({
    required this.id,
    required this.patientName,
    required this.detail,
    required this.dateTime,
    this.notes,
  });

  factory AppointmentModel.fromCode(String code) {
    // Code format: APT|patientName|detail|dateTime|notes
    final parts = code.split('|');
    if (parts.length < 4 || parts[0] != 'APT') {
      throw const FormatException('Invalid appointment code');
    }
    return AppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientName: parts[1],
      detail: parts[2],
      dateTime: DateTime.parse(parts[3]),
      notes: parts.length > 4 ? parts[4] : null,
    );
  }

  String toCode() {
    return 'APT|$patientName|$detail|${dateTime.toIso8601String()}|${notes ?? ''}';
  }
}

class MedicationSchedule {
  final String drugName;
  final String instruction;
  final DateTime startDate;
  final int durationWeeks;

  MedicationSchedule({
    required this.drugName,
    required this.instruction,
    required this.startDate,
    required this.durationWeeks,
  });

  factory MedicationSchedule.fromCode(String code) {
    // Code format: MED|drugName|instruction|startDate|durationWeeks
    final parts = code.split('|');
    if (parts.length < 5 || parts[0] != 'MED') {
      throw const FormatException('Invalid medication code');
    }
    return MedicationSchedule(
      drugName: parts[1],
      instruction: parts[2],
      startDate: DateTime.parse(parts[3]),
      durationWeeks: int.parse(parts[4]),
    );
  }

  String toCode() {
    return 'MED|$drugName|$instruction|${startDate.toIso8601String()}|$durationWeeks';
  }
}
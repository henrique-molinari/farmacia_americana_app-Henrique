class PrescriptionParseResult {
  final String rawText;
  final String? crm;
  final DateTime? issueDate;
  final String? prescriptionColor;
  final List<String> medicationCandidates;
  final List<String> filteredMedicationNames;
  final List<String> controlledKeywordsFound;

  const PrescriptionParseResult({
    required this.rawText,
    required this.crm,
    required this.issueDate,
    required this.prescriptionColor,
    required this.medicationCandidates,
    required this.filteredMedicationNames,
    required this.controlledKeywordsFound,
  });

  bool get hasControlledMedicationWarning => controlledKeywordsFound.isNotEmpty;

  int get recognizedCoreFieldCount {
    var count = 0;
    if (crm != null && crm!.trim().isNotEmpty) count++;
    if (issueDate != null) count++;
    if (prescriptionColor != null && prescriptionColor!.trim().isNotEmpty) {
      count++;
    }
    if (filteredMedicationNames.isNotEmpty) count++;
    return count;
  }
}

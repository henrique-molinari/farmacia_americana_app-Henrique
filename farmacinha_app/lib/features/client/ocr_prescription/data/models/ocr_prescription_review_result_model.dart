class OcrPrescriptionReviewResult {
  final String imagePath;
  final String fileName;
  final String crm;
  final String prescriptionColor;
  final String issueDateText;
  final List<String> medications;
  final bool wasHandwritten;
  final bool hasLowConfidenceWarning;
  final bool hasControlledMedicationWarning;
  final List<String> controlledKeywordsFound;

  const OcrPrescriptionReviewResult({
    required this.imagePath,
    required this.fileName,
    required this.crm,
    required this.prescriptionColor,
    required this.issueDateText,
    required this.medications,
    required this.wasHandwritten,
    required this.hasLowConfidenceWarning,
    required this.hasControlledMedicationWarning,
    required this.controlledKeywordsFound,
  });
}

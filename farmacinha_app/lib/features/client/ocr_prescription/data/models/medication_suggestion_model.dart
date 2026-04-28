class MedicationSuggestion {
  final String originalText;
  final String suggestedName;
  final double similarity;

  const MedicationSuggestion({
    required this.originalText,
    required this.suggestedName,
    required this.similarity,
  });
}

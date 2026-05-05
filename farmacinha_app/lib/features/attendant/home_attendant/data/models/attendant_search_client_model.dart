class AttendantSearchClient {
  final String id;
  final String initials;
  final String name;
  final String cpf;
  final String timeLabel;
  final String preview;
  final bool isUrgent;

  const AttendantSearchClient({
    required this.id,
    required this.initials,
    required this.name,
    required this.cpf,
    required this.timeLabel,
    this.preview = '',
    this.isUrgent = false,
  });
}

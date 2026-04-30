DateTime parseUtcToLocal(String date) {
  return DateTime.parse(date).toLocal();
}

DateTime? tryParseUtcToLocal(String? date) {
  if (date == null || date.trim().isEmpty) return null;
  return DateTime.tryParse(date)?.toLocal();
}

String localDateToUtcIso(DateTime date) {
  return date.toUtc().toIso8601String();
}

DateTime nowUtc() {
  return DateTime.now().toUtc();
}

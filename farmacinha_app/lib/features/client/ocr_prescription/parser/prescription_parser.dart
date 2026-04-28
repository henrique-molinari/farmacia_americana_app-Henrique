import 'package:farmacia_app/features/client/ocr_prescription/data/models/prescription_parse_result_model.dart';

class PrescriptionParser {
  static final RegExp _strictCrmRegex = RegExp(
    r'\bCRM\s*/?\s*[A-Z]{2}\s*\d{3,}\b',
    caseSensitive: false,
  );

  static final RegExp _tolerantCrmRegex = RegExp(
    r'\bC[R0O]M\s*/?\s*([A-Z]{2})\s*([0-9OIilS]{3,})\b',
    caseSensitive: false,
  );

  static final RegExp _strictDateRegex = RegExp(
    r'\b(0?[1-9]|[12][0-9]|3[01])[\/\-\.](0?[1-9]|1[0-2])[\/\-\.](\d{4})\b',
  );

  static final RegExp _tolerantDateRegex = RegExp(
    r'\b([0-3OolI][0-9OolI])[\/\-\.]([0-1OolI][0-9OolI])[\/\-\.]([12][0-9OolI]{3})\b',
    caseSensitive: false,
  );

  static const List<String> _controlledKeywords = [
    'psicotropico',
    'reten\u00E7\u00E3o',
    'retencao',
    'controle especial',
    'uso controlado',
    'receita azul',
    'receita amarela',
    'c1',
    'b1',
    'a3',
  ];

  static const List<String> _ignoredFragments = [
    'posologia',
    'paciente',
    'assinatura',
    'crm',
    'data',
    'dr.',
    'dra.',
    'uso',
    'tomar',
    'dose',
    'quantidade',
    'endereco',
    'telefone',
    'farmacia',
  ];

  PrescriptionParseResult parse(String rawText) {
    final lines = _normalizeLines(rawText);
    final normalizedText = _normalize(rawText);
    final crm = extractCrm(rawText, lines);
    final issueDate = extractIssueDate(rawText, lines);

    return PrescriptionParseResult(
      rawText: rawText,
      crm: crm,
      issueDate: issueDate,
      prescriptionColor: null,
      medicationCandidates: _extractMedicationCandidates(lines),
      filteredMedicationNames: const [],
      controlledKeywordsFound: _extractControlledKeywords(normalizedText),
    );
  }

  String? extractCrm(String rawText, [List<String>? sourceLines]) {
    final lines = sourceLines ?? _normalizeLines(rawText);
    final strictMatch = _strictCrmRegex.firstMatch(rawText);
    if (strictMatch != null) {
      return strictMatch.group(0)?.replaceAll(RegExp(r'\s+'), ' ').trim();
    }

    for (final line in lines) {
      final candidate = _normalizeOcrForCrm(line.toUpperCase());
      final tolerantMatch = _tolerantCrmRegex.firstMatch(candidate);
      if (tolerantMatch == null) continue;

      final state = tolerantMatch.group(1)?.toUpperCase();
      final digits = tolerantMatch.group(2);
      if (state == null || digits == null) continue;

      return 'CRM/$state ${_normalizeOcrDigits(digits)}';
    }

    return null;
  }

  DateTime? extractIssueDate(String rawText, [List<String>? sourceLines]) {
    final lines = sourceLines ?? _normalizeLines(rawText);
    final strictMatch = _strictDateRegex.firstMatch(rawText);
    if (strictMatch != null) {
      return _parseDate(strictMatch.group(0)!);
    }

    for (final line in lines) {
      final candidate = _normalizeOcrForDate(line);
      final tolerantMatch = _tolerantDateRegex.firstMatch(candidate);
      if (tolerantMatch == null) continue;

      final normalizedDate = [
        _normalizeOcrDigits(tolerantMatch.group(1)!),
        _normalizeOcrDigits(tolerantMatch.group(2)!),
        _normalizeOcrDigits(tolerantMatch.group(3)!),
      ].join('/');

      final parsedDate = _parseDate(normalizedDate);
      if (parsedDate != null) {
        return parsedDate;
      }
    }

    return null;
  }

  List<String> _extractMedicationCandidates(List<String> lines) {
    final scoredCandidates = <_MedicationCandidate>[];

    for (final line in lines) {
      final score = _scoreMedicationLine(line);
      if (score <= 0) continue;

      scoredCandidates.add(
        _MedicationCandidate(
          value: _cleanupMedicationLine(line),
          score: score,
        ),
      );
    }

    scoredCandidates.sort((a, b) => b.score.compareTo(a.score));

    final uniqueValues = <String>{};
    final result = <String>[];

    for (final candidate in scoredCandidates) {
      final normalized = _normalize(candidate.value);
      if (normalized.isEmpty || uniqueValues.contains(normalized)) {
        continue;
      }

      uniqueValues.add(normalized);
      result.add(candidate.value);

      if (result.length == 5) break;
    }

    return result;
  }

  int _scoreMedicationLine(String line) {
    final normalized = _normalize(line);
    if (normalized.length < 4) return 0;
    if (normalized.length > 60) return 0;
    if (_ignoredFragments.any(normalized.contains)) return 0;
    if (_strictCrmRegex.hasMatch(line) || _tolerantCrmRegex.hasMatch(line)) {
      return 0;
    }
    if (_strictDateRegex.hasMatch(line) || _tolerantDateRegex.hasMatch(line)) {
      return 0;
    }

    final hasLetters = RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(line);
    if (!hasLetters) return 0;

    var score = 1;

    if (RegExp(r'\b\d+\s*(mg|mcg|g|ml|ui|mg/ml)\b', caseSensitive: false)
        .hasMatch(line)) {
      score += 3;
    }

    if (RegExp(r'\b(comprimido|capsula|xarope|solucao|gotas)\b',
            caseSensitive: false)
        .hasMatch(line)) {
      score += 2;
    }

    final wordCount = line.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).length;
    if (wordCount >= 1 && wordCount <= 4) {
      score += 2;
    }

    if (RegExp(r'^[A-ZÀ-Ýa-zà-ÿ0-9\s\-/]+$').hasMatch(line)) {
      score += 1;
    }

    return score;
  }

  String _cleanupMedicationLine(String line) {
    return line
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[\-\•\*\.\:]+'), '')
        .trim();
  }

  List<String> _extractControlledKeywords(String normalizedText) {
    return _controlledKeywords
        .where((keyword) => normalizedText.contains(_normalize(keyword)))
        .toSet()
        .toList();
  }

  List<String> _normalizeLines(String rawText) {
    return rawText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  DateTime? _parseDate(String value) {
    final normalizedValue = value.replaceAll(RegExp(r'[-\.]'), '/');
    final parts = normalizedValue.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;

    try {
      final parsed = DateTime(year, month, day);
      if (parsed.day != day || parsed.month != month || parsed.year != year) {
        return null;
      }
      return parsed;
    } catch (_) {
      return null;
    }
  }

  String _normalizeOcrForCrm(String text) {
    return text
        .replaceAll('CR0', 'CRO')
        .replaceAll('CROM', 'CRM')
        .replaceAll('CRN', 'CRM')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalizeOcrForDate(String text) {
    return text.replaceAll(RegExp(r'\s+'), '');
  }

  String _normalizeOcrDigits(String value) {
    return value
        .replaceAll('O', '0')
        .replaceAll('o', '0')
        .replaceAll('I', '1')
        .replaceAll('l', '1')
        .replaceAll('S', '5');
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll('\u00E1', 'a')
        .replaceAll('\u00E0', 'a')
        .replaceAll('\u00E2', 'a')
        .replaceAll('\u00E3', 'a')
        .replaceAll('\u00E9', 'e')
        .replaceAll('\u00EA', 'e')
        .replaceAll('\u00ED', 'i')
        .replaceAll('\u00F3', 'o')
        .replaceAll('\u00F4', 'o')
        .replaceAll('\u00F5', 'o')
        .replaceAll('\u00FA', 'u')
        .replaceAll('\u00E7', 'c');
  }
}

class _MedicationCandidate {
  final String value;
  final int score;

  const _MedicationCandidate({
    required this.value,
    required this.score,
  });
}

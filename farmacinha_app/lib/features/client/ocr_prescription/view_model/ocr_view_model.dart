import 'package:farmacia_app/features/client/ocr_prescription/data/mocks/mock_medications_catalog.dart';
import 'package:farmacia_app/features/client/ocr_prescription/data/models/medication_suggestion_model.dart';
import 'package:farmacia_app/features/client/ocr_prescription/data/models/ocr_prescription_review_result_model.dart';
import 'package:farmacia_app/features/client/ocr_prescription/data/models/prescription_input_style_model.dart';
import 'package:farmacia_app/features/client/ocr_prescription/data/models/prescription_parse_result_model.dart';
import 'package:farmacia_app/features/client/ocr_prescription/parser/prescription_parser.dart';
import 'package:farmacia_app/features/client/ocr_prescription/service/ocr_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:string_similarity/string_similarity.dart';

class OcrViewModel extends ChangeNotifier {
  final OcrService _ocrService;
  final PrescriptionParser _prescriptionParser;
  final ImagePicker _imagePicker;
  final List<String> _medicationsCatalog;
  final TextEditingController crmController = TextEditingController();
  final TextEditingController prescriptionColorController =
      TextEditingController();
  final TextEditingController issueDateController = TextEditingController();
  final TextEditingController medicationsController = TextEditingController();

  OcrViewModel({
    OcrService? ocrService,
    PrescriptionParser? prescriptionParser,
    ImagePicker? imagePicker,
    List<String>? medicationsCatalog,
  }) : _ocrService = ocrService ?? OcrService(),
       _prescriptionParser = prescriptionParser ?? PrescriptionParser(),
       _imagePicker = imagePicker ?? ImagePicker(),
       _medicationsCatalog = medicationsCatalog ?? MockMedicationsCatalog.medications;

  bool _isLoading = false;
  String? _errorMessage;
  XFile? _selectedImage;
  String? _extractedText;
  PrescriptionParseResult? _parsedPrescription;
  List<MedicationSuggestion> _medicationSuggestions = [];
  bool _shouldShowControlledAlert = false;
  PrescriptionInputStyle? _inputStyle;
  bool _shouldShowHandwrittenWarning = false;
  bool _shouldShowMedicationPrefilterWarning = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  XFile? get selectedImage => _selectedImage;
  String? get extractedText => _extractedText;
  PrescriptionParseResult? get parsedPrescription => _parsedPrescription;
  List<MedicationSuggestion> get medicationSuggestions =>
      List.unmodifiable(_medicationSuggestions);
  bool get shouldShowControlledAlert => _shouldShowControlledAlert;
  PrescriptionInputStyle? get inputStyle => _inputStyle;
  bool get shouldShowHandwrittenWarning => _shouldShowHandwrittenWarning;
  bool get shouldShowMedicationPrefilterWarning =>
      _shouldShowMedicationPrefilterWarning;
  String get controlledMedicineWarningMessage =>
      'Para este medicamento, a apresentacao da via fisica original ou assinatura digital ICP-Brasil e obrigatoria.';
  String get pharmacistReviewNotice =>
      'OCR e apenas um apoio a digitacao. A validacao tecnica final e responsabilidade do farmaceutico logado.';
  String get handwrittenWarningMessage =>
      'Receitas escritas a caneta podem nao ser reconhecidas com seguranca. Revise todos os campos antes de enviar.';
  String get medicationPrefilterWarningMessage =>
      'Nao houve medicamentos confirmados com seguranca no catalogo. Revise ou digite manualmente nome e dosagem.';
  bool get canSubmitReview => _selectedImage != null && _parsedPrescription != null;

  // Human-in-the-loop: o OCR apenas preenche um formulario editavel para
  // conferencia do usuario e validacao tecnica do farmaceutico logado.
  bool get shouldEnableEditableReviewForm => _parsedPrescription != null;
  bool get shouldBlockImageSelectionUntilInputStyleIsChosen =>
      _inputStyle == null;
  bool get isHandwrittenInput =>
      _inputStyle == PrescriptionInputStyle.handwritten;

  bool get shouldShowLowConfidenceWarning {
    if (!isHandwrittenInput || _parsedPrescription == null) {
      return false;
    }

    final parsed = _parsedPrescription!;
    return parsed.recognizedCoreFieldCount < 3 ||
        parsed.filteredMedicationNames.isEmpty;
  }

  // Aviso: o prazo legal varia conforme categoria do medicamento/receita.
  // Este indicador e apenas um apoio operacional inicial e nunca aprova nem
  // reprova automaticamente a prescricao.
  bool get isPrescriptionPossiblyExpired {
    final issueDate = _parsedPrescription?.issueDate;
    if (issueDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(issueDate).inDays > 30;
  }

  Future<void> captureFromCamera() async {
    if (_inputStyle == null) return;
    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    await processImage(image);
  }

  Future<void> pickFromGallery() async {
    if (_inputStyle == null) return;
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    await processImage(image);
  }

  void setInputStyle(PrescriptionInputStyle style) {
    _inputStyle = style;
    _shouldShowHandwrittenWarning = style == PrescriptionInputStyle.handwritten;
    notifyListeners();
  }

  Future<void> processImage(XFile image) async {
    _setLoading(true);
    _errorMessage = null;
    _selectedImage = image;
    notifyListeners();

    try {
      final rawText = await _ocrService.extractRawText(image.path);
      final baseParsed = _prescriptionParser.parse(rawText);
      final prescriptionColor = await _ocrService.detectPrescriptionColor(
        image.path,
      );
      final medicationSuggestions = _buildSuggestions(
        baseParsed.medicationCandidates,
      );
      final filteredMedicationNames = medicationSuggestions
          .map((item) => item.suggestedName)
          .toSet()
          .toList();
      final parsed = PrescriptionParseResult(
        rawText: rawText,
        crm: baseParsed.crm,
        issueDate: baseParsed.issueDate,
        prescriptionColor: prescriptionColor,
        medicationCandidates: baseParsed.medicationCandidates,
        filteredMedicationNames: filteredMedicationNames,
        controlledKeywordsFound: baseParsed.controlledKeywordsFound,
      );

      _extractedText = rawText;
      _parsedPrescription = parsed;
      _medicationSuggestions = medicationSuggestions;
      _shouldShowControlledAlert = parsed.hasControlledMedicationWarning;
      _shouldShowMedicationPrefilterWarning = filteredMedicationNames.isEmpty;
      _fillEditableForm(parsed);
    } catch (_) {
      _errorMessage =
          'Nao foi possivel ler a receita. Tente novamente com uma imagem mais nitida.';
    } finally {
      _setLoading(false);
    }
  }

  void clearSession() {
    _errorMessage = null;
    _selectedImage = null;
    _extractedText = null;
    _parsedPrescription = null;
    _medicationSuggestions = [];
    _shouldShowControlledAlert = false;
    _inputStyle = null;
    _shouldShowHandwrittenWarning = false;
    _shouldShowMedicationPrefilterWarning = false;
    crmController.clear();
    prescriptionColorController.clear();
    issueDateController.clear();
    medicationsController.clear();
    notifyListeners();
  }

  void applyMedicationSuggestion(MedicationSuggestion suggestion) {
    final medications = _splitMedicationsText(medicationsController.text);
    final index = medications.indexWhere(
      (item) => item.trim().toLowerCase() == suggestion.originalText.trim().toLowerCase(),
    );

    if (index == -1) {
      medications.add(suggestion.suggestedName);
    } else {
      medications[index] = suggestion.suggestedName;
    }

    medicationsController.text = medications.join('\n');
    notifyListeners();
  }

  OcrPrescriptionReviewResult? buildReviewResult() {
    final image = _selectedImage;
    final parsed = _parsedPrescription;

    if (image == null || parsed == null) {
      return null;
    }

    return OcrPrescriptionReviewResult(
      imagePath: image.path,
      fileName: image.name,
      crm: crmController.text.trim(),
      prescriptionColor: prescriptionColorController.text.trim(),
      issueDateText: issueDateController.text.trim(),
      medications: _splitMedicationsText(medicationsController.text),
      wasHandwritten: isHandwrittenInput,
      hasLowConfidenceWarning: shouldShowLowConfidenceWarning,
      hasControlledMedicationWarning: _shouldShowControlledAlert,
      controlledKeywordsFound: parsed.controlledKeywordsFound,
    );
  }

  List<MedicationSuggestion> _buildSuggestions(List<String> candidates) {
    final suggestions = candidates
        .map((candidate) {
          final normalizedCandidate = _normalizeMedicationText(candidate);
          if (normalizedCandidate.length < 4) {
            return null;
          }

          final normalizedCatalog = _medicationsCatalog
              .map(_normalizeMedicationText)
              .toList();

          final match = normalizedCandidate.bestMatch(normalizedCatalog);
          final best = match.bestMatch;
          final similarity = best.rating;
          final target = best.target;

          if (target == null || similarity == null || similarity < 0.42) {
            return null;
          }

          final catalogIndex = normalizedCatalog.indexOf(target);
          if (catalogIndex == -1) {
            return null;
          }

          final suggestedName = _medicationsCatalog[catalogIndex];
          if (_containsDosage(candidate) && !_containsDosage(suggestedName)) {
            return null;
          }

          return MedicationSuggestion(
            originalText: candidate,
            suggestedName: suggestedName,
            similarity: similarity,
          );
        })
        .whereType<MedicationSuggestion>()
        .toList();

    final uniqueSuggestions = <String, MedicationSuggestion>{};
    for (final suggestion in suggestions) {
      final key = suggestion.suggestedName.toLowerCase();
      final current = uniqueSuggestions[key];
      if (current == null || suggestion.similarity > current.similarity) {
        uniqueSuggestions[key] = suggestion;
      }
    }

    return uniqueSuggestions.values.toList();
  }

  void _fillEditableForm(PrescriptionParseResult parsed) {
    crmController.text = parsed.crm ?? '';
    prescriptionColorController.text = parsed.prescriptionColor ?? '';
    issueDateController.text = parsed.issueDate != null
        ? _formatDate(parsed.issueDate!)
        : '';
    medicationsController.text = parsed.filteredMedicationNames.join('\n');
  }

  List<String> _splitMedicationsText(String value) {
    return value
        .split(RegExp(r'\r?\n'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }

  String _normalizeMedicationText(String value) {
    return value
        .toLowerCase()
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('5', 's')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _containsDosage(String value) {
    return RegExp(
      r'\b\d+\s*(mg|mcg|g|ml|ui|mg\/ml)\b',
      caseSensitive: false,
    ).hasMatch(value);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    crmController.dispose();
    prescriptionColorController.dispose();
    issueDateController.dispose();
    medicationsController.dispose();
    _ocrService.dispose();
    super.dispose();
  }
}

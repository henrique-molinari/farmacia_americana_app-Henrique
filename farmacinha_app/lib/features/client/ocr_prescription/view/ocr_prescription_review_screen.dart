import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/client/ocr_prescription/data/models/medication_suggestion_model.dart';
import 'package:farmacia_app/features/client/ocr_prescription/data/models/prescription_input_style_model.dart';
import 'package:farmacia_app/features/client/ocr_prescription/view_model/ocr_view_model.dart';
import 'package:flutter/material.dart';

class OcrPrescriptionReviewScreen extends StatefulWidget {
  const OcrPrescriptionReviewScreen({super.key});

  @override
  State<OcrPrescriptionReviewScreen> createState() =>
      _OcrPrescriptionReviewScreenState();
}

class _OcrPrescriptionReviewScreenState
    extends State<OcrPrescriptionReviewScreen> {
  late final OcrViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OcrViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Pallete.primaryRed),
        ),
        title: const Text(
          'OCR da Receita',
          style: TextStyle(
            color: Color(0xFF291715),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoCard(text: _viewModel.pharmacistReviewNotice),
                  const SizedBox(height: 12),
                  _InputStyleSelector(
                    selectedStyle: _viewModel.inputStyle,
                    onChanged: _viewModel.setInputStyle,
                  ),
                  if (_viewModel.shouldShowHandwrittenWarning) ...[
                    const SizedBox(height: 12),
                    _WarningCard(
                      title: 'Receita manuscrita',
                      message: _viewModel.handwrittenWarningMessage,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _SourceChooser(
                    isEnabled:
                        !_viewModel.shouldBlockImageSelectionUntilInputStyleIsChosen,
                    onCameraTap: _viewModel.captureFromCamera,
                    onGalleryTap: _viewModel.pickFromGallery,
                  ),
                  if (_viewModel.shouldBlockImageSelectionUntilInputStyleIsChosen) ...[
                    const SizedBox(height: 10),
                    const _MutedHelperText(
                      text:
                          'Escolha antes se a receita foi escrita a caneta ou se esta digitalizada para liberar a leitura.',
                    ),
                  ],
                  if (_viewModel.isLoading) ...[
                    const SizedBox(height: 20),
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Pallete.primaryRed),
                      ),
                    ),
                  ],
                  if (_viewModel.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _ErrorCard(message: _viewModel.errorMessage!),
                  ],
                  if (_viewModel.selectedImage != null) ...[
                    const SizedBox(height: 16),
                    _SectionTitle(title: 'Formulario editavel'),
                    const SizedBox(height: 10),
                    _FormFieldCard(
                      label: 'CRM',
                      controller: _viewModel.crmController,
                      hintText: 'Ex: CRM/SP 123456',
                    ),
                    const SizedBox(height: 12),
                    _FormFieldCard(
                      label: 'Cor da receita',
                      controller: _viewModel.prescriptionColorController,
                      hintText: 'Azul, amarela ou branca',
                    ),
                    const SizedBox(height: 12),
                    _FormFieldCard(
                      label: 'Data da receita',
                      controller: _viewModel.issueDateController,
                      hintText: 'DD/MM/AAAA',
                    ),
                    const SizedBox(height: 12),
                    _FormFieldCard(
                      label: 'Medicamentos sugeridos',
                      controller: _viewModel.medicationsController,
                      hintText: 'Um medicamento por linha',
                      maxLines: 5,
                    ),
                  ],
                  if (_viewModel.medicationSuggestions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionTitle(title: 'Sugestoes por similaridade'),
                    const SizedBox(height: 10),
                    ..._viewModel.medicationSuggestions.map(
                      (suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SuggestionCard(
                          suggestion: suggestion,
                          onApply: () =>
                              _viewModel.applyMedicationSuggestion(suggestion),
                        ),
                      ),
                    ),
                  ],
                  if (_viewModel.shouldShowMedicationPrefilterWarning) ...[
                    const SizedBox(height: 16),
                    _WarningCard(
                      title: 'Medicamento sem confirmacao segura',
                      message: _viewModel.medicationPrefilterWarningMessage,
                    ),
                  ],
                  if (_viewModel.shouldShowLowConfidenceWarning) ...[
                    const SizedBox(height: 16),
                    const _WarningCard(
                      title: 'Leitura com baixa confianca',
                      message:
                          'Como a receita foi marcada como escrita a caneta, parte dos dados pode nao ter sido reconhecida. Confira CRM, cor, data, nome e dosagem antes de enviar.',
                    ),
                  ],
                  if (_viewModel.shouldShowControlledAlert) ...[
                    const SizedBox(height: 16),
                    _WarningCard(
                      title: 'Receituario controlado',
                      message: _viewModel.controlledMedicineWarningMessage,
                    ),
                  ],
                  if (_viewModel.isPrescriptionPossiblyExpired) ...[
                    const SizedBox(height: 16),
                    const _WarningCard(
                      title: 'Possivel receita vencida',
                      message:
                          'A data identificada ultrapassa a janela inicial de 30 dias. Confira o prazo correto conforme a categoria do medicamento antes de seguir.',
                    ),
                  ],
                  if (_viewModel.canSubmitReview) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Pallete.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: const Text(
                          'Enviar para o chat',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitReview() {
    final result = _viewModel.buildReviewResult();
    if (result == null) return;
    Navigator.of(context).pop(result);
  }
}

class _InfoCard extends StatelessWidget {
  final String text;

  const _InfoCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD7D1)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF5D3F3C),
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SourceChooser extends StatelessWidget {
  final bool isEnabled;
  final Future<void> Function() onCameraTap;
  final Future<void> Function() onGalleryTap;

  const _SourceChooser({
    required this.isEnabled,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SourceCard(
            isEnabled: isEnabled,
            icon: Icons.photo_camera_rounded,
            title: 'Camera',
            subtitle: 'Fotografar receita',
            onTap: onCameraTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SourceCard(
            isEnabled: isEnabled,
            icon: Icons.photo_library_rounded,
            title: 'Galeria',
            subtitle: 'Selecionar imagem',
            onTap: onGalleryTap,
          ),
        ),
      ],
    );
  }
}

class _SourceCard extends StatelessWidget {
  final bool isEnabled;
  final IconData icon;
  final String title;
  final String subtitle;
  final Future<void> Function() onTap;

  const _SourceCard({
    required this.isEnabled,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled
          ? () {
              onTap();
            }
          : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : const Color(0xFFF3F1F0),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isEnabled
                    ? const Color(0xFFFFE8E4)
                    : const Color(0xFFE8E3E1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isEnabled ? Pallete.primaryRed : const Color(0xFFAB9E9A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isEnabled ? Color(0xFF291715) : Color(0xFF8E817D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isEnabled ? Pallete.textColor : Color(0xFFAA9E99),
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputStyleSelector extends StatelessWidget {
  final PrescriptionInputStyle? selectedStyle;
  final ValueChanged<PrescriptionInputStyle> onChanged;

  const _InputStyleSelector({
    required this.selectedStyle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Como esta a receita?',
            style: TextStyle(
              color: Color(0xFF291715),
              fontWeight: FontWeight.w800,
              fontSize: 15.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Isso ajuda a ajustar a leitura e avisar quando a IA pode falhar com letra cursiva.',
            style: TextStyle(
              color: Pallete.textColor,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InputStyleChip(
                label: 'Escrita a caneta',
                isSelected:
                    selectedStyle == PrescriptionInputStyle.handwritten,
                onTap: () => onChanged(PrescriptionInputStyle.handwritten),
              ),
              _InputStyleChip(
                label: 'Digitalizada',
                isSelected: selectedStyle == PrescriptionInputStyle.digital,
                onTap: () => onChanged(PrescriptionInputStyle.digital),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InputStyleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _InputStyleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFE8E4) : const Color(0xFFFFF8F7),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFB9AA)
                : const Color(0xFFEADFDB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Pallete.primaryRed : const Color(0xFF6A5A56),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF291715),
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _MutedHelperText extends StatelessWidget {
  final String text;

  const _MutedHelperText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8F817A),
        fontSize: 12.5,
        height: 1.35,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _FormFieldCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const _FormFieldCard({
    required this.label,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5D3F3C),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE7DDD8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE7DDD8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final MedicationSuggestion suggestion;
  final VoidCallback onApply;

  const _SuggestionCard({
    required this.suggestion,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.originalText,
                  style: const TextStyle(
                    color: Color(0xFF5D3F3C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sugestao: ${suggestion.suggestedName}',
                  style: const TextStyle(
                    color: Color(0xFF291715),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onApply,
            child: const Text(
              'Aplicar',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  final String title;
  final String message;

  const _WarningCard({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD46D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6E5C00),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF6E5C00),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Pallete.primaryRed,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

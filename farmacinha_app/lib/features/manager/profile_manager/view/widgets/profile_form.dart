import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:flutter/material.dart';

class ProfileForm extends StatefulWidget {
  final String initialName;
  final String initialRole;
  final String initialEmail;
  final Future<bool> Function(String name, String role, String email) onSave;

  const ProfileForm({
    super.key,
    required this.initialName,
    required this.initialRole,
    required this.initialEmail,
    required this.onSave,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _roleController;
  late final TextEditingController _emailController;

  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.initialName);
    _roleController = TextEditingController(text: widget.initialRole);
    _emailController = TextEditingController(text: widget.initialEmail);

    _nameController.addListener(_checkChanges);
    _roleController.addListener(_checkChanges);
    _emailController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final changed =
        _nameController.text != widget.initialName ||
        _roleController.text != widget.initialRole ||
        _emailController.text != widget.initialEmail;

    setState(() => _hasChanges = changed);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Pallete.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Pallete.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INFORMACOES PESSOAIS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Pallete.textColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          _buildField(
            label: 'Nome',
            controller: _nameController,
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Cargo',
            controller: _roleController,
            icon: Icons.badge_outlined,
            readOnly: true,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'E-mail',
            controller: _emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          if (_hasChanges) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.primaryRed,
                  foregroundColor: Pallete.whiteColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Pallete.whiteColor,
                        ),
                      )
                    : const Text(
                        'Salvar Alteracoes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final saved = await widget.onSave(
      _nameController.text,
      _roleController.text,
      _emailController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
      if (saved) {
        _hasChanges = false;
      }
    });
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Pallete.textColor,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: Pallete.textColor),
            filled: true,
            fillColor: Pallete.grayColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Pallete.primaryRed,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
          ),
        ),
      ],
    );
  }
}

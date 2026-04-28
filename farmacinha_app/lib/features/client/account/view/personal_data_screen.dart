import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/client/account/view_model/personal_data_view_model.dart';
import 'package:farmacia_app/features/client/home_client/view/home_client_screen.dart';
import 'package:farmacia_app/features/client/orders/list/view/orders_screen.dart';
import 'package:farmacia_app/features/client/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/services.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final PersonalDataViewModel viewModel = PersonalDataViewModel();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Pallete.primaryRed),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Dados Pessoais',
          style: TextStyle(
            color: Pallete.primaryRed,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputLabel('NOME COMPLETO'),
                _buildTextField(
                  controller: viewModel.nameController,
                  hint: 'Digite seu nome completo',
                  icon: Icons.person,
                  focusNode: viewModel.nameFocusNode,
                  isPrefilled: viewModel.isNamePrefilled,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 20),
                _buildInputLabel('E-MAIL'),
                _buildTextField(
                  controller: viewModel.emailController,
                  hint: 'seu@email.com',
                  icon: Icons.mail,
                  focusNode: viewModel.emailFocusNode,
                  isPrefilled: viewModel.isEmailPrefilled,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildInputLabel('CPF'),
                _buildTextField(
                  controller: viewModel.cpfController,
                  hint: '000.000.000-00',
                  icon: Icons.badge,
                  focusNode: viewModel.cpfFocusNode,
                  isPrefilled: viewModel.isCpfPrefilled,
                  keyboardType: TextInputType.number,
                  inputFormatters: viewModel.cpfInputFormatters,
                ),
                const SizedBox(height: 20),
                _buildInputLabel('TELEFONE'),
                _buildTextField(
                  controller: viewModel.phoneController,
                  hint: '(00) 00000-0000',
                  icon: Icons.call,
                  focusNode: viewModel.phoneFocusNode,
                  isPrefilled: viewModel.isPhonePrefilled,
                  keyboardType: TextInputType.phone,
                  inputFormatters: viewModel.phoneInputFormatters,
                ),
                const SizedBox(height: 28),
                _buildSecurityCard(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: Color(0xFF4D302D),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required FocusNode focusNode,
    required bool isPrefilled,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDEDEC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        autocorrect: true,
        enableSuggestions: true,
        style: TextStyle(
          fontSize: 22 / 1.4,
          color: isPrefilled
              ? const Color(0xFF9B8D8B)
              : const Color(0xFF1C1617),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 26,
            vertical: 21,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(icon, color: const Color(0xFFBBA9A7), size: 34 / 1.4),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCE4F4),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF005F93),
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Segurança da Conta',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20 / 1.3,
                      color: Color(0xFF1E1615),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Última alteração há 3 meses',
                    style: TextStyle(
                      fontSize: 14 / 1.1,
                      color: Color(0xFF5D3F3C),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: _showChangePasswordSheet,
            child: const Text(
              'Alterar Senha',
              style: TextStyle(
                color: Pallete.primaryRed,
                fontSize: 20 / 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          colors: [Pallete.primaryRed, Color(0xFFE31B23)],
        ),
        boxShadow: [
          BoxShadow(
            color: Pallete.primaryRed.withOpacity(0.30),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: viewModel.isSavingPersonalData ? null : _savePersonalData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        child: const Text(
          'Salvar Alterações',
          style: TextStyle(fontSize: 20 / 1.3, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _savePersonalData() async {
    final message = await viewModel.savePersonalData();
    if (!mounted) {
      return;
    }

    _showInfo(message);
  }

  void _onBottomNavTap(int index) {
    if (index == 3) {
      return;
    }

    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeClientScreen()),
        (route) => false,
      );
      return;
    }

    if (index == 1) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const OrdersScreen()));
      return;
    }

    _showInfo('Tela em construção.');
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showChangePasswordSheet() {
    viewModel.resetPasswordForm();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChangePasswordSheet(
        viewModel: viewModel,
        onMessage: _showGlobalMessage,
      ),
    );
  }

  void _showGlobalMessage(String message) {
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Pallete.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordSheet extends StatelessWidget {
  final PersonalDataViewModel viewModel;
  final ValueChanged<String> onMessage;

  const _ChangePasswordSheet({
    required this.viewModel,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alterar Senha',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1615),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: viewModel.currentPasswordController,
                  label: 'Senha atual',
                  obscureText: viewModel.hideCurrentPassword,
                  onToggleVisibility: viewModel.toggleCurrentPasswordVisibility,
                ),
                const SizedBox(height: 12),
                _buildPasswordField(
                  controller: viewModel.newPasswordController,
                  label: 'Nova senha',
                  obscureText: viewModel.hideNewPassword,
                  onToggleVisibility: viewModel.toggleNewPasswordVisibility,
                ),
                const SizedBox(height: 12),
                _buildPasswordField(
                  controller: viewModel.confirmPasswordController,
                  label: 'Confirmar nova senha',
                  obscureText: viewModel.hideConfirmPassword,
                  onToggleVisibility: viewModel.toggleConfirmPasswordVisibility,
                ),
                const SizedBox(height: 14),
                _buildRequirement(
                  'Mínimo de 6 caracteres',
                  viewModel.hasMinLength,
                ),
                _buildRequirement('1 letra maiúscula', viewModel.hasUppercase),
                _buildRequirement('1 letra minúscula', viewModel.hasLowercase),
                _buildRequirement('1 caractere numérico', viewModel.hasNumber),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: viewModel.isSavingPassword
                        ? null
                        : () => _saveNewPassword(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Pallete.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: viewModel.isSavingPassword
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Salvar nova senha'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: met ? Colors.green : Pallete.primaryRed,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: met ? Colors.green : Pallete.primaryRed,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNewPassword(BuildContext context) async {
    final result = await viewModel.saveNewPassword();
    if (!context.mounted) {
      return;
    }

    if (result.shouldCloseSheet) {
      Navigator.of(context).pop();
      viewModel.resetPasswordForm();
    }
    onMessage(result.message);
  }
}

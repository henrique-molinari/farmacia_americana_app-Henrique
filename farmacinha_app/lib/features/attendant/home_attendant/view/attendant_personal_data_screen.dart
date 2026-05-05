import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:farmacia_app/app/app_routes.dart';
import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view_model/attendant_personal_viewl_model.dart';

class AttendantPersonalDataScreen extends StatefulWidget {
  const AttendantPersonalDataScreen({super.key});

  @override
  State<AttendantPersonalDataScreen> createState() =>
      _AttendantPersonalDataScreenState();
}

class _AttendantPersonalDataScreenState
    extends State<AttendantPersonalDataScreen> {
  late final AttendantPersonalDataViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AttendantPersonalDataViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFF8F7),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFF8F7),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Pallete.primaryRed,
              ),
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputLabel('NOME COMPLETO'),
                _buildTextField(
                  controller: _viewModel.nameController,
                  hint: 'Digite seu nome completo',
                  icon: Icons.person,
                  focusNode: _viewModel.nameFocusNode,
                  isPrefilled: _viewModel.isNamePrefilled,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 20),
                _buildInputLabel('E-MAIL'),
                _buildTextField(
                  controller: _viewModel.emailController,
                  hint: 'seu@email.com',
                  icon: Icons.mail,
                  focusNode: _viewModel.emailFocusNode,
                  isPrefilled: _viewModel.isEmailPrefilled,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildInputLabel('CPF'),
                _buildTextField(
                  controller: _viewModel.cpfController,
                  hint: '000.000.000-00',
                  icon: Icons.badge,
                  focusNode: _viewModel.cpfFocusNode,
                  isPrefilled: _viewModel.isCpfPrefilled,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CpfInputFormatter(),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInputLabel('TELEFONE'),
                _buildTextField(
                  controller: _viewModel.phoneController,
                  hint: '(00) 00000-0000',
                  icon: Icons.call,
                  focusNode: _viewModel.phoneFocusNode,
                  isPrefilled: _viewModel.isPhonePrefilled,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    PhoneInputFormatter(),
                  ],
                ),
                const SizedBox(height: 28),
                _buildSecurityCard(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 3,
            onTap: (index) => _onBottomNavTap(context, index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Pallete.primaryRed,
            unselectedItemColor: const Color(0xFF9F9F9F),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'IN\u00cdCIO',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_rounded),
                label: 'ESTOQUE',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble),
                label: 'CHAT',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'PERFIL',
              ),
            ],
          ),
        );
      },
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
          fontSize: 16,
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
            child: Icon(icon, color: const Color(0xFFBBA9A7), size: 24),
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
                    'Seguran\u00e7a da Conta',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1E1615),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\u00daltima altera\u00e7\u00e3o h\u00e1 3 meses',
                    style: TextStyle(fontSize: 13, color: Color(0xFF5D3F3C)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.attendantSecurity);
            },
            child: const Text(
              'Alterar Senha',
              style: TextStyle(
                color: Pallete.primaryRed,
                fontSize: 16,
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
        onPressed: _savePersonalData,
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
          'Salvar Altera\u00e7\u00f5es',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _savePersonalData() {
    _viewModel.savePersonalData();
    _showInfo('Dados salvos com sucesso!');
    Navigator.of(context).pop();
  }

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == 3) {
      Navigator.pushReplacementNamed(context, AppRoutes.attendantProfile);
      return;
    }

    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRoutes.homeAttendant);
      return;
    }

    if (index == 1) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.attendantProductRegistration,
      );
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.attendantChat);
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
    final buffer = StringBuffer();

    for (int i = 0; i < limited.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
    final buffer = StringBuffer();

    for (int i = 0; i < limited.length; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 7) buffer.write('-');
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

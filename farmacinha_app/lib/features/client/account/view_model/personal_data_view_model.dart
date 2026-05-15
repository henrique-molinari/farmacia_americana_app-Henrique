import 'package:farmacia_app/features/auth/data/repositories/auth_repository.dart';
import 'package:farmacia_app/features/auth/view_models/auth_session_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonalDataViewModel extends ChangeNotifier {
  PersonalDataViewModel() {
    _prefillFromSession();
    _bindPrefilledClearBehavior(
      focusNode: cpfFocusNode,
      controller: cpfController,
      isPrefilled: () => _isCpfPrefilled,
      setPrefilled: (value) => _isCpfPrefilled = value,
    );
    _bindPrefilledClearBehavior(
      focusNode: phoneFocusNode,
      controller: phoneController,
      isPrefilled: () => _isPhonePrefilled,
      setPrefilled: (value) => _isPhonePrefilled = value,
    );
  }

  final AuthSessionViewModel _authSession = AuthSessionViewModel.instance;
  final AuthRepository _authRepository = AuthRepository.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cpfController = TextEditingController(
    text: '123.456.789-00',
  );
  final TextEditingController phoneController = TextEditingController(
    text: '(11) 98765-4321',
  );

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode cpfFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();

  bool _isNamePrefilled = false;
  bool _isEmailPrefilled = false;
  bool _isCpfPrefilled = true;
  bool _isPhonePrefilled = true;
  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  bool _isSavingPersonalData = false;
  bool _isSavingPassword = false;

  bool get isNamePrefilled => _isNamePrefilled;
  bool get isEmailPrefilled => _isEmailPrefilled;
  bool get isCpfPrefilled => _isCpfPrefilled;
  bool get isPhonePrefilled => _isPhonePrefilled;

  bool get hideCurrentPassword => _hideCurrentPassword;
  bool get hideNewPassword => _hideNewPassword;
  bool get hideConfirmPassword => _hideConfirmPassword;
  bool get isSavingPersonalData => _isSavingPersonalData;
  bool get isSavingPassword => _isSavingPassword;

  List<TextInputFormatter> get cpfInputFormatters => <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    const CpfInputFormatter(),
  ];

  List<TextInputFormatter> get phoneInputFormatters => <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    const PhoneInputFormatter(),
  ];

  void toggleCurrentPasswordVisibility() {
    _hideCurrentPassword = !_hideCurrentPassword;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _hideNewPassword = !_hideNewPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _hideConfirmPassword = !_hideConfirmPassword;
    notifyListeners();
  }

  Future<String> savePersonalData() async {
    if (_isSavingPersonalData) {
      return 'Salvamento em andamento.';
    }

    _isSavingPersonalData = true;
    notifyListeners();

    try {
      final requestedEmail = emailController.text.trim().toLowerCase();
      final updatedUser = await _authRepository.updateCurrentUserProfile(
        fullName: nameController.text,
        email: requestedEmail,
      );
      _authSession.updateCurrentUser(updatedUser);
      nameController.text = updatedUser.name;
      emailController.text = updatedUser.email;
      _isNamePrefilled = false;
      _isEmailPrefilled = false;

      if (requestedEmail != updatedUser.email.toLowerCase()) {
        return 'Nome salvo. O e-mail de login ainda continua ${updatedUser.email}. Para troca instantanea, rode o SQL update_my_profile_instant no Supabase.';
      }

      return 'Dados salvos com sucesso!';
    } on AuthException catch (error) {
      return _formatAuthError(error.message);
    } on PostgrestException catch (error) {
      return 'Não foi possível salvar no banco. Detalhe: ${error.message}';
    } catch (error) {
      return error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isSavingPersonalData = false;
      notifyListeners();
    }
  }

  Future<PasswordSaveResult> saveNewPassword() async {
    if (_isSavingPassword) {
      return const PasswordSaveResult(message: 'Alteração em andamento.');
    }

    if (currentPasswordController.text.isEmpty) {
      return const PasswordSaveResult(message: 'Informe a senha atual.');
    }

    if (newPasswordController.text.trim().isEmpty) {
      return const PasswordSaveResult(message: 'Informe a nova senha.');
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      return const PasswordSaveResult(
        message: 'A confirmação da senha não confere.',
      );
    }

    _isSavingPassword = true;
    notifyListeners();

    try {
      await _authRepository.updateCurrentUserPassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      return const PasswordSaveResult(
        message: 'Senha alterada com sucesso!',
        shouldCloseSheet: true,
      );
    } on AuthException catch (error) {
      return PasswordSaveResult(message: _formatPasswordAuthError(error));
    } catch (error) {
      return PasswordSaveResult(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      _isSavingPassword = false;
      notifyListeners();
    }
  }

  void resetPasswordForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    _hideCurrentPassword = true;
    _hideNewPassword = true;
    _hideConfirmPassword = true;
    notifyListeners();
  }

  void _prefillFromSession() {
    final user = _authSession.currentUser;
    nameController.text = user?.name ?? '';
    emailController.text = user?.email ?? '';
  }

  void _bindPrefilledClearBehavior({
    required FocusNode focusNode,
    required TextEditingController controller,
    required bool Function() isPrefilled,
    required ValueChanged<bool> setPrefilled,
  }) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus || !isPrefilled()) {
        return;
      }

      controller.clear();
      setPrefilled(false);
      notifyListeners();
    });
  }

  String _formatAuthError(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('email rate limit')) {
      return 'O Supabase bloqueou muitos envios de e-mail agora. Tente novamente mais tarde.';
    }

    if (lowerMessage.contains('email not confirmed') ||
        lowerMessage.contains('confirm')) {
      return 'O Supabase pode pedir confirmação para trocar o e-mail. Verifique a caixa de entrada.';
    }

    if (lowerMessage.contains('already registered') ||
        lowerMessage.contains('already exists')) {
      return 'Este e-mail ja esta em uso por outra conta.';
    }

    return 'Não foi possível atualizar seus dados. Detalhe: $message';
  }

  String _formatPasswordAuthError(AuthException error) {
    final lowerMessage = error.message.toLowerCase();

    if (lowerMessage.contains('invalid login credentials') ||
        lowerMessage.contains('invalid credentials')) {
      return 'Senha atual incorreta.';
    }

    if (lowerMessage.contains('password')) {
      return 'O Supabase recusou essa senha. Verifique o tamanho minimo configurado no painel.';
    }

    return 'Não foi possível alterar a senha. Detalhe: ${error.message}';
  }

  @override
  void dispose() {
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    cpfFocusNode.dispose();
    phoneFocusNode.dispose();
    nameController.dispose();
    emailController.dispose();
    cpfController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

class PasswordSaveResult {
  final String message;
  final bool shouldCloseSheet;

  const PasswordSaveResult({
    required this.message,
    this.shouldCloseSheet = false,
  });
}

class CpfInputFormatter extends TextInputFormatter {
  const CpfInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
    final buffer = StringBuffer();

    for (int i = 0; i < limited.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('.');
      }
      if (i == 9) {
        buffer.write('-');
      }
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
  const PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
    final buffer = StringBuffer();

    for (int i = 0; i < limited.length; i++) {
      if (i == 0) {
        buffer.write('(');
      }
      if (i == 2) {
        buffer.write(') ');
      }
      if (i == 7) {
        buffer.write('-');
      }
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

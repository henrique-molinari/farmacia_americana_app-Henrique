import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/attendant/home_attendant/data/models/attendant_stock_product_model.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view_model/attendant_product_registration_view_model.dart';
import 'package:farmacia_app/features/attendant/home_attendant/view_model/attendant_profile_data_store.dart';
import 'package:farmacia_app/features/client/home_client/data/models/product_model.dart';
import 'package:flutter/material.dart';

class AttendantProductRegistrationScreen extends StatefulWidget {
  const AttendantProductRegistrationScreen({super.key});

  @override
  State<AttendantProductRegistrationScreen> createState() =>
      _AttendantProductRegistrationScreenState();
}

class _AttendantProductRegistrationScreenState
    extends State<AttendantProductRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AttendantProductRegistrationViewModel _viewModel;
  bool _loadedArguments = false;

  @override
  void initState() {
    super.initState();
    _viewModel = AttendantProductRegistrationViewModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedArguments) return;
    _loadedArguments = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    _viewModel.loadEditingProduct(args is Product ? args : null);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _viewModel.registrationDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Pallete.primaryRed),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (selectedDate != null) {
      _viewModel.setRegistrationDate(selectedDate);
    }
  }

  Future<void> _saveProduct() async {
    if (_viewModel.isSaving) return;

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final result = await _viewModel.saveProduct();
    if (!mounted) return;
    _showSnackBar(result.message);
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deletar produto?'),
          content: const Text(
            'Essa ação remove o produto do sistema e do banco de dados.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.primaryRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Deletar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final result = await _viewModel.deleteCurrentProduct();
    if (!mounted) return;
    _showSnackBar(result.message);
  }

  Future<void> _generateDescription() async {
    if (_viewModel.isGeneratingDescription) return;

    if (_viewModel.nameController.text.trim().isNotEmpty &&
        _viewModel.descriptionController.text.trim().isNotEmpty) {
      final shouldReplace = await _confirmReplaceDescription();
      if (!shouldReplace) return;
    }

    final result = await _viewModel.generateProductDescription();
    if (!mounted) return;
    _showSnackBar(result.message);
  }

  Future<bool> _confirmReplaceDescription() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Substituir descrição?'),
          content: const Text(
            'Já existe uma descrição preenchida. Deseja substituir pela '
            'descrição gerada pela IA?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.primaryRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Substituir'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final isForm = _viewModel.mode == AttendantStockControlMode.form;

        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF9F9F9),
            elevation: 0,
            surfaceTintColor: const Color(0xFFF9F9F9),
            leading: IconButton(
              onPressed: isForm
                  ? _viewModel.showProductList
                  : () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Pallete.primaryRed,
              ),
            ),
            titleSpacing: 0,
            title: const Text(
              'Controle de Estoque',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Pallete.primaryRed,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              if (!isForm)
                IconButton(
                  onPressed: _viewModel.refreshProducts,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Pallete.primaryRed,
                  ),
                ),
              if (!isForm)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton.filled(
                    onPressed: _viewModel.startNewProduct,
                    style: IconButton.styleFrom(
                      backgroundColor: Pallete.primaryRed,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: isForm ? _buildProductForm() : _buildProductList(),
          ),
          bottomNavigationBar: isForm ? _buildFormActionBar() : null,
        );
      },
    );
  }

  Widget _buildProductList() {
    if (_viewModel.isLoadingProducts) {
      return const Center(
        child: CircularProgressIndicator(color: Pallete.primaryRed),
      );
    }

    return RefreshIndicator(
      color: Pallete.primaryRed,
      onRefresh: _viewModel.refreshProducts,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          TextField(
            controller: _viewModel.searchController,
            decoration: InputDecoration(
              hintText: 'Buscar produto no estoque...',
              prefixIcon: const Icon(Icons.manage_search_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Pallete.primaryRed),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (_viewModel.productsErrorMessage != null)
            _StateMessage(
              icon: Icons.error_outline_rounded,
              message: _viewModel.productsErrorMessage!,
            )
          else if (_viewModel.products.isEmpty)
            const _StateMessage(
              icon: Icons.inventory_2_outlined,
              message: 'Nenhum produto encontrado no estoque.',
            )
          else
            ..._viewModel.products.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StockProductTile(
                  product: product,
                  onTap: () => _viewModel.editProduct(product),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductForm() {
    final profile = _viewModel.profile;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 112),
        children: [
          const _FieldLabel(label: 'URL DA IMAGEM'),
          _ProductTextField(
            controller: _viewModel.imageUrlController,
            hintText: 'https://exemplo.com/imagem.jpg',
            keyboardType: TextInputType.url,
            suffixIcon: Icons.link_rounded,
            validator: _viewModel.validateImageUrl,
          ),
          if (_viewModel.imageUrl.isNotEmpty) ...[
            const SizedBox(height: 14),
            _ImageUrlPreview(imageUrl: _viewModel.imageUrl),
          ],
          const SizedBox(height: 26),
          Text(
            _viewModel.isEditing ? 'EDITAR PRODUTO' : 'NOVO PRODUTO',
            style: const TextStyle(
              color: Color(0xFF5D3F3C),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 18),
          const _FieldLabel(label: 'NOME DO PRODUTO'),
          _ProductTextField(
            controller: _viewModel.nameController,
            hintText: 'Ex: Paracetamol 500mg',
            validator: (value) =>
                _viewModel.requiredField(value, 'Informe o nome.'),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _viewModel.isGeneratingDescription
                  ? null
                  : _generateDescription,
              icon: _viewModel.isGeneratingDescription
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Pallete.primaryRed,
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 20),
              label: Text(
                _viewModel.isGeneratingDescription
                    ? 'Gerando...'
                    : 'Gerar descrição com IA',
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _FieldLabel(label: 'DESCRIÇÃO'),
          _ProductTextField(
            controller: _viewModel.descriptionController,
            hintText:
                'Insira as especificações técnicas e indicações do medicamento...',
            maxLines: 3,
            validator: (value) =>
                _viewModel.requiredField(value, 'Informe a descrição.'),
          ),
          const SizedBox(height: 24),
          const _FieldLabel(label: 'CATEGORIA'),
          DropdownButtonFormField<String>(
            value: _viewModel.selectedCategory,
            icon: const Icon(Icons.unfold_more_rounded),
            items: _viewModel.categories
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: _viewModel.selectCategory,
            decoration: _inputDecoration('Selecione uma categoria'),
            validator: (value) =>
                value == null ? 'Selecione uma categoria.' : null,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 340;
              final priceField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(label: 'PREÇO (R\$)'),
                  _ProductTextField(
                    controller: _viewModel.priceController,
                    hintText: 'R\$ 0,00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _viewModel.validatePrice,
                  ),
                ],
              );
              final stockField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(label: 'ESTOQUE ATUAL'),
                  _ProductTextField(
                    controller: _viewModel.stockController,
                    hintText: '0',
                    keyboardType: TextInputType.number,
                    validator: _viewModel.validateStock,
                  ),
                ],
              );

              if (compact) {
                return Column(
                  children: [
                    priceField,
                    const SizedBox(height: 18),
                    stockField,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: priceField),
                  const SizedBox(width: 22),
                  Expanded(child: stockField),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const _FieldLabel(label: 'DATA DE CADASTRO'),
          GestureDetector(
            onTap: _selectDate,
            child: AbsorbPointer(
              child: _ProductTextField(
                controller: _viewModel.dateController,
                hintText: 'dd/mm/aaaa',
                suffixIcon: Icons.calendar_today_rounded,
              ),
            ),
          ),
          const SizedBox(height: 34),
          _ControlledMedicationSwitch(
            value: _viewModel.isControlled,
            onChanged: _viewModel.setControlled,
          ),
          if (_viewModel.isEditing) ...[
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: _viewModel.isSaving ? null : _deleteProduct,
              style: OutlinedButton.styleFrom(
                foregroundColor: Pallete.primaryRed,
                side: const BorderSide(color: Pallete.primaryRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Deletar Produto'),
            ),
          ],
          const SizedBox(height: 34),
          const Divider(color: Color(0xFFECECEC)),
          const SizedBox(height: 24),
          const Text(
            'REGISTRADO POR',
            style: TextStyle(
              color: Color(0xFF5D3F3C),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          _RegisteredByCard(profile: profile),
        ],
      ),
    );
  }

  Widget _buildFormActionBar() {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(22, 10, 22, 18),
      child: SizedBox(
        height: 58,
        child: ElevatedButton.icon(
          onPressed: _viewModel.isSaving ? null : _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE31B23),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFE31B23).withOpacity(0.6),
            elevation: 8,
            shadowColor: Pallete.primaryRed.withOpacity(0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          icon: _viewModel.isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_rounded, size: 22),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _viewModel.isSaving ? 'Salvando...' : 'Salvar Produto',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFB8AAAA)),
      filled: true,
      fillColor: const Color(0xFFEFEFEF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(
          color: Pallete.primaryRed.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Pallete.primaryRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _StockProductTile extends StatelessWidget {
  final AttendantStockProduct product;
  final VoidCallback onTap;

  const _StockProductTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 54,
                  height: 54,
                  color: const Color(0xFFEFEFEF),
                  child: product.imageUrl.isEmpty
                      ? const Icon(
                          Icons.inventory_2_rounded,
                          color: Pallete.primaryRed,
                        )
                      : Image.network(product.imageUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.category} • Estoque: ${product.stockQuantity}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF7D6C6A),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        color: Pallete.primaryRed,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_rounded, color: Color(0xFF9E8F8D)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _StateMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(icon, size: 48, color: const Color(0xFF9E8F8D)),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF5D3F3C),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageUrlPreview extends StatelessWidget {
  final String imageUrl;

  const _ImageUrlPreview({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F4),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFF9FFFF),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(18),
                  child: const Text(
                    'NÃ£o foi possÃ­vel carregar a imagem',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF5D3F3C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'PrÃ©via',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? suffixIcon;

  const _ProductTextField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFB8AAAA)),
        suffixIcon: suffixIcon == null ? null : Icon(suffixIcon, size: 20),
        filled: true,
        fillColor: const Color(0xFFEFEFEF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 18,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF5D3F3C),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ControlledMedicationSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ControlledMedicationSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFECECEC)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_rounded,
            color: Pallete.primaryRed,
            size: 36,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medicamento Controlado',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text(
                  'Exige retenção de receita médica',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF8F7E7C), fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: Pallete.primaryRed,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _RegisteredByCard extends StatelessWidget {
  final AttendantProfileData profile;

  const _RegisteredByCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: const Color(0xFFEFF3F4),
            child: Text(
              profile.fullName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Pallete.primaryRed,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.roleDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF9E8F8D),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

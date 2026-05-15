import 'dart:math' as math;

import 'package:farmacia_app/core/palette/pallete.dart';
import 'package:farmacia_app/features/client/account/data/models/delivery_address_model.dart';
import 'package:farmacia_app/features/client/account/view/favorite_products_screen.dart';
import 'package:farmacia_app/features/client/account/view_model/addresses_view_model.dart';
import 'package:farmacia_app/features/client/home_client/view/home_client_screen.dart';
import 'package:farmacia_app/features/client/orders/list/view/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _addressesScreenBackground = Color(0xFFFFF8F7);
const Color _addressesSurfaceWhite = Color(0xFFFFFFFF);
const Color _addressesSurfaceLow = Color(0xFFFFF0EE);
const Color _addressesSurfaceHigh = Color(0xFFFFE2DE);
const Color _addressesSurfaceHighest = Color(0xFFFDDBD7);
const Color _addressesText = Color(0xFF291715);
const Color _addressesMutedText = Color(0xFF5D3F3C);
const Color _addressesSoftBlue = Color(0xFFCDE5FF);
const Color _addressesBlueText = Color(0xFF004B74);
const Color _addressesErrorContainer = Color(0xFFFFDAD6);
const Color _addressesErrorText = Color(0xFF93000A);

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final AddressesViewModel viewModel = AddressesViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.loadAddresses();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _addressesScreenBackground,
      appBar: AppBar(
        backgroundColor: _addressesScreenBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFB90014)),
        ),
        titleSpacing: 0,
        title: const Text(
          'Endereços',
          style: TextStyle(
            color: Color(0xFFB90014),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Pharmacy Care',
                  style: TextStyle(
                    color: Color(0xFFB90014),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final width = MediaQuery.of(context).size.width;
          final horizontalPadding = width < 360 ? 16.0 : 24.0;
          final contentMaxWidth = width >= 900 ? 840.0 : double.infinity;

          return RefreshIndicator(
            color: Pallete.primaryRed,
            onRefresh: viewModel.loadAddresses,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                26,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCard(width),
                      const SizedBox(height: 32),
                      _buildSectionHeader(),
                      const SizedBox(height: 22),
                      _buildAddressesContent(),
                      const SizedBox(height: 14),
                      _buildMapCard(),
                      const SizedBox(height: 42),
                      _buildAddAddressButton(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _AddressesBottomNavBar(onTap: _onBottomNavTap),
    );
  }

  Widget _buildHeroCard(double width) {
    final compact = width < 420;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compact ? 22 : 32,
        compact ? 26 : 32,
        compact ? 22 : 32,
        compact ? 24 : 28,
      ),
      decoration: BoxDecoration(
        color: _addressesSurfaceLow,
        borderRadius: BorderRadius.circular(compact ? 24 : 32),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showSideIcon = constraints.maxWidth >= 540;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Onde você está?',
                style: TextStyle(
                  color: _addressesText,
                  fontSize: compact ? 24 : 28,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Gerencie seus endereços para uma entrega rápida e segura dos seus cuidados farmacêuticos.',
                style: TextStyle(
                  color: _addressesMutedText,
                  fontSize: 16,
                  height: 1.55,
                ),
              ),
            ],
          );

          if (showSideIcon) {
            return Row(
              children: [
                Expanded(child: text),
                const SizedBox(width: 24),
                _buildLocationIcon(size: 92),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text,
              const SizedBox(height: 24),
              Center(child: _buildLocationIcon(size: compact ? 82 : 94)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocationIcon({required double size}) {
    return Transform.rotate(
      angle: math.pi / 15,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFE31B23),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          Icons.location_on_rounded,
          color: Colors.white,
          size: size * 0.54,
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Text(
            'Meus Locais',
            style: TextStyle(
              color: _addressesText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Flexible(
          child: Text(
            viewModel.registeredAddressesLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFFB90014),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressesContent() {
    if (viewModel.isLoading && viewModel.addresses.isEmpty) {
      return const _AddressesLoadingState();
    }

    if (viewModel.errorMessage != null && viewModel.addresses.isEmpty) {
      return _AddressesMessageState(
        icon: Icons.cloud_off_rounded,
        title: 'Não foi possível carregar',
        message: viewModel.errorMessage!,
        actionLabel: 'Tentar novamente',
        onAction: viewModel.loadAddresses,
      );
    }

    if (viewModel.addresses.isEmpty) {
      return _AddressesMessageState(
        icon: Icons.add_location_alt_rounded,
        title: 'Nenhum endereço cadastrado',
        message: 'Adicione um local de entrega para agilizar seus pedidos.',
        actionLabel: 'Adicionar endereço',
        onAction: () => _openAddressForm(),
      );
    }

    return Column(
      children: [
        for (final address in viewModel.addresses) ...[
          _AddressCard(
            address: address,
            isBusy: viewModel.isDeleting,
            onEdit: () => _openAddressForm(address: address),
            onDelete: () => _confirmDelete(address),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildMapCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 194,
        width: double.infinity,
        color: _addressesSurfaceLow,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _SoftMapPainter()),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.04),
                    _addressesScreenBackground.withOpacity(0.72),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 26,
              bottom: 20,
              right: 26,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.94),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'COBERTURA AMERICANA HEALTH',
                      style: TextStyle(
                        color: _addressesText,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAddressButton() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: SizedBox(
          height: 68,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: viewModel.isSaving ? null : () => _openAddressForm(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE30613),
              disabledBackgroundColor: const Color(0xFFE30613).withOpacity(0.45),
              foregroundColor: Colors.white,
              elevation: 18,
              shadowColor: const Color(0xFFE30613).withOpacity(0.32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 28),
            label: const Text(
              'Novo Endereço',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAddressForm({DeliveryAddress? address}) async {
    final result = await showModalBottomSheet<AddressActionResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return _AddressFormSheet(
            address: address,
            viewModel: viewModel,
          );
        },
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    _showInfo(result.message);
  }

  Future<void> _confirmDelete(DeliveryAddress address) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _addressesSurfaceWhite,
          title: const Text('Excluir endereço'),
          content: Text(
            'Deseja excluir "${address.title}" dos seus locais de entrega?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: _addressesErrorText,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final result = await viewModel.deleteAddress(address);
    if (!mounted) {
      return;
    }
    _showInfo(result.message);
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeClientScreen()),
        (route) => false,
      );
      return;
    }

    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FavoriteProductsScreen()),
      );
      return;
    }

    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OrdersScreen()),
      );
      return;
    }

    Navigator.of(context).maybePop();
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1400),
        ),
      );
  }
}

class _AddressFormSheet extends StatefulWidget {
  final DeliveryAddress? address;
  final AddressesViewModel viewModel;

  const _AddressFormSheet({
    required this.address,
    required this.viewModel,
  });

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _recipientController;
  late final TextEditingController _streetController;
  late final TextEditingController _numberController;
  late final TextEditingController _complementController;
  late final TextEditingController _neighborhoodController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipCodeController;
  late bool _isDefault;
  String? _lastSearchedZipCode;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _titleController = TextEditingController(text: address?.title ?? '');
    _recipientController = TextEditingController(text: address?.recipient ?? '');
    _streetController = TextEditingController(text: address?.street ?? '');
    _numberController = TextEditingController(text: address?.number ?? '');
    _complementController =
        TextEditingController(text: address?.complement ?? '');
    _neighborhoodController =
        TextEditingController(text: address?.neighborhood ?? '');
    _cityController = TextEditingController(text: address?.city ?? '');
    _stateController = TextEditingController(text: address?.state ?? '');
    _zipCodeController = TextEditingController(text: address?.zipCode ?? '');
    _latitude = address?.latitude;
    _longitude = address?.longitude;
    _isDefault = address?.isDefault ?? widget.viewModel.addresses.isEmpty;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _recipientController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxWidth = MediaQuery.of(context).size.width >= 700 ? 640.0 : double.infinity;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: _addressesScreenBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _addressesSurfaceHighest,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.address == null
                                  ? 'Novo Endereço'
                                  : 'Editar Endereço',
                              style: const TextStyle(
                                color: _addressesText,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _LocationButton(
                        isLoading: widget.viewModel.isUsingLocation,
                        onPressed: _useCurrentLocation,
                      ),
                      if (_latitude != null && _longitude != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Localização salva: ${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                          style: const TextStyle(
                            color: _addressesMutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      _AddressTextField(
                        controller: _titleController,
                        label: 'Nome do endereço',
                        icon: Icons.bookmark_rounded,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      _AddressTextField(
                        controller: _recipientController,
                        label: 'Destinatário',
                        icon: Icons.person_rounded,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      _AddressTextField(
                        controller: _zipCodeController,
                        label: 'CEP',
                        icon: Icons.local_post_office_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          const _CepInputFormatter(),
                        ],
                        textInputAction: TextInputAction.next,
                        onChanged: _onZipCodeChanged,
                        suffix: widget.viewModel.isSearchingZipCode
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFE30613),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _AddressTextField(
                        controller: _streetController,
                        label: 'Rua ou avenida',
                        icon: Icons.route_rounded,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 460;
                          final numberField = _AddressTextField(
                            controller: _numberController,
                            label: 'Número',
                            icon: Icons.numbers_rounded,
                            textInputAction: TextInputAction.next,
                          );
                          final complementField = _AddressTextField(
                            controller: _complementController,
                            label: 'Complemento',
                            icon: Icons.apartment_rounded,
                            isRequired: false,
                            textInputAction: TextInputAction.next,
                          );

                          if (compact) {
                            return Column(
                              children: [
                                numberField,
                                const SizedBox(height: 12),
                                complementField,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              SizedBox(width: 160, child: numberField),
                              const SizedBox(width: 12),
                              Expanded(child: complementField),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _AddressTextField(
                        controller: _neighborhoodController,
                        label: 'Bairro',
                        icon: Icons.location_city_rounded,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 460;
                          final cityField = _AddressTextField(
                            controller: _cityController,
                            label: 'Cidade',
                            icon: Icons.map_rounded,
                            textInputAction: TextInputAction.next,
                          );
                          final stateField = _AddressTextField(
                            controller: _stateController,
                            label: 'UF',
                            icon: Icons.flag_rounded,
                            maxLength: 2,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                          );

                          if (compact) {
                            return Column(
                              children: [
                                cityField,
                                const SizedBox(height: 12),
                                stateField,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: cityField),
                              const SizedBox(width: 12),
                              SizedBox(width: 118, child: stateField),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        value: _isDefault,
                        onChanged: (value) => setState(() => _isDefault = value),
                        contentPadding: EdgeInsets.zero,
                        activeColor: Pallete.primaryRed,
                        title: const Text(
                          'Usar como endereço padrão',
                          style: TextStyle(
                            color: _addressesText,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: widget.viewModel.isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE30613),
                            disabledBackgroundColor:
                                const Color(0xFFE30613).withOpacity(0.45),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: widget.viewModel.isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Salvar endereço',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    FocusScope.of(context).unfocus();
    final result = await widget.viewModel.useCurrentLocation();
    if (!mounted) {
      return;
    }

    final address = result.address;
    if (address != null) {
      setState(() {
        if (_titleController.text.trim().isEmpty) {
          _titleController.text = address.title;
        }
        _streetController.text = address.street;
        _numberController.text = address.number;
        _neighborhoodController.text = address.neighborhood;
        _cityController.text = address.city;
        _stateController.text = address.state;
        _zipCodeController.text = address.zipCode;
        _latitude = address.latitude;
        _longitude = address.longitude;
      });
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _onZipCodeChanged(String value) async {
    final cleanZipCode = value.replaceAll(RegExp(r'\D'), '');
    if (cleanZipCode.length != 8) {
      _lastSearchedZipCode = null;
      return;
    }
    if (cleanZipCode == _lastSearchedZipCode) {
      return;
    }

    _lastSearchedZipCode = cleanZipCode;
    final result = await widget.viewModel.searchZipCode(cleanZipCode);
    if (!mounted || result.message.isEmpty) {
      return;
    }

    final address = result.address;
    if (address != null) {
      setState(() {
        _zipCodeController.text = address.zipCode;
        _streetController.text = address.street;
        _neighborhoodController.text = address.neighborhood;
        _cityController.text = address.city;
        _stateController.text = address.state;
      });
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final original = widget.address;
    final address = DeliveryAddress(
      id: original?.id ?? 'new-address',
      userId: original?.userId,
      title: _titleController.text,
      recipient: _recipientController.text,
      street: _streetController.text,
      number: _numberController.text,
      complement: _complementController.text,
      neighborhood: _neighborhoodController.text,
      city: _cityController.text,
      state: _stateController.text,
      zipCode: _zipCodeController.text,
      latitude: _latitude,
      longitude: _longitude,
      isDefault: _isDefault,
    );

    final result = await widget.viewModel.saveAddress(address);
    if (!mounted) {
      return;
    }

    if (result.success) {
      Navigator.of(context).pop(result);
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result.message)));
  }
}

class _AddressTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isRequired;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  const _AddressTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isRequired = true,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLength,
    this.textCapitalization = TextCapitalization.sentences,
    this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      validator: (value) {
        if (!isRequired) {
          return null;
        }
        if (value == null || value.trim().isEmpty) {
          return 'Campo obrigatório';
        }
        if (label == 'CEP' && value.replaceAll(RegExp(r'\D'), '').length != 8) {
          return 'CEP inválido';
        }
        if (label == 'UF' && value.trim().length != 2) {
          return 'UF inválida';
        }
        return null;
      },
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: _addressesSurfaceWhite,
        prefixIcon: Icon(icon, color: Pallete.primaryRed, size: 20),
        suffixIcon: suffix,
        labelText: label,
        labelStyle: const TextStyle(color: _addressesMutedText),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _addressesSurfaceHigh),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE30613), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _addressesErrorText),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _addressesErrorText, width: 1.4),
        ),
      ),
    );
  }
}

class _LocationButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _LocationButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Pallete.primaryRed,
          side: const BorderSide(color: _addressesSurfaceHighest),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.my_location_rounded, size: 20),
        label: Text(
          isLoading ? 'Buscando localização...' : 'Usar minha localização atual',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final DeliveryAddress address;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      decoration: BoxDecoration(
        color: _addressesSurfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: _addressesSurfaceHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(address.icon, color: Pallete.primaryRed, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _addressesText,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Destinatário: ${address.recipient}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _addressesMutedText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (address.isDefault) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _addressesSoftBlue,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'PADRÃO',
                        style: TextStyle(
                          color: _addressesBlueText,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 22),
          Text(
            address.formattedLines,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _addressesMutedText,
              fontSize: 16,
              height: 1.62,
            ),
          ),
          if (address.latitude != null && address.longitude != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.my_location_rounded,
                  color: _addressesMutedText,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${address.latitude!.toStringAsFixed(5)}, ${address.longitude!.toStringAsFixed(5)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _addressesMutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          const Divider(height: 1, color: _addressesSurfaceLow),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextButton.icon(
                    onPressed: isBusy ? null : onEdit,
                    style: TextButton.styleFrom(
                      backgroundColor: _addressesSurfaceLow,
                      foregroundColor: _addressesText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text(
                      'Editar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  onPressed: isBusy ? null : onDelete,
                  style: IconButton.styleFrom(
                    backgroundColor: _addressesErrorContainer,
                    foregroundColor: _addressesErrorText,
                    disabledBackgroundColor: _addressesErrorContainer.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.delete_rounded, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressesLoadingState extends StatelessWidget {
  const _AddressesLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: _addressesSurfaceWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFFE30613)),
      ),
    );
  }
}

class _AddressesMessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _AddressesMessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      decoration: BoxDecoration(
        color: _addressesSurfaceWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, color: Pallete.primaryRed, size: 42),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _addressesText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _addressesMutedText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: onAction,
            style: OutlinedButton.styleFrom(
              foregroundColor: Pallete.primaryRed,
              side: const BorderSide(color: _addressesSurfaceHighest),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _AddressesBottomNavBar extends StatelessWidget {
  final ValueChanged<int> onTap;

  const _AddressesBottomNavBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _addressesScreenBackground.withOpacity(0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.home_rounded,
                  label: 'INÍCIO',
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.favorite_rounded,
                  label: 'FAVORITOS',
                  onTap: () => onTap(1),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'PEDIDOS',
                  onTap: () => onTap(2),
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.person_rounded,
                  label: 'PERFIL',
                  selected: true,
                  onTap: () => onTap(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _addressesErrorContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? Pallete.primaryRed : Pallete.textColor,
              size: 22,
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: selected ? Pallete.primaryRed : Pallete.textColor,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CepInputFormatter extends TextInputFormatter {
  const _CepInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;
    final buffer = StringBuffer();

    for (int i = 0; i < limited.length; i++) {
      if (i == 5) {
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

class _SoftMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFFE9E3E2);
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final minorPaint = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..strokeWidth = 0.8;
    final majorPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1.2;

    for (double x = -20; x < size.width + 30; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x + 18, size.height), minorPaint);
    }

    for (double y = 14; y < size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 8), minorPaint);
    }

    final roads = [
      [Offset(0, size.height * 0.42), Offset(size.width, size.height * 0.38)],
      [Offset(size.width * 0.3, 0), Offset(size.width * 0.33, size.height)],
      [Offset(size.width * 0.72, 0), Offset(size.width * 0.62, size.height)],
      [Offset(0, size.height * 0.73), Offset(size.width, size.height * 0.68)],
      [Offset(size.width * 0.12, 0), Offset(size.width * 0.5, size.height)],
      [Offset(size.width * 0.9, 0), Offset(size.width * 0.78, size.height)],
    ];

    for (final road in roads) {
      canvas.drawLine(road[0], road[1], majorPaint);
    }

    final blockPaint = Paint()..color = Colors.white.withOpacity(0.12);
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 6; col++) {
        final rect = Rect.fromLTWH(
          12 + col * 58,
          16 + row * 42,
          34 + (col.isEven ? 10 : 0),
          22,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          blockPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

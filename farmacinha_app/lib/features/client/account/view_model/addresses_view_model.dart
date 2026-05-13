import 'package:farmacia_app/features/client/account/data/models/delivery_address_model.dart';
import 'package:farmacia_app/features/client/account/data/repositories/address_location_repository.dart';
import 'package:farmacia_app/features/client/account/data/repositories/client_addresses_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressesViewModel extends ChangeNotifier {
  AddressesViewModel({
    ClientAddressesRepository? addressesRepository,
    AddressLocationRepository? locationRepository,
  })  : _addressesRepository =
            addressesRepository ?? ClientAddressesRepository.instance,
        _locationRepository =
            locationRepository ?? AddressLocationRepository.instance;

  final ClientAddressesRepository _addressesRepository;
  final AddressLocationRepository _locationRepository;

  final List<DeliveryAddress> _addresses = [];

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isUsingLocation = false;
  String? _errorMessage;

  List<DeliveryAddress> get addresses =>
      List<DeliveryAddress>.unmodifiable(_addresses);

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isDeleting => _isDeleting;
  bool get isUsingLocation => _isUsingLocation;
  String? get errorMessage => _errorMessage;

  String get registeredAddressesLabel {
    final count = _addresses.length;
    return '$count REGISTRADO${count == 1 ? '' : 'S'}';
  }

  Future<void> loadAddresses() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final addresses = await _addressesRepository.fetchCurrentUserAddresses();
      _addresses
        ..clear()
        ..addAll(addresses);
    } on PostgrestException catch (error) {
      _errorMessage = _formatPostgrestError(error);
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AddressActionResult> saveAddress(DeliveryAddress address) async {
    if (_isSaving) {
      return const AddressActionResult(message: 'Salvamento em andamento.');
    }

    final validationMessage = _validateAddress(address);
    if (validationMessage != null) {
      return AddressActionResult(message: validationMessage);
    }

    _isSaving = true;
    notifyListeners();

    try {
      await _addressesRepository.saveAddress(address);
      await loadAddresses();
      return AddressActionResult(
        message: address.id == 'new-address'
            ? 'Endereço cadastrado com sucesso!'
            : 'Endereço atualizado com sucesso!',
        success: true,
      );
    } on PostgrestException catch (error) {
      return AddressActionResult(message: _formatPostgrestError(error));
    } catch (error) {
      return AddressActionResult(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<AddressActionResult> deleteAddress(DeliveryAddress address) async {
    if (_isDeleting) {
      return const AddressActionResult(message: 'Exclusão em andamento.');
    }

    _isDeleting = true;
    notifyListeners();

    try {
      await _addressesRepository.deleteAddress(address.id);
      await loadAddresses();
      return const AddressActionResult(
        message: 'Endereço excluído com sucesso!',
        success: true,
      );
    } on PostgrestException catch (error) {
      return AddressActionResult(message: _formatPostgrestError(error));
    } catch (error) {
      return AddressActionResult(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  Future<AddressLocationResult> useCurrentLocation() async {
    if (_isUsingLocation) {
      return const AddressLocationResult(
        message: 'Localização em andamento.',
      );
    }

    _isUsingLocation = true;
    notifyListeners();

    try {
      final location = await _locationRepository.fetchCurrentLocationAddress();
      return AddressLocationResult(
        address: location.address,
        message: 'Localização encontrada. Confira os dados antes de salvar.',
        success: true,
      );
    } catch (error) {
      return AddressLocationResult(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      _isUsingLocation = false;
      notifyListeners();
    }
  }

  String? _validateAddress(DeliveryAddress address) {
    if (address.title.trim().isEmpty) {
      return 'Informe um nome para o endereço.';
    }
    if (address.recipient.trim().isEmpty) {
      return 'Informe o destinatário.';
    }
    if (address.street.trim().isEmpty) {
      return 'Informe a rua ou avenida.';
    }
    if (address.number.trim().isEmpty) {
      return 'Informe o número.';
    }
    if (address.neighborhood.trim().isEmpty) {
      return 'Informe o bairro.';
    }
    if (address.city.trim().isEmpty) {
      return 'Informe a cidade.';
    }
    if (address.state.trim().length != 2) {
      return 'Informe a UF com 2 letras.';
    }
    if (address.zipCode.replaceAll(RegExp(r'\D'), '').length != 8) {
      return 'Informe um CEP válido.';
    }
    return null;
  }

  String _formatPostgrestError(PostgrestException error) {
    final message = error.message.toLowerCase();
    if (message.contains('client_addresses') ||
        message.contains('does not exist') ||
        message.contains('schema cache')) {
      return 'A tabela de endereços ainda não foi criada no Supabase. Rode o SQL informado no final.';
    }
    if (message.contains('row-level security')) {
      return 'O Supabase bloqueou os endereços por RLS. Confira as policies da tabela client_addresses.';
    }
    return 'Não foi possível salvar no banco. Detalhe: ${error.message}';
  }
}

class AddressActionResult {
  final String message;
  final bool success;

  const AddressActionResult({
    required this.message,
    this.success = false,
  });
}

class AddressLocationResult {
  final DeliveryAddress? address;
  final String message;
  final bool success;

  const AddressLocationResult({
    this.address,
    required this.message,
    this.success = false,
  });
}

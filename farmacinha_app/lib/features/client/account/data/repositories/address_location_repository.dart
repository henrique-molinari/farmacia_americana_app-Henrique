import 'dart:convert';

import 'package:farmacia_app/features/client/account/data/models/delivery_address_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class AddressLocationRepository {
  AddressLocationRepository._();

  static final AddressLocationRepository instance = AddressLocationRepository._();

  Future<DeliveryAddressLocation> fetchCurrentLocationAddress() async {
    final permission = await _requestLocationPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Permita o acesso à localização para usar este recurso.');
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Ative a localização do dispositivo para continuar.');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final address = await _reverseGeocode(position);
    return DeliveryAddressLocation(position: position, address: address);
  }

  Future<LocationPermission> _requestLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  Future<DeliveryAddress> _reverseGeocode(Position position) async {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/reverse',
      {
        'format': 'jsonv2',
        'lat': position.latitude.toString(),
        'lon': position.longitude.toString(),
        'accept-language': 'pt-BR',
        'addressdetails': '1',
      },
    );

    final response = await http.get(
      uri,
      headers: const {
        'User-Agent': 'farmacia_app/1.0 contact:suporte@farmaciaamericana.local',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return _coordinateOnlyAddress(position);
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      return _coordinateOnlyAddress(position);
    }

    final address = Map<String, dynamic>.from(body['address'] ?? {});
    final road = _pick(address, ['road', 'pedestrian', 'residential', 'path']);
    final houseNumber = _pick(address, ['house_number']);
    final neighborhood = _pick(address, [
      'suburb',
      'neighbourhood',
      'city_district',
      'quarter',
    ]);
    final city = _pick(address, ['city', 'town', 'municipality', 'village']);
    final state = _stateInitials(_pick(address, ['state']));
    final zipCode = _pick(address, ['postcode']);

    return DeliveryAddress(
      id: 'new-address',
      title: 'Localização atual',
      recipient: '',
      street: road,
      number: houseNumber,
      neighborhood: neighborhood,
      city: city,
      state: state,
      zipCode: zipCode,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  DeliveryAddress _coordinateOnlyAddress(Position position) {
    return DeliveryAddress(
      id: 'new-address',
      title: 'Localização atual',
      recipient: '',
      street: '',
      number: '',
      neighborhood: '',
      city: '',
      state: '',
      zipCode: '',
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  String _pick(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  String _stateInitials(String stateName) {
    const states = {
      'acre': 'AC',
      'alagoas': 'AL',
      'amapá': 'AP',
      'amapa': 'AP',
      'amazonas': 'AM',
      'bahia': 'BA',
      'ceará': 'CE',
      'ceara': 'CE',
      'distrito federal': 'DF',
      'espírito santo': 'ES',
      'espirito santo': 'ES',
      'goiás': 'GO',
      'goias': 'GO',
      'maranhão': 'MA',
      'maranhao': 'MA',
      'mato grosso': 'MT',
      'mato grosso do sul': 'MS',
      'minas gerais': 'MG',
      'pará': 'PA',
      'para': 'PA',
      'paraíba': 'PB',
      'paraiba': 'PB',
      'paraná': 'PR',
      'parana': 'PR',
      'pernambuco': 'PE',
      'piauí': 'PI',
      'piaui': 'PI',
      'rio de janeiro': 'RJ',
      'rio grande do norte': 'RN',
      'rio grande do sul': 'RS',
      'rondônia': 'RO',
      'rondonia': 'RO',
      'roraima': 'RR',
      'santa catarina': 'SC',
      'são paulo': 'SP',
      'sao paulo': 'SP',
      'sergipe': 'SE',
      'tocantins': 'TO',
    };

    final normalized = stateName.trim().toLowerCase();
    if (normalized.length == 2) {
      return normalized.toUpperCase();
    }
    return states[normalized] ?? stateName;
  }
}

class DeliveryAddressLocation {
  final Position position;
  final DeliveryAddress address;

  const DeliveryAddressLocation({
    required this.position,
    required this.address,
  });
}

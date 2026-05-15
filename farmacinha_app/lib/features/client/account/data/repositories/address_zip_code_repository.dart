import 'dart:convert';

import 'package:farmacia_app/features/client/account/data/models/zip_code_address_model.dart';
import 'package:http/http.dart' as http;

class AddressZipCodeRepository {
  AddressZipCodeRepository._();

  static final AddressZipCodeRepository instance = AddressZipCodeRepository._();

  Future<ZipCodeAddress?> fetchAddressByZipCode(String zipCode) async {
    final cleanZipCode = zipCode.replaceAll(RegExp(r'\D'), '');
    if (cleanZipCode.length != 8) {
      return null;
    }

    final response = await http.get(
      Uri.parse('https://viacep.com.br/ws/$cleanZipCode/json/'),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Não foi possível consultar o CEP agora.');
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic> || body['erro'] == true) {
      return null;
    }

    return ZipCodeAddress.fromViaCepMap(body);
  }
}

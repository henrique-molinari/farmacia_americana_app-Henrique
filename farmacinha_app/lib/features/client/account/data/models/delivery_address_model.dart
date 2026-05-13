import 'package:flutter/material.dart';

class DeliveryAddress {
  final String id;
  final String? userId;
  final String title;
  final String recipient;
  final String street;
  final String number;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const DeliveryAddress({
    required this.id,
    this.userId,
    required this.title,
    required this.recipient,
    required this.street,
    required this.number,
    this.complement = '',
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  IconData get icon {
    final normalizedTitle = title.toLowerCase();
    if (normalizedTitle.contains('trabalho') ||
        normalizedTitle.contains('empresa')) {
      return Icons.work_rounded;
    }
    if (normalizedTitle.contains('casa') ||
        normalizedTitle.contains('lar')) {
      return Icons.home_rounded;
    }
    return Icons.location_on_rounded;
  }

  String get streetLine {
    final pieces = <String>[street];
    if (number.trim().isNotEmpty) {
      pieces.add(number.trim());
    }
    var line = pieces.where((piece) => piece.trim().isNotEmpty).join(', ');
    if (complement.trim().isNotEmpty) {
      line = '$line - ${complement.trim()}';
    }
    return line;
  }

  String get districtLine {
    final cityState = [
      city.trim(),
      state.trim(),
    ].where((piece) => piece.isNotEmpty).join(' - ');
    if (neighborhood.trim().isEmpty) {
      return cityState;
    }
    if (cityState.isEmpty) {
      return neighborhood.trim();
    }
    return '${neighborhood.trim()}, $cityState';
  }

  String get formattedLines =>
      '$streetLine\n$districtLine\nCEP: $zipCode';

  String get singleLineAddress => '$streetLine, $districtLine, CEP: $zipCode';

  DeliveryAddress copyWith({
    String? id,
    String? userId,
    String? title,
    String? recipient,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    String? zipCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      recipient: recipient ?? this.recipient,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory DeliveryAddress.fromSupabaseMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString(),
      title: map['title']?.toString() ?? '',
      recipient: map['recipient']?.toString() ?? '',
      street: map['street']?.toString() ?? '',
      number: map['number']?.toString() ?? '',
      complement: map['complement']?.toString() ?? '',
      neighborhood: map['neighborhood']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      state: map['state']?.toString() ?? '',
      zipCode: map['zip_code']?.toString() ?? '',
      latitude: _parseDouble(map['latitude']),
      longitude: _parseDouble(map['longitude']),
      isDefault: map['is_default'] == true,
    );
  }

  Map<String, dynamic> toSupabaseMap({required String userId}) {
    return {
      'user_id': userId,
      'title': title.trim(),
      'recipient': recipient.trim(),
      'street': street.trim(),
      'number': number.trim(),
      'complement': complement.trim().isEmpty ? null : complement.trim(),
      'neighborhood': neighborhood.trim(),
      'city': city.trim(),
      'state': state.trim().toUpperCase(),
      'zip_code': zipCode.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }
}

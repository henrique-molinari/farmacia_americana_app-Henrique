class ZipCodeAddress {
  final String zipCode;
  final String street;
  final String neighborhood;
  final String city;
  final String state;

  const ZipCodeAddress({
    required this.zipCode,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  factory ZipCodeAddress.fromViaCepMap(Map<String, dynamic> map) {
    return ZipCodeAddress(
      zipCode: map['cep']?.toString() ?? '',
      street: map['logradouro']?.toString() ?? '',
      neighborhood: map['bairro']?.toString() ?? '',
      city: map['localidade']?.toString() ?? '',
      state: map['uf']?.toString() ?? '',
    );
  }
}

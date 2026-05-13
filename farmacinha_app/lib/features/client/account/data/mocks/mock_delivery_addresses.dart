import 'package:farmacia_app/features/client/account/data/models/delivery_address_model.dart';

class MockDeliveryAddresses {
  static List<DeliveryAddress> getAddresses() {
    return const [
      DeliveryAddress(
        id: 'home-main',
        title: 'Minha Casa',
        recipient: 'Ricardo Oliveira',
        street: 'Avenida Paulista',
        number: '1578',
        complement: 'Apto 42',
        neighborhood: 'Bela Vista',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01310-200',
        isDefault: true,
      ),
      DeliveryAddress(
        id: 'work',
        title: 'Trabalho',
        recipient: 'Ricardo Oliveira',
        street: 'Rua das Olimpíadas',
        number: '205',
        complement: '12º andar',
        neighborhood: 'Vila Olímpia',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '04551-000',
      ),
    ];
  }
}

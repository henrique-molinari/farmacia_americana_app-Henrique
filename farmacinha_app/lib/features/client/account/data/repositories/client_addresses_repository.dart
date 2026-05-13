import 'package:farmacia_app/features/client/account/data/models/delivery_address_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientAddressesRepository {
  ClientAddressesRepository._();

  static final ClientAddressesRepository instance = ClientAddressesRepository._();

  static const String _table = 'client_addresses';

  SupabaseClient get _client => Supabase.instance.client;

  Future<List<DeliveryAddress>> fetchCurrentUserAddresses() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      return [];
    }

    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', authUser.id)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);

    return response
        .map<DeliveryAddress>(
          (address) => DeliveryAddress.fromSupabaseMap(
            Map<String, dynamic>.from(address),
          ),
        )
        .toList(growable: false);
  }

  Future<DeliveryAddress> saveAddress(DeliveryAddress address) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('Entre com sua conta para salvar endereços.');
    }

    if (address.isDefault) {
      await _clearCurrentDefault(authUser.id);
    }

    final payload = address.toSupabaseMap(userId: authUser.id);
    final hasDatabaseId = address.id.trim().isNotEmpty &&
        address.id != 'new-address';

    final response = hasDatabaseId
        ? await _client
            .from(_table)
            .update(payload)
            .eq('id', address.id)
            .eq('user_id', authUser.id)
            .select()
            .single()
        : await _client
            .from(_table)
            .insert(payload)
            .select()
            .single();

    final savedAddress = DeliveryAddress.fromSupabaseMap(
      Map<String, dynamic>.from(response),
    );

    if (!savedAddress.isDefault) {
      await _ensureUserHasDefaultAddress(authUser.id, savedAddress.id);
    }

    return savedAddress;
  }

  Future<void> deleteAddress(String addressId) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('Entre com sua conta para excluir endereços.');
    }

    await _client
        .from(_table)
        .delete()
        .eq('id', addressId)
        .eq('user_id', authUser.id);

    await _promoteLatestAddressAsDefault(authUser.id);
  }

  Future<void> _clearCurrentDefault(String userId) async {
    await _client
        .from(_table)
        .update({'is_default': false})
        .eq('user_id', userId)
        .eq('is_default', true);
  }

  Future<void> _ensureUserHasDefaultAddress(
    String userId,
    String savedAddressId,
  ) async {
    final currentDefault = await _client
        .from(_table)
        .select('id')
        .eq('user_id', userId)
        .eq('is_default', true)
        .maybeSingle();

    if (currentDefault == null) {
      await _client
          .from(_table)
          .update({'is_default': true})
          .eq('id', savedAddressId)
          .eq('user_id', userId);
    }
  }

  Future<void> _promoteLatestAddressAsDefault(String userId) async {
    final currentDefault = await _client
        .from(_table)
        .select('id')
        .eq('user_id', userId)
        .eq('is_default', true)
        .maybeSingle();

    if (currentDefault != null) {
      return;
    }

    final latestAddress = await _client
        .from(_table)
        .select('id')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    final latestAddressId = latestAddress?['id']?.toString();
    if (latestAddressId == null || latestAddressId.isEmpty) {
      return;
    }

    await _client
        .from(_table)
        .update({'is_default': true})
        .eq('id', latestAddressId)
        .eq('user_id', userId);
  }
}

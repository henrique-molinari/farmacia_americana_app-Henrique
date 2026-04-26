import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Todos';

  final List<String> _statusFilters = [
    'Todos',
    'ENVIADO',
    'PROCESSANDO',
    'PENDENTE',
  ];

  final List<Map<String, String>> _orders = [
    {'id': '#CK-9281', 'client': 'Ricardo Oliveira', 'status': 'ENVIADO', 'value': 'R\$ 452,00', 'date': 'Hoje, 10:30'},
    {'id': '#CK-9280', 'client': 'Ana Julia Santos', 'status': 'PROCESSANDO', 'value': 'R\$ 129,90', 'date': 'Hoje, 09:15'},
    {'id': '#CK-9279', 'client': 'Marcos Pereira', 'status': 'PENDENTE', 'value': 'R\$ 78,50', 'date': 'Hoje, 08:40'},
    {'id': '#CK-9278', 'client': 'Fernanda Lima', 'status': 'ENVIADO', 'value': 'R\$ 234,00', 'date': 'Ontem, 17:20'},
    {'id': '#CK-9277', 'client': 'Carlos Eduardo', 'status': 'ENVIADO', 'value': 'R\$ 89,90', 'date': 'Ontem, 15:05'},
    {'id': '#CK-9276', 'client': 'Juliana Martins', 'status': 'PROCESSANDO', 'value': 'R\$ 312,50', 'date': 'Ontem, 12:30'},
    {'id': '#CK-9275', 'client': 'Roberto Silva', 'status': 'PENDENTE', 'value': 'R\$ 56,00', 'date': 'Ontem, 09:00'},
    {'id': '#CK-9274', 'client': 'Patricia Souza', 'status': 'ENVIADO', 'value': 'R\$ 178,00', 'date': '20/01, 14:45'},
    {'id': '#CK-9273', 'client': 'Lucas Ferreira', 'status': 'ENVIADO', 'value': 'R\$ 95,50', 'date': '20/01, 11:20'},
    {'id': '#CK-9272', 'client': 'Amanda Costa', 'status': 'PENDENTE', 'value': 'R\$ 43,00', 'date': '19/01, 16:10'},
  ];

  List<Map<String, String>> get _filteredOrders {
    return _orders.where((order) {
      final matchesSearch = order['id']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order['client']!.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == 'Todos' || order['status'] == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ENVIADO': return const Color(0xFF10B981);
      case 'PROCESSANDO': return const Color(0xFFFAC000);
      default: return const Color(0xFF64748B);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Pallete.whiteColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Histórico de Pedidos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Pallete.borderColor),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                // Campo de busca
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar ID ou Cliente...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Pallete.textColor.withOpacity(0.6),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Pallete.textColor,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Pallete.whiteColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Pallete.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Pallete.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Pallete.primaryRed,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),

                const SizedBox(height: 12),

                // Filtros de status
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _statusFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final status = _statusFilters[index];
                      final isSelected = status == _selectedStatus;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedStatus = status),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Pallete.primaryRed
                                : Pallete.whiteColor,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: isSelected
                                  ? Pallete.primaryRed
                                  : Pallete.borderColor,
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Pallete.whiteColor
                                  : Pallete.textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Contagem
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${orders.length} pedidos',
                style: const TextStyle(fontSize: 13, color: Pallete.textColor),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Lista de pedidos
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum pedido encontrado',
                      style: TextStyle(
                        fontSize: 14,
                        color: Pallete.textColor.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final statusColor = _statusColor(order['status']!);

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Pallete.whiteColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Pallete.borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // ID, cliente e data
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['id']!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Pallete.primaryRed,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  order['client']!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  order['date']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Pallete.textColor.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),

                            // Status e valor
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    order['status']!,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order['value']!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
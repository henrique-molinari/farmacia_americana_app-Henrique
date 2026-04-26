import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';

class SettingsBottomSheet extends StatefulWidget {
  const SettingsBottomSheet({super.key});

  // Método estático para abrir o BottomSheet facilmente em qualquer tela
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsBottomSheet(),
    );
  }

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  // Valor atual do alerta de estoque
  int _stockThreshold = 10;

  // Estado do botão de sincronização
  bool _isSyncing = false;
  String _lastSync = 'Hoje, 10:45';

  // Simula a sincronização de dados
  Future<void> _syncData() async {
    setState(() => _isSyncing = true);

    // Simula um delay de carregamento
    await Future.delayed(const Duration(seconds: 2));

    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    setState(() {
      _isSyncing = false;
      _lastSync = '${now.day.toString().padLeft(2, '0')}/'
      '${now.month.toString().padLeft(2, '0')}/'
      '${now.year} às $hour:$minute';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Dados atualizados com sucesso!',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de arrasto
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Pallete.borderColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),

          const SizedBox(height: 16),

          // Cabeçalho
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Configurações',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Alerta de Estoque ───────────────────────────────────────
          _buildSection(
            icon: Icons.inventory_2_outlined,
            iconColor: Pallete.accentYellow,
            title: 'Alerta de Estoque',
            subtitle: 'Notificar quando abaixo de $_stockThreshold unidades',
            child: Row(
              children: [
                // Botão diminuir
                _buildThresholdButton(
                  icon: Icons.remove,
                  onTap: () {
                    if (_stockThreshold > 1) {
                      setState(() => _stockThreshold--);
                    }
                  },
                ),

                const SizedBox(width: 16),

                // Valor atual
                Text(
                  '$_stockThreshold',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(width: 16),

                // Botão aumentar
                _buildThresholdButton(
                  icon: Icons.add,
                  onTap: () {
                    if (_stockThreshold < 50) {
                      setState(() => _stockThreshold++);
                    }
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Pallete.borderColor, indent: 20, endIndent: 20),

          // ── Atualizar Dados ─────────────────────────────────────────
          _buildSection(
            icon: Icons.sync_rounded,
            iconColor: const Color(0xFF0079B9),
            title: 'Atualizar Dados',
            subtitle: 'Última sync: $_lastSync',
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _syncData,
                icon: _isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Pallete.whiteColor,
                        ),
                      )
                    : const Icon(Icons.sync_rounded, size: 18),
                label: Text(
                  _isSyncing ? 'Sincronizando...' : 'Sincronizar Agora',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0079B9),
                  foregroundColor: Pallete.whiteColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),

          const Divider(height: 1, color: Pallete.borderColor, indent: 20, endIndent: 20),

          // ── Suporte ─────────────────────────────────────────────────
          _buildSection(
            icon: Icons.support_agent_rounded,
            iconColor: const Color(0xFF10B981),
            title: 'Suporte',
            subtitle: 'Entre em contato com nossa equipe',
            child: Column(
              children: [
                _buildContactRow(
                  icon: Icons.phone_outlined,
                  value: '(35) 99999-9999',
                ),
                const SizedBox(height: 8),
                _buildContactRow(
                  icon: Icons.email_outlined,
                  value: 'suporte@americana.com',
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Pallete.borderColor, indent: 20, endIndent: 20),

          // ── Versão do App ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Pallete.grayColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_android_rounded,
                    color: Pallete.textColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Versão do App',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Pallete.textColor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  // Seção genérica com ícone, título, subtítulo e conteúdo
  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Pallete.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // Botão de incremento/decremento do alerta de estoque
  Widget _buildThresholdButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Pallete.primaryRed.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Pallete.primaryRed, size: 18),
      ),
    );
  }

  // Linha de contato (telefone ou e-mail)
  Widget _buildContactRow({
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Pallete.textColor),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
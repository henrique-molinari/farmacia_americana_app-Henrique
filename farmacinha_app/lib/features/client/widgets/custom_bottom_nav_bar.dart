import 'package:flutter/material.dart';
import 'package:farmacia_app/core/palette/pallete.dart';

/// Um widget customizado de navegação inferior para o fluxo do cliente.
/// Seguindo a POO, ele é um Stateless porque apenas exibe dados e repassa eventos.
class CustomBottomNavBar extends StatelessWidget {
  /// O índice da aba que está selecionada no momento (0 a 3).
  final int currentIndex;
  
  /// Função de callback disparada quando o usuário toca em um ícone.
  /// Isso permite que a tela pai decida para onde navegar.
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      // Define qual ícone aparecerá como "aceso" (selecionado)
      currentIndex: currentIndex,
      
      // Repassa o índice clicado para a função que recebemos no construtor
      onTap: onTap,
      
      // 'fixed' garante que os ícones fiquem parados e as labels (textos) sempre apareçam
      type: BottomNavigationBarType.fixed,
      
      backgroundColor: Pallete.whiteColor,
      
      // Adiciona uma leve sombra acima da barra para separá-la do conteúdo (body)
      elevation: 8,
      
      // Cor do ícone e do texto quando a aba está ativa
      selectedItemColor: Pallete.primaryRed,
      
      // Cor do ícone e do texto quando a aba NÃO está ativa
      unselectedItemColor: Pallete.textColor,
      
      // Estilo do texto da aba selecionada
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 10,
      ),

      // Lista de itens (botões) da barra. Removido o item 'Buscar' para evitar duplicidade.
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),    // Ícone de linha (vazado) para estado inativo
          activeIcon: Icon(Icons.home_rounded), // Ícone preenchido para estado ativo
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          activeIcon: Icon(Icons.chat_bubble_rounded),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          activeIcon: Icon(Icons.shopping_cart_rounded),
          label: 'Carrinho',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Conta',
        ),
      ],
    );
  }
}

# Definição do MVP
**Ecossistema Farmácia Americana — App Flutter/Dart**

---

## 1. Escopo do MVP (Minimum Viable Product)

O MVP do ecossistema Farmácia Americana cobre o ciclo operacional fim-a-fim: desde a descoberta do produto via catálogo ou chat assistido, até a entrega final e auditoria regulatória. O foco central é a **Venda Híbrida** (Autónoma e Assistida), garantindo que a farmácia opere digitalmente com a mesma segurança e rigor técnico do balcão físico.

### **Dentro do MVP (Funcionalidades Essenciais):**

* **Acesso e Identidade (UC10, UC11, UC14):**
    * Autenticação segura via JWT com expiração diferenciada (8h para equipa / 24h para clientes).
    * Gestão de perfis (RBAC) com quatro níveis: Cliente, Atendente, Farmacêutico e Gerente/Dono.
    * Edição de dados pessoais e palavra-passe pelo cliente ("Minha Conta").
* **Operação Comercial e Catálogo (UC01, UC03, UC15):**
    * Navegação por categorias e busca por texto com interface Material Design 3 (60 FPS).
    * Fluxo de compra "Comprar Agora" (direto) ou via Carrinho (múltiplos itens).
    * Consulta de stock em tempo real com bloqueio de checkout para saldo insuficiente.
* **Atendimento e IA (UC01, UC04, UC13):**
    * Atendimento via Chat Híbrido: Árvore de decisão automatizada com transbordo para humano.
    * Cadastro de produtos com **Assistente de IA** para geração automática de descrições e posologias.
* **Fluxo Regulatório e Auditoria (UC05, UC06):**
    * Upload de receita médica pelo chat para medicamentos controlados.
    * Painel do Farmacêutico para validação manual de receitas e inserção de dados do prescritor.
    * Persistência imutável de logs de chat, imagens de receitas e dados de venda para auditoria (encriptação AES-256).
* **Financeiro e Logística (UC07, UC08, UC12, UC16):**
    * Pagamento via PIX Remoto (com timer de expiração de 10 min) e Pagamento na Entrega.
    * Rastreamento de pedidos com linha do tempo visual e notificações Push para cada mudança de estado.
    * Configuração da unidade pelo Gerente (Raio de entrega, horários e métodos de pagamento).
* **Gestão e Performance (UC02, UC09):**
    * **BI Mobile:** Consulta de performance (Dia/Semana/Mês) simplificada diretamente na AppBar para gestores.
    * Consulta de histórico do cliente (logs de chat e pedidos anteriores) para suporte do atendente.

### **Fora do MVP (Melhorias Futuras):**

* OCR automático de receitas (leitura por IA de letra de médico).
* Programa de fidelidade com acumulação de pontos/cashback.
* Lembretes automáticos de reposição de medicamentos de uso contínuo.
* Base de conhecimento da IA configurável por interface (Prompt Engineering UI).
* Dashboards de BI avançados com gráficos comparativos entre múltiplas unidades e previsões de procura.
* Integração direta com sistemas de seguros de saúde para autorização online.

---

## 2. Justificativa Estratégica

O foco deste MVP foi garantir a **viabilidade regulatória e operacional**. Diferente de um e-commerce comum, uma farmácia exige a figura do farmacêutico e a retenção de dados de auditoria (conforme as normas da ANVISA). Portanto, a validação de receitas e o log de auditoria foram priorizados em detrimento de recursos de marketing (como fidelidade ou IA preditiva).

A inclusão da **IA no cadastro de produtos** e no **atendimento inicial** justifica-se como o diferencial competitivo do produto: reduz o trabalho manual da farmácia e acelera o atendimento ao cliente. A delimitação de um **BI Mobile simplificado na AppBar** permite que o responsável pela farmácia monitorize o negócio em tempo real sem a complexidade de ferramentas externas, mantendo a operação ágil e centralizada no App Flutter.


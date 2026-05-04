# Regras de Negócio (RN) — Ecossistema Farmácia Americana 

Este documento define as diretrizes lógicas e as restrições operacionais que governam o comportamento do ecossistema Farmácia Americana (App Flutter + Backend).

---

## 1. Fluxo de Atendimento e Inteligência Artificial (ChatBot e IA) 

**RN01 — Navegação por Árvore de Decisão ** O atendimento inicial deve ser conduzido através de um menu de opções (botões), onde o usuário seleciona o fluxo desejado (ex: Comprar, Enviar Receita, Falar com Atendente). Não haverá processamento de texto livre nesta etapa. 

**RN02 — Transbordo para Atendimento Humano ** Caso o usuário selecione a opção de "Falar com Atendente" ou finalize um fluxo de seleção que exija intervenção (como validação de receita), a conversa deve ser encaminhada para a fila do colaborador responsável. 

**RN03 — Assistente de Cadastro (IA Generativa)** Exclusivo para a tela de Atendente/Gerente: ao cadastrar um novo item, o sistema disponibiliza uma ferramenta de IA que gera automaticamente o campo de "Descrição" e sugere "Tags/Categorias" com base no nome do produto, visando a celeridade do processo operacional. 

---

## 2. Gestão de Medicamentos e Saúde 

**RN04 — Validação Humana de Receitas** Medicamentos que exigem retenção de receita só terão sua venda autorizada após o Atendente/Farmacêutico visualizar a imagem enviada pelo cliente e validar manualmente os dados no painel administrativo. 

**RN05 — Persistência de Dados Críticos (API/BD)** Para cada venda realizada, o sistema deve obrigatoriamente persistir via API no Banco de Dados os seguintes dados:
* Identificação do(s) Produto(s);
* CPF do comprador;
* Data e hora exata da venda;
* Imagem da receita médica (se aplicável);
* CRM do Farmacêutico responsável pela validação;
* UF e CRM do Médico prescritor;
* Log completo do chat contendo toda a conversa da venda.

**RN06 — Registro Obrigatório de Prescritor** Toda venda de medicamento que exige retenção ou validação de receita deve conter o registro obrigatório do número do CRM e a Unidade Federativa (UF) do médico que emitiu a prescrição.

---

## 3. Vendas, Estoque e Checkout 

**RN07 — Disponibilidade em Tempo Real** O sistema não deve permitir a inclusão de itens no carrinho ou a finalização da compra se a quantidade solicitada for maior que o saldo em estoque físico da unidade selecionada.

**RN08 — Expiração de Chave PIX** As chaves PIX dinâmicas geradas para pagamento remoto devem expirar em exatamente **10 minutos**. Após este prazo, o pedido deve ser cancelado automaticamente e os itens devem retornar ao saldo de estoque disponível.

**RN09 — Pagamento Híbrido e Baixa Financeira** Pagamentos via PIX são validados automaticamente via Webhook bancário. Pagamentos em espécie ou cartão na entrega dependem obrigatoriamente da baixa manual do entregador via App para conclusão do fluxo.

**RN10 — Imutabilidade do Preço de Venda** O sistema deve registrar e manter o preço do produto praticado no momento exato da finalização da venda, garantindo que alterações posteriores no cadastro de produtos não afetem pedidos já concluídos.

---

## 4. Gestão de Acessos e Logística 

**RN11 — Hierarquia de Dados Financeiros (RBAC)** * **Dono:** Visualiza faturamento e indicadores de desempenho de todas as unidades.
* **Gerente:** Visualiza dados financeiros e relatórios apenas de sua unidade de lotação.
* **Demais Perfis:** Têm acesso restrito apenas às funcionalidades operacionais de sua alçada, sem acesso a dados de lucro ou faturamento global.

**RN12 — Restrição por Raio de Entrega** O sistema só deve permitir a finalização de pedidos para endereços localizados dentro do raio de entrega (quilometragem) configurado para a unidade da Farmácia Americana responsável pelo atendimento.

**RN13 — Notificação Automática de Status** O sistema deve disparar notificações Push em tempo real ao cliente a cada mudança de estado do pedido (ex: Pagamento Aprovado, Em Separação, Saiu para Entrega).

---

> **Diretriz de Implementação:** Estas regras devem ser validadas tanto na camada de interface (Flutter) para melhor UX, quanto na camada de serviços (Backend) para garantir a integridade dos dados.

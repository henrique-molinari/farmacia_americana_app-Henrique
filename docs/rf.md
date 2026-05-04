# Requisitos Funcionais (RF) — Ecossistema Farmácia Americana

Este documento detalha as funcionalidades que o sistema deve oferecer para atender aos usuários e às regras de negócio estabelecidas.

---

## 1. Módulo do Cliente (Interface Mobile Flutter)

**RF01 — Cadastro e Autenticação de Usuário**  
O sistema deve permitir que o cliente realize cadastro, login e logout utilizando e-mail e senha.

**RF02 — Catálogo de Produtos e Busca**  
O sistema deve exibir produtos com fotos, descrições e preços, permitindo a navegação por categorias e a busca por texto.

**RF03 — Atendimento Automatizado por Opções**  
O sistema deve prover uma interface de chat nativa onde o cliente interage com fluxos automatizados por opções para tirar dúvidas, buscar orientações e avançar no atendimento.

**RF04 — Transbordo de Atendimento**  
O sistema deve permitir que o cliente solicite ou seja transferido automaticamente para um atendente humano caso as opções do sistema não resolvam a demanda.

**RF05 — Seleção de Produtos via Chat**  
O sistema deve permitir que o cliente selecione produtos e siga fluxos de atendimento diretamente pela interface de conversa, sem depender apenas da navegação manual pelo catálogo.

**RF06 — Envio de Arquivos no Chat**  
O sistema deve permitir o envio de imagens e documentos diretamente no chat para complementar o atendimento.

**RF07 — Checkout e Pagamento por Pix**  
O sistema deve permitir a finalização da compra com opção de pagamento por Pix.

**RF08 — Seleção de Pagamento Presencial**  
O sistema deve permitir que o cliente opte pelo pagamento em dinheiro ou cartão no momento da entrega ou retirada, conforme o fluxo disponível.

**RF09 — Rastreamento de Pedido**  
O sistema deve exibir o status do pedido e o histórico de atualizações.

**RF10 — Gestão de Perfil e Histórico**  
O sistema deve permitir que o cliente visualize compras anteriores e realize a alteração de seus dados cadastrais.

---

## 2. Módulo de Atendimento (Atendente e Farmacêutico)

**RF11 — Gestão de Fila de Conversas**  
O sistema deve listar os chats ativos em um painel administrativo, permitindo a organização do atendimento por sistema ou humano.

**RF12 — Visualização de Histórico do Cliente**  
O sistema deve permitir a busca de clientes por dados como nome ou CPF para apoiar o atendimento.

**RF13 — Validação Técnica de Receita**  
O sistema deve fornecer uma tela para o farmacêutico visualizar a imagem da receita enviada e permitir aprovar ou reprovar a continuidade da venda.

**RF14 — Edição de Catálogo e Estoque**  
O sistema deve permitir que usuários autorizados realizem cadastro, edição de produtos e atualização do estoque.

**RF15 — Registro de Dados de Venda**  
O sistema deve persistir os dados essenciais do pedido e da venda no banco de dados.

---

## 3. Módulo de Gestão (Gerente e Dono)

**RF16 — Geração de Relatórios de Vendas**  
O sistema deve permitir a visualização de dados de faturamento, pedidos e produtos mais vendidos.

**RF17 — Dashboards de Indicadores (BI)**  
O sistema deve exibir gráficos de ticket médio e taxa de recorrência de clientes.

**RF18 — Configuração de Logística**  
O sistema deve permitir configurar regras básicas de entrega por unidade, conforme a necessidade do negócio.

 

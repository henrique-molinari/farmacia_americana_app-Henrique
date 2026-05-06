# Escopo do MVP — Farmácia Americana App

Este documento define o **escopo realista do MVP** do projeto **Farmácia Americana App**, consolidando o que deve ser entregue na primeira versão utilizável do produto.

O objetivo deste MVP não é contemplar toda a visão de longo prazo do ecossistema, mas sim entregar um produto funcional, coerente com o negócio e suficiente para validar a proposta principal da aplicação junto aos usuários e à operação interna.

---

## 1. Objetivo do MVP

O MVP deve validar a capacidade do produto de:

- oferecer um canal digital próprio para atendimento e compra;
- organizar o atendimento ao cliente com fluxo automatizado por opções;
- permitir transbordo para atendimento humano quando necessário;
- disponibilizar catálogo, carrinho, checkout e acompanhamento de pedidos;
- apoiar a operação interna com gestão básica de conversas, produtos, estoque e indicadores.

Em termos práticos, o MVP precisa comprovar que o app consegue sustentar o **fluxo central do negócio**:

**cliente entra no app → encontra produtos → recebe atendimento → monta pedido → finaliza compra → acompanha o pedido → operação interna acompanha e gerencia o processo**

---

## 2. Proposta do MVP

O MVP do **Farmácia Americana App** deve entregar uma experiência inicial de atendimento e compra digital estruturada, com foco em simplicidade operacional e validação de uso real.

A proposta do MVP é concentrar as funcionalidades indispensáveis para:

- entrada e autenticação de usuários;
- navegação no catálogo e busca de produtos;
- atendimento via chat por opções;
- transbordo para humano;
- montagem e confirmação de pedidos;
- consulta de pedidos e histórico;
- apoio operacional para atendentes e gestores.

---

## 3. Escopo Funcional do MVP

## 3.1 Dentro do MVP

### Acesso e conta
- Cadastro de usuários com nome, e-mail e senha
- Login e logout
- Direcionamento por perfil de acesso
- Edição de dados pessoais
- Alteração de senha

### Catálogo e descoberta
- Listagem de produtos ativos
- Navegação por categorias
- Busca por produtos
- Visualização de detalhes do produto

### Atendimento pelo chat
- Chat nativo com fluxo automatizado por opções
- Navegação por menus e categorias no atendimento
- Solicitação manual de atendimento humano
- Transbordo do fluxo automatizado para atendimento humano
- Registro de recados e solicitação de retorno
- Envio de imagens e documentos no chat

### Carrinho e checkout
- Adição de produtos ao carrinho
- Alteração de quantidade e remoção de itens
- Escolha entre entrega e retirada
- Escolha de forma de pagamento
- Checkout com confirmação do pedido
- Suporte a Pix, dinheiro e cartão na entrega

### Pedidos e acompanhamento
- Listagem de pedidos do usuário
- Visualização de detalhes do pedido
- Visualização de histórico de compras
- Acompanhamento básico do pedido

### Painel de atendimento
- Listagem de conversas
- Busca de cliente por nome ou CPF
- Acesso ao detalhe da conversa
- Continuidade do atendimento humano

### Gestão de produtos e estoque
- Cadastro de produto
- Edição de produto
- Atualização de estoque
- Pesquisa e filtro de produtos
- Destaque de baixo estoque

### Indicadores gerenciais
- Visualização de faturamento por período
- Visualização de gráficos de vendas
- Visualização de produtos mais vendidos
- Visão consolidada de operação

---

## 3.2 Fora do MVP

As funcionalidades abaixo **não fazem parte do MVP** e devem ser tratadas como evolução futura:

- atendimento por IA generativa no chat
- interpretação automática de intenções com linguagem natural
- OCR de receitas ou documentos
- leitura automatizada de receita médica
- auditoria técnica de respostas de IA
- configuração de base de conhecimento de IA
- motor preditivo de recomendação
- lembretes automáticos de recompra
- automações avançadas de comunicação com o cliente
- módulo robusto de administração de permissões com gestão completa de colaboradores
- regras avançadas de logística por geolocalização
- notificações push plenamente integradas com redirecionamento inteligente
- mecanismos offline sofisticados de sincronização de mensagens

---

## 4. Justificativa do Escopo

O MVP foi delimitado para preservar o que realmente representa valor imediato para o negócio sem inflar a primeira entrega com funcionalidades complexas, caras ou ainda pouco aderentes ao estado atual do projeto.

A decisão de escopo prioriza:

- **validação do canal digital** da farmácia;
- **redução de atrito no atendimento**;
- **digitalização do fluxo de compra**;
- **apoio à operação interna**;
- **base técnica sustentável para evolução futura**.

Também foram removidos do MVP elementos que apareciam em versões antigas da documentação, mas que já não representam a direção atual do projeto, como dependência de IA no chat, OCR e módulos especializados de auditoria da IA.

---

## 5. Regras de Negócio do MVP

### RN01 — Direcionamento por perfil
Após autenticação, o usuário deve ser direcionado à área correspondente ao seu perfil de acesso.

### RN02 — Atendimento por opções com continuidade
O chat deve conduzir o cliente por fluxos estruturados, preservando o histórico da conversa ao longo do atendimento.

### RN03 — Transbordo para humano
O cliente deve poder solicitar atendimento humano dentro do fluxo de chat sempre que necessário.

### RN04 — Persistência da conversa
As mensagens e anexos enviados no chat devem permanecer vinculados à conversa em andamento.

### RN05 — Controle de carrinho
O sistema deve permitir atualização consistente de itens, quantidades e totais no carrinho.

### RN06 — Fechamento do pedido
A confirmação do checkout deve gerar um pedido persistido com itens, forma de pagamento e forma de recebimento.

### RN07 — Histórico vinculado ao usuário
Pedidos e histórico de compras devem ser acessíveis apenas ao usuário autenticado ao qual pertencem.

### RN08 — Controle de estoque
Produtos cadastrados devem possuir quantidade em estoque passível de consulta e atualização pela operação.

### RN09 — Separação de áreas por perfil
As áreas de cliente, atendimento e gestão devem permanecer separadas conforme o perfil ativo.

### RN10 — Indicadores baseados em pedidos
Os dados de BI e visão gerencial devem ser calculados a partir dos pedidos registrados no sistema.

---

## 6. Requisitos Funcionais do MVP

### RF01 — Cadastro e autenticação de usuários
O sistema deve permitir cadastro, login e logout de usuários por e-mail e senha.

### RF02 — Direcionamento por perfil de acesso
O sistema deve direcionar o usuário autenticado para áreas compatíveis com seu perfil.

### RF03 — Catálogo de produtos e busca
O sistema deve exibir produtos ativos com busca e navegação por categorias.

### RF04 — Visualização de detalhes do produto
O sistema deve permitir consultar detalhes do produto antes da compra.

### RF05 — Atendimento automatizado por opções
O sistema deve prover um chat com fluxo automatizado por opções.

### RF06 — Transbordo de atendimento
O sistema deve permitir encaminhamento do atendimento para humano.

### RF07 — Envio de arquivos no chat
O sistema deve permitir envio de imagens e documentos no chat.

### RF08 — Carrinho de compras e checkout
O sistema deve permitir montar carrinho e concluir pedido.

### RF09 — Seleção de forma de recebimento
O sistema deve permitir escolher entre entrega e retirada.

### RF10 — Seleção de forma de pagamento
O sistema deve permitir escolher Pix, dinheiro ou cartão na entrega.

### RF11 — Acompanhamento de pedidos
O sistema deve permitir visualizar pedidos, detalhes e histórico.

### RF12 — Gestão de perfil do cliente
O sistema deve permitir atualização de dados pessoais e senha.

### RF13 — Gestão de fila de conversas
O sistema deve listar conversas e permitir busca de clientes no painel de atendimento.

### RF14 — Cadastro e edição de produtos
O sistema deve permitir cadastrar e editar produtos.

### RF15 — Gestão de estoque
O sistema deve permitir consultar e atualizar estoque.

### RF16 — Dashboards e indicadores básicos
O sistema deve exibir métricas e gráficos gerenciais básicos.

---

## 7. Requisitos Não Funcionais do MVP

### RNF01 — Performance de interface
A aplicação deve manter navegação fluida e responsiva nas telas principais.

### RNF02 — Segurança em trânsito
A comunicação entre app e backend deve ocorrer por conexão segura.

### RNF03 — Proteção de dados
Dados de usuários e informações sensíveis devem ser protegidos conforme boas práticas e LGPD.

### RNF04 — Responsividade
A interface deve se adaptar adequadamente a dispositivos móveis.

### RNF05 — Consistência visual
As telas devem seguir padrão visual consistente entre fluxos principais.

### RNF06 — Persistência confiável
Pedidos, produtos, usuários e conversas devem ser persistidos de forma confiável.

### RNF07 — Organização arquitetural
O projeto deve manter separação clara entre interface, lógica e dados.

### RNF08 — Padrão MVVM
A implementação deve seguir o padrão MVVM adotado pelo projeto.

### RNF09 — Modularidade
As funcionalidades devem permanecer organizadas por módulos para facilitar manutenção e evolução.

---

## 8. Casos de Uso Cobertos pelo MVP

| UC | Nome | Domínio |
|---|---|---|
| UC01 | Cadastrar Usuário | Acesso |
| UC02 | Autenticar Usuário | Acesso |
| UC03 | Gerenciar Conta | Acesso |
| UC04 | Navegar no Catálogo | Cliente |
| UC05 | Buscar Produto | Cliente |
| UC06 | Visualizar Produto | Cliente |
| UC07 | Realizar Atendimento no Chat | Atendimento |
| UC08 | Solicitar Atendimento Humano | Atendimento |
| UC09 | Enviar Arquivo no Chat | Atendimento |
| UC10 | Gerenciar Carrinho | Compra |
| UC11 | Finalizar Pedido | Compra |
| UC12 | Consultar Pedidos | Pedido |
| UC13 | Acompanhar Pedido | Pedido |
| UC14 | Visualizar Histórico de Compras | Pedido |
| UC15 | Gerenciar Conversas no Painel | Atendimento Interno |
| UC16 | Buscar Cliente no Painel | Atendimento Interno |
| UC17 | Cadastrar Produto | Gestão |
| UC18 | Editar Produto | Gestão |
| UC19 | Atualizar Estoque | Gestão |
| UC20 | Consultar Indicadores Gerenciais | Gestão |

---

## 9. Critério de Aceite do MVP

O MVP será considerado adequado quando for possível demonstrar, de ponta a ponta, os seguintes cenários:

### Cenário 1 — Jornada do cliente
- usuário cria conta ou entra no sistema;
- navega pelo catálogo;
- utiliza o chat;
- adiciona produtos ao carrinho;
- conclui um pedido;
- consulta o pedido no histórico.

### Cenário 2 — Jornada do atendimento
- atendente acessa o painel;
- localiza uma conversa;
- consulta o contexto do cliente;
- dá continuidade ao atendimento humano.

### Cenário 3 — Jornada da gestão
- usuário autorizado cadastra ou edita produto;
- atualiza estoque;
- consulta visão gerencial com métricas básicas.

Se esses três cenários estiverem funcionando com consistência, o MVP já cumpre sua função de validação do produto.

---

## 10. Conclusão

O MVP do **Farmácia Americana App** deve ser entendido como a primeira versão sólida do produto, centrada no essencial: **atendimento digital estruturado, compra dentro do app e apoio operacional básico**.

Esse escopo cria uma base mais coerente com a documentação revisada e com a direção atual do projeto, evitando dependências desnecessárias de recursos que não fazem mais parte da proposta principal da solução.

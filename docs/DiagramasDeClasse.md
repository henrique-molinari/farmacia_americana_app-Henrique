## Diagrama de Classes

O diagrama de classes apresentado neste projeto representa a estrutura arquitetural do sistema da aplicação **Farmácia Americana**, evidenciando a organização das entidades, responsabilidades e relações entre os principais componentes do sistema.

A modelagem foi dividida em módulos funcionais, com o objetivo de melhorar a compreensão, manutenção e escalabilidade da aplicação. Cada módulo agrupa classes que compartilham responsabilidades semelhantes dentro do sistema.

### Módulo de Autenticação (Auth / Core)
Responsável pelo gerenciamento de usuários e autenticação. Contém a entidade `User`, que representa os usuários do sistema, e o `UserRole`, que define os diferentes perfis de acesso (cliente, atendente, farmacêutico, gerente e administrador). Também inclui classes responsáveis pelo controle de sessão e acesso aos dados de autenticação.

<img width="388" height="519" alt="image" src="https://github.com/user-attachments/assets/3aebcd08-34f7-4c7b-b9b1-1a56f913c4ca" />

### Módulo de Cliente (Catálogo e Carrinho)
Gerencia os produtos disponíveis e o carrinho de compras. Inclui a entidade `Product`, que representa os itens vendidos, e `CartItem`, que representa produtos adicionados ao carrinho. O `CartViewModel` centraliza a lógica de manipulação do carrinho e interação com o sistema.

<img width="603" height="407" alt="image" src="https://github.com/user-attachments/assets/6ee63297-0ef6-4a57-980d-700ac15e89a9" />

### Módulo de Pedido
Responsável pelo fluxo de pedidos da aplicação. A classe `Order` representa uma compra realizada pelo usuário, enquanto `OrderItem` detalha os produtos incluídos no pedido. Também são definidos os enums `OrderStatus` e `PaymentMethod`, que controlam o estado do pedido e a forma de pagamento, respectivamente.

<img width="527" height="707" alt="image" src="https://github.com/user-attachments/assets/48ca5afd-e1a4-4ed2-9785-5ee27a04c463" />

### Módulo de Chat
Implementa o sistema de comunicação entre cliente, bot e atendente. Inclui entidades como `ClientChatConversation`, `ClientChatMessage` e `ClientChatBotStep`, permitindo tanto interações automatizadas quanto atendimento humano. Esse módulo possibilita a troca de mensagens, envio de anexos e navegação por fluxos de atendimento.

<img width="569" height="690" alt="image" src="https://github.com/user-attachments/assets/12980889-3d90-4a70-9cc3-bee88ca9bddf" />

### Módulo de Atendimento
Voltado para o suporte operacional da farmácia, permitindo que atendentes gerenciem clientes e produtos. Contém classes relacionadas à busca de clientes, cadastro e manipulação de produtos, além das camadas responsáveis pela lógica de negócio.

<img width="659" height="362" alt="image" src="https://github.com/user-attachments/assets/e8d3018d-a9e6-4d90-bee1-aeb5250091cb" />

### Módulo de Gestão
Responsável pela análise e monitoramento do sistema. Inclui classes que representam dados consolidados, como `ManagerProductSummary` e `ManagerOrderSummary`, além de repositórios e view models utilizados para geração de dashboards e controle de estoque.

<img width="659" height="351" alt="image" src="https://github.com/user-attachments/assets/445ce0be-2aaf-4afe-9c9e-9cfc11535f77" />

---

### Relações entre os módulos

O diagrama também evidencia a interação entre os módulos, destacando que:

- Um `User` pode realizar pedidos (`Order`) e participar de conversas (`ClientChatConversation`);
- O carrinho depende da sessão do usuário (`AuthSessionViewModel`) e do fluxo de pedidos;
- O sistema de chat também utiliza a sessão do usuário para identificar o contexto da conversa;
- Os módulos de atendimento e gestão utilizam dados de outros módulos para operações administrativas e analíticas.

<img width="8192" height="2263" alt="image" src="https://github.com/user-attachments/assets/823e81c5-ae4c-44af-9ee6-ad7ed7f3e1da" />

---

### Objetivo do Diagrama

Este diagrama tem como objetivo:

- Fornecer uma visão clara da arquitetura do sistema;
- Facilitar o entendimento das responsabilidades de cada componente;
- Servir como base para desenvolvimento, manutenção e evolução do projeto;
- Apoiar a comunicação entre membros da equipe técnica.


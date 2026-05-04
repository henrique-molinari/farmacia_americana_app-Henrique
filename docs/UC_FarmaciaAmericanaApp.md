# Casos de Uso (UC) — Ecossistema Farmácia Americana

> Este documento detalha as interações funcionais entre os atores e o sistema, servindo como guia para o desenvolvimento da lógica de negócio no Flutter e Backend.

---

## Índice

### Domínio: Acesso e Identidade
- [UC10 — Autenticar Usuário](#uc10--autenticar-usuário)
- [UC11 — Gerenciar Perfil e Conta](#uc11--gerenciar-perfil-e-conta)
- [UC14 — Gerenciar Acessos e Perfis (RBAC)](#uc14--gerenciar-acessos-e-perfis-rbac)

### Domínio: Atendimento e IA
- [UC04 — Realizar Transbordo de Atendimento](#uc04--realizar-transbordo-de-atendimento)
- [UC13 — Cadastrar Produto (com Assistência de IA)](#uc13--cadastrar-produto-com-assistência-de-ia)

### Domínio: Operação Comercial
- [UC01 — Realizar Venda](#uc01--realizar-venda)
- [UC02 — Consultar Histórico de Cliente](#uc02--consultar-histórico-de-cliente)
- [UC03 — Consultar e Verificar Estoque](#uc03--consultar-e-verificar-estoque)
- [UC15 — Navegar no Catálogo e Consultar Produto](#uc15--navegar-no-catálogo-e-consultar-produto)

### Domínio: Regulatório e Auditoria
- [UC05 — Validar Receita Médica](#uc05--validar-receita-médica)
- [UC06 — Persistir Dados de Auditoria](#uc06--persistir-dados-de-auditoria)

### Domínio: Financeiro e Logística
- [UC08 — Processar Pagamento e Confirmar Recebimento](#uc08--processar-pagamento-e-confirmar-recebimento)
- [UC12 — Rastrear Pedido em Tempo Real](#uc12--rastrear-pedido-em-tempo-real)
- [UC16 — Receber e Processar Notificação Push](#uc16--receber-e-processar-notificação-push)

### Domínio: Gestão e BI
- [UC07 — Gerenciar Unidade](#uc07--gerenciar-unidade)
- [UC09 — Consultar Performance (BI Mobile)](#uc09--consultar-performance-bi-mobile)

---

## Matriz de Rastreabilidade

| UC | Nome | Ator Principal | RFs Relacionados | RNs Relacionadas |
|---|---|---|---|---|
| **UC01** | Realizar Venda | Cliente | RF02, RF03, RF05, RF07, RF08, RF15 | RN01, RN02, RN04, RN05, RN07, RN08, RN10 |
| **UC02** | Consultar Histórico de Cliente | Atendente | RF13, RF15 | RN05 |
| **UC03** | Consultar e Verificar Estoque | Sistema | RF02, RF03, RF05, RF14 | RN07 |
| **UC04** | Realizar Transbordo de Atendimento | Cliente | RF04, RF11, RF12 | RN01, RN02, RN04 |
| **UC05** | Validar Receita Médica | Farmacêutico | RF06, RF13, RF15 | RN04, RN05, RN06 |
| **UC06** | Persistir Dados de Auditoria | Sistema | RF15 | RN05, RN06 |
| **UC07** | Gerenciar Unidade | Gerente/Dono | RF14, RF18 | RN11, RN12 |
| **UC08** | Processar Pagamento e Confirmar Recebimento | Cliente | RF07, RF08 | RN08, RN09, RN10 |
| **UC09** | Consultar Performance (BI Mobile) | Gerente/Dono | RF16, RF17 | RN11 |
| **UC10** | Autenticar Usuário | Todos | RF01 | RN11 |
| **UC11** | Gerenciar Perfil e Conta | Cliente | RF10 | — |
| **UC12** | Rastrear Pedido em Tempo Real | Cliente | RF09 | RN08, RN10, RN13 |
| **UC13** | Cadastrar Produto (com Assistência de IA) | Atendente | RF03, RF05 | RN03, RN04, RN07 |
| **UC14** | Gerenciar Acessos e Perfis (RBAC) | Administrador | — | RN11 |
| **UC15** | Navegar no Catálogo e Consultar Produto | Cliente | RF02, RF03 | RN07, RN10 |
| **UC16** | Receber e Processar Notificação Push | Sistema | — | RN08, RN13 |




---

## UC01 — Realizar Venda

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente, Atendente, Gerente/Dono |
| **Descrição** | Registra a compra de produtos por dois fluxos: Autônomo (Catálogo/Carrinho) para itens isentos, ou Assistido (Chat/Árvore de Decisão) para fluxos guiados e suporte. |
| **Pré-condições** | Usuário autenticado; Produtos com estoque disponível. |
| **Pós-condições** | Venda registrada; Estoque atualizado; Comprovante gerado; Dados de auditoria persistidos. |
| **RFs relacionados** | RF02, RF03, RF05, RF07, RF08, RF15 |
| **RNs relacionadas** | RN01, RN02, RN04, RN05, RN07, RN08, RN10 |

### Fluxo Principal (Caminho 1: Autônomo - MIPs e Conveniência)

1. O Cliente navega pelo catálogo na Home ou por categorias.
2. O Cliente seleciona um produto (MIP, Perfumaria, Higiene ou Beleza).
3. **Opção A (Carrinho):** O Cliente adiciona itens ao carrinho, acessa a tela de checkout e segue para o pagamento.
4. **Opção B (Comprar Agora):** O Cliente seleciona um único item e é direcionado imediatamente à tela de pagamento.
5. O Sistema verifica o estoque e calcula o total com base no preço atual.
6. O Cliente escolhe o método de pagamento (Pix ou Entrega) e finaliza a compra.
7. O Sistema abate o estoque e confirma o pedido.

### Fluxo Alternativo (Caminho 2: Assistido - Chat/Árvore de Decisão)

1. O Cliente inicia o atendimento via chat.
2. O Cliente interage através de cliques nas opções da Árvore de Decisão.
3. O Cliente seleciona produtos e segue o fluxo de compra orientado pela interface de conversa.
4. Se o item selecionado for um Medicamento Controlado, o Sistema solicita obrigatoriamente a foto da receita para validação humana (estende **UC05**).
5. Caso o fluxo automático não resolva, o atendimento é transferido para um humano (estende **UC04**).
6. O pagamento é processado e a venda é registrada no painel administrativo.

### Fluxos de Exceção

| ID | Nome | Descrição |
|---|---|---|
| **FE01** | Estoque Insuficiente | O sistema impede a conclusão e informa a falta de saldo. |
| **FE02** | Expiração de Pagamento | Em pagamentos Pix, o pedido é cancelado automaticamente após 10 minutos de inatividade. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | UC02 — Identificar ou Cadastrar Cliente |
| **Include** | UC03 — Consultar e Verificar Estoque |
| **Include** | UC06 — Persistir Dados de Auditoria |
| **Include** | UC08 — Processar Pagamento e Confirmar Recebimento |
| **Extend** | UC05 — Validar Receita Médica (Obrigatório para itens controlados) |
| **Extend** | UC04 — Realizar Transbordo de Atendimento (Se solicitado via menu ou falha de fluxo) |

### Diagrama de Atividades

<img width="648" height="843" alt="image" src="https://github.com/user-attachments/assets/6e4272f3-911f-4da5-9c74-77ed6a5abdae" />

---

## UC02 — Consultar Histórico de Cliente

| Campo | Descrição |
|---|---|
| **Ator(es)** | Atendente, Gerente/Dono |
| **Descrição** | Permite que o atendente localize um cliente pelo nome para visualizar seus dados e acessar o histórico completo de conversas (logs) e pedidos. |
| **Pré-condições** | Usuário autenticado no Painel Administrativo. |
| **Pós-condições** | Histórico de conversas e dados do cliente exibidos na tela. |
| **RFs relacionados** | RF13, RF15 |
| **RNs relacionadas** | RN05 (Persistência de Logs) |
| **RNFs relacionados** | RNF07 (Segurança de Dados) |

### Fluxo Principal

1. O Atendente acessa a seção "Clientes" ou "Histórico de Atendimento" no painel.
2. O Atendente digita o **nome** (ou parte dele) no campo de busca.
3. O Sistema realiza a filtragem em tempo real na base de dados.
4. O Sistema exibe uma lista de clientes correspondentes ao nome digitado.
5. O Atendente seleciona o cliente desejado.
6. O Sistema carrega o perfil do cliente e exibe cronologicamente todas as **conversas** (logs do chat) e vendas associadas.
7. O Atendente navega pelas conversas passadas para entender o histórico de solicitações.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Cliente não encontrado | Sistema exibe mensagem "Nenhum resultado encontrado" e sugere verificar a grafia. |
| **FA02** | Filtro por Período | O Atendente pode refinar a busca por data para encontrar conversas de um mês específico. |
| **FE01** | Sem Histórico | Se o cliente nunca interagiu via chat, o sistema exibe apenas os dados básicos e informa que não há logs disponíveis. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Extended by** | UC01 — Realizar Venda (Pode ser consultado durante uma venda ativa) |

### Diagrama de Atividades

<img width="493" height="529" alt="image" src="https://github.com/user-attachments/assets/5ba26778-10e2-4ffd-8332-466c7f3d77a9" />

---

## UC03 — Consultar e Verificar Estoque

| Campo | Descrição |
|---|---|
| **Ator(es)** | Atendente, Cliente, Sistema (Automático) |
| **Descrição** | Verifica a disponibilidade de um item em tempo real antes de permitir a adição ao carrinho ou finalização via chat, evitando a venda de itens sem saldo. |
| **Pré-condições** | Produto identificado por nome, categoria ou ID; Conexão ativa com o banco de dados. |
| **Pós-condições** | Saldo validado; Item permitido ou bloqueado para venda. |
| **RFs relacionados** | RF02, RF03, RF05, RF14 |
| **RNs relacionadas** | RN07 (Bloqueio de estoque) |
| **RNFs relacionados** | RNF04 (Sincronização em tempo real < 5s) |

### Fluxo Principal

1. O Atendente (Painel) ou Cliente (App) pesquisa um produto ou navega pelas categorias.
2. O Sistema consulta a base de dados de estoque em tempo real.
3. O Sistema retorna o saldo disponível. 
4. **No App:** O botão "Adicionar" ou "Comprar Agora" só fica ativo se o saldo for > 0.
5. **No Chat:** O Sistema (Árvore de Decisão) informa a disponibilidade antes de avançar para o checkout.
6. O usuário define a quantidade desejada.
7. Se **quantidade solicitada ≤ saldo**: O sistema permite a reserva temporária no carrinho.
8. Se **quantidade solicitada > saldo**: O sistema barra a operação, exibe o saldo real e sugere ajuste (RN07).

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Item Indisponível | O sistema oculta o botão de compra e exibe a tag "Esgotado" no catálogo. |
| **FA02** | Conflito de Checkout | Se dois clientes tentarem comprar a última unidade simultaneamente, o sistema valida no momento do pagamento e cancela o que finalizar por último. |
| **FE01** | Falha de Sincronização | Caso o banco não responda em 5s, o sistema exibe erro de conexão e impede a venda por segurança. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | Parte integrante do UC01 — Realizar Venda |
| **Include** | Parte integrante do UC15 — Navegar no Catálogo |

### Diagrama de Atividades

<img width="754" height="545" alt="image" src="https://github.com/user-attachments/assets/da008c6e-d811-48aa-86dc-318e998f4dcd" />

---

## UC04 — Realizar Transbordo de Atendimento

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente, Atendente, Sistema |
| **Descrição** | Transfere o cliente do fluxo automatizado (Árvore de Decisão) para um atendente humano quando solicitado pelo menu ou quando o fluxo exige validação manual. |
| **Pré-condições** | Chat iniciado; Cliente autenticado ou identificado. |
| **Pós-condições** | Cliente vinculado à fila de espera; Histórico de cliques e mensagens disponível para o atendente. |
| **RFs relacionados** | RF04, RF11, RF12 |
| **RNs relacionadas** | RN01, RN02, RN04 |
| **RNFs relacionados** | RNF02 (Notificações em tempo real) |

### Fluxo Principal

1. O Cliente interage com o Chat através das opções da Árvore de Decisão.
2. O Sistema identifica a necessidade de transbordo quando:
    - O Cliente seleciona a opção "Falar com Atendente" no menu.
    - O fluxo de compra de medicamento controlado exige validação de receita (estende **UC05**).
    - O Cliente atinge um "nó de ajuda" específico na árvore.
3. O Sistema notifica o Cliente que ele será transferido para um atendimento humano.
4. O Sistema enfileira a solicitação no Painel Administrativo.
5. O Sistema disponibiliza para o Atendente todo o log de opções selecionadas pelo Cliente até aquele momento.
6. O Atendente recebe um alerta (visual/sonoro) no painel.
7. O Atendente assume o ticket e inicia a interação manual.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Fora do Horário Comercial | O sistema informa que não há atendentes no momento e oferece a opção de deixar uma mensagem ou retornar depois. |
| **FA02** | Fila de Espera Longa | Se houver muitos clientes na frente, o sistema exibe a posição na fila em tempo real. |
| **FE01** | Perda de Conexão | Se o cliente desconectar durante a fila, a solicitação permanece ativa por X minutos antes de ser encerrada automaticamente. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Extend** | Disparado pelo UC01 — Realizar Venda (Quando há itens controlados) |
| **Extend** | Disparado pelo UC05 — Validar Receita Médica |
| **Include** | UC11 — Gestão de Fila de Conversas |

### Diagrama de Atividades

<img width="473" height="694" alt="image" src="https://github.com/user-attachments/assets/d8e7dea3-8af4-4c7a-be03-339e3eb85b73" />

---

## UC05 — Validar Receita Médica

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente, Farmacêutico, Sistema |
| **Descrição** | Gerencia o envio e a validação técnica de receitas para medicamentos controlados, garantindo a conformidade legal para a venda. |
| **Pré-condições** | Medicamento controlado selecionado; Cliente identificado; Farmacêutico autenticado no Painel Admin. |
| **Pós-condições** | Receita validada/rejeitada; Dados de auditoria (CRM, Imagem, CPF) persistidos; Venda liberada ou bloqueada. |
| **RFs relacionados** | RF06, RF13, RF15 |
| **RNs relacionadas** | RN04, RN05, RN06 |
| **RNFs relacionados** | RNF15 (Legibilidade da imagem) |

### Fluxo Principal

1. O Sistema detecta item controlado no checkout autônomo ou no chat e aciona o transbordo para o fluxo de validação.
2. O Sistema solicita, via interface de chat, a foto da receita médica.
3. O Cliente realiza o upload da imagem (JPEG/PNG).
4. O Sistema armazena a imagem em servidor seguro e gera um alerta no Painel do Farmacêutico.
5. O Farmacêutico acessa a tarefa e analisa a imagem, verificando:
   - Legibilidade e dados do paciente;
   - CRM e UF do médico prescritor;
   - Validade do documento e correspondência com o produto solicitado.
6. O Farmacêutico insere os dados do prescritor no sistema para registro legal.
7. O Farmacêutico registra o veredito (Aprovar ou Reprovar).
8. **Se Aprovado:** O Sistema libera o botão de pagamento para o Cliente no App.
9. **Se Reprovado:** O Sistema notifica o Cliente, informa o motivo (ex: receita vencida) e encerra o fluxo ou solicita novo envio.
10. O Sistema consolida os logs e a imagem para fins de auditoria futura.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Receita Ilegível | Farmacêutico solicita novo envio; Sistema reabre o campo de upload para o cliente. |
| **FA02** | Divergência de Item | Se a receita for de outro medicamento, o Farmacêutico reprova e orienta o cliente via chat. |
| **FE01** | Abandono de Upload | Se o cliente não enviar a foto em até X minutos, o sistema remove o item controlado do carrinho para permitir a compra dos demais itens. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Extend** | Disparado pelo UC01 — Realizar Venda (Interceptação de segurança) |
| **Include** | UC04 — Realizar Transbordo de Atendimento (A validação ocorre no ambiente de chat humano) |
| **Include** | UC06 — Persistir Dados de Auditoria |

### Diagrama de Atividades

<img width="522" height="695" alt="image" src="https://github.com/user-attachments/assets/d5ebe421-b32c-4c9d-8aac-195fc2178ca4" />

---

## UC06 — Persistir Dados de Auditoria

| Campo | Descrição |
|---|---|
| **Ator(es)** | Sistema (Automático) |
| **Descrição** | Registra de forma imutável e criptografada todos os dados críticos de uma transação, incluindo receitas, validações e o log completo do chat, garantindo rastreabilidade total. |
| **Pré-condições** | Finalização de venda (UC01) ou conclusão de validação (UC05). |
| **Pós-condições** | Registro persistido com criptografia AES-256; Imagem em bucket seguro; Hash de integridade gerado. |
| **RFs relacionados** | RF15 |
| **RNs relacionadas** | RN05, RN06 |
| **RNFs relacionados** | RNF05, RNF06, RNF08 |

### Fluxo Principal

1. O Sistema dispara o gatilho de persistência após a confirmação de pagamento ou validação técnica.
2. O Sistema consolida o pacote de dados obrigatórios:
   - Itens, valores e quantidades;
   - CPF do comprador e identificação do Farmacêutico;
   - CRM/UF do médico prescritor (se houver item controlado);
   - Log completo da árvore de decisão e chat humano.
3. O Sistema criptografa os dados sensíveis e a imagem da receita.
4. O Sistema realiza o upload da imagem para o bucket privado e obtém a referência de armazenamento.
5. O Sistema executa uma **transação atômica** no banco de dados para garantir que o log e a venda sejam gravados simultaneamente.
6. O Sistema gera um Hash de integridade para o registro (evitando edições posteriores).
7. O Sistema confirma o sucesso da operação para o fluxo de origem.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Erro de Conexão | O sistema armazena o pacote em cache local/fila e tenta a sincronização automática assim que a conexão for restabelecida. |
| **FE01** | Falha de Integridade | Caso os dados cheguem incompletos, o sistema aborta a transação e gera um log de erro crítico para o administrador. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | Invocado pelo UC01 — Realizar Venda |
| **Include** | Invocado pelo UC05 — Validar Receita Médica |

### Diagrama de Atividades

<img width="553" height="676" alt="image" src="https://github.com/user-attachments/assets/75637dd4-25e9-4ae6-addf-258252ef53ea" />

---

## UC07 — Gerenciar Unidade

| Campo | Descrição |
|---|---|
| **Ator(es)** | Gerente, Dono |
| **Descrição** | Permite configurar os parâmetros operacionais da unidade, como raio de entrega, métodos de pagamento aceitos e horários, impactando diretamente o checkout do cliente. |
| **Pré-condições** | Usuário autenticado com perfil administrativo; Unidade vinculada. |
| **Pós-condições** | Parâmetros atualizados no banco de dados; Regras de checkout sincronizadas em tempo real. |
| **RFs relacionados** | RF14, RF18 |
| **RNs relacionadas** | RN11, RN12 (Restrição de Raio de Entrega) |
| **RNFs relacionados** | RNF04 (Sincronização imediata) |

### Fluxo Principal

1. O Ator administrativo acessa o painel de "Configurações da Unidade".
2. O Sistema exibe as configurações atuais (Logística, Pagamento e Horários).
3. O Ator define o **Raio de Entrega** em quilômetros.
4. O Ator ativa ou desativa as **Formas de Pagamento** (ex: Habilitar/Desabilitar Pagamento na Entrega).
5. O Ator atualiza o horário de funcionamento da unidade.
6. O Sistema valida se os dados estão dentro dos limites operacionais.
7. O Sistema persiste as alterações e gera um registro de auditoria.
8. O Sistema propaga as novas regras para o App (Checkout), garantindo que clientes fora do raio não consigam finalizar pedidos de entrega.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Raio Inválido | O sistema impede valores negativos ou excessivos que a logística não comporte. |
| **FE01** | Unidade Fechada | Se o horário for alterado para "Fechado", o sistema bloqueia imediatamente novas vendas autônomas no App. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Extend** | Influencia o UC01 — Realizar Venda (Validação de raio e pagamento) |
| **Include** | UC06 — Persistir Dados de Auditoria |

### Diagrama de Atividades

<img width="677" height="581" alt="image" src="https://github.com/user-attachments/assets/7af4b632-e9ce-4c09-a3b1-54a1b163cbde" />

---

## UC08 — Processar Pagamento e Confirmar Recebimento

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente, Entregador, Sistema |
| **Descrição** | Gerencia o ciclo de vida financeiro da venda, desde a geração do QR Code PIX até a baixa manual em pagamentos presenciais. |
| **Pré-condições** | Venda finalizada (UC01); Valor total calculado com preços congelados. |
| **Pós-condições** | Pagamento confirmado; Pedido liberado para separação; Estoque definitivamente abatido ou liberado (em caso de cancelamento). |
| **RFs relacionados** | RF07, RF08 |
| **RNs relacionadas** | RN08, RN09, RN10 |
| **RNFs relacionados** | RNF02 (Notificações em tempo real) |

### Fluxo Principal

#### Caminho A: PIX (Digital e Síncrono)
1. O Cliente seleciona PIX no Checkout.
2. O Sistema congela o preço dos itens (RN10) e gera a Chave PIX Dinâmica.
3. O Sistema exibe o QR Code e inicia a contagem de **10 minutos**.
4. O Sistema aguarda a notificação do Banco (**Webhook**).
5. **Sucesso:** O Banco confirma o recebimento; o Sistema altera o status para "Pago" e notifica a farmácia.
6. **Expiração:** Após 10 min sem confirmação, o Sistema cancela o pedido e devolve os itens ao estoque automaticamente.

#### Caminho B: Pagamento na Entrega (Presencial e Assíncrono)
1. O Cliente seleciona "Pagar na Entrega".
2. O Sistema registra o pedido com status "Aguardando Pagamento na Entrega".
3. O Pedido segue o fluxo de logística (Separação e Saída).
4. O Entregador recebe o valor no ato da entrega (Cartão/Espécie).
5. O Entregador realiza a **Baixa Manual** no App/Painel.
6. O Sistema finaliza a transação e emite o comprovante digital.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Pagamento em Duplicidade | O sistema identifica o erro via Webhook e gera um alerta para o Gerente realizar o estorno manual. |
| **FA02** | Timeout do Webhook | Caso o banco não envie o Webhook, o sistema permite que o Atendente valide o comprovante enviado pelo cliente no chat e force a baixa manual. |
| **FE01** | Valor Divergente | No pagamento via PIX manual (chave estática), se o valor for inferior ao total, o sistema não libera o pedido. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | Invocado pelo UC01 — Realizar Venda |
| **Include** | UC06 — Persistir Dados de Auditoria |

### Diagrama de Atividades

<img width="690" height="734" alt="image" src="https://github.com/user-attachments/assets/84ac3cc9-f2e5-4e2a-9e9f-1ea13ed7dadf" />

---

## UC09 — Consultar Performance (BI Mobile)

| Campo | Descrição |
|---|---|
| **Ator(es)** | Gerente, Dono |
| **Descrição** | Permite que o gestor visualize indicadores rápidos de venda (Dia, Semana, Mês) diretamente pela AppBar do App mobile. |
| **Pré-condições** | Usuário autenticado no App com perfil Gerente ou Dono. |
| **Pós-condições** | Indicadores de performance exibidos na tela do smartphone. |
| **RFs relacionados** | RF16, RF17 |
| **RNs relacionadas** | RN11 (Filtro por Unidade) |
| **RNFs relacionados** | RNF04 (Sincronização rápida) |

### Fluxo Principal

1. O Gerente/Dono realiza login no App Flutter.
2. O Sistema identifica o perfil administrativo e renderiza o ícone de **"BI" na AppBar**.
3. O Usuário toca no ícone de BI.
4. O Sistema abre uma sobreposição ou tela rápida com os filtros: **Dia, Semana e Mês**.
5. O Sistema consulta o banco de dados e retorna:
   - Faturamento total do período selecionado;
   - Quantidade de pedidos finalizados;
   - Ticket médio simplificado.
6. O Sistema aplica a **RN11**, garantindo que o Gerente veja apenas os números da sua unidade.
7. O Usuário alterna entre as abas (Dia/Semana/Mês) para comparar resultados.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Usuário Comum | O ícone de BI não é exibido na AppBar para clientes ou entregadores. |
| **FE01** | Sem Vendas no Período | O sistema exibe o valor "R$ 0,00" e informa que não houve movimentação. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Extend** | Interface estendida da Home do App (AppBar) |

### Diagrama de Atividades

<img width="644" height="538" alt="image" src="https://github.com/user-attachments/assets/b4046698-e815-4ccc-a93a-d80d15fd4763" />

---

## UC10 — Autenticar Usuário

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente, Atendente, Farmacêutico, Gerente, Dono |
| **Descrição** | Realiza a autenticação segura via e-mail/senha, emitindo um token JWT com permissões específicas de perfil (Claims) e tempos de expiração distintos. |
| **Pré-condições** | Cadastro ativo no sistema; Conexão HTTPS. |
| **Pós-condições** | Token JWT persistido localmente; Acesso liberado conforme o perfil do usuário. |
| **RFs relacionados** | RF01 |
| **RNs relacionadas** | RN11 (Hierarquia definida no Token) |
| **RNFs relacionados** | RNF05, RNF07 |

### Fluxo Principal

1. O Usuário acessa a tela de Login no App ou Painel.
2. O Usuário insere as credenciais (E-mail e Senha).
3. O Sistema consulta a base de dados e valida o hash da senha.
4. **Se as credenciais forem válidas:**
   - O Sistema identifica o perfil do usuário.
   - O Sistema gera o **Token JWT** com o tempo de expiração definido:
     - **Clientes:** 24 horas.
     - **Equipe Técnica/Gestão:** 8 horas.
   - O Token é enviado ao dispositivo e armazenado de forma segura.
   - O Usuário é redirecionado para a Home.
5. **Se as credenciais forem inválidas:**
   - O Sistema exibe alerta de erro e permite nova tentativa.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Conta Bloqueada | Após 5 tentativas falhas, o sistema bloqueia o acesso temporariamente por 30 minutos para prevenir ataques de força bruta. |
| **FA02** | Recuperação de Senha | O usuário solicita o reset; o sistema envia um token temporário por e-mail para definição de nova senha. |
| **FE01** | Token Inválido/Expirado | O sistema intercepta a requisição, limpa os dados locais e redireciona para a tela de login. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | Pré-condição obrigatória para todos os UCs operacionais (UC01 a UC09). |

### Diagrama de Atividades

<img width="853" height="578" alt="image" src="https://github.com/user-attachments/assets/e5b5387c-7bb1-468d-8cff-659acf1a2898" />

---

## UC11 — Gerenciar Perfil e Conta

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente |
| **Descrição** | Permite ao cliente alterar seus dados cadastrais (Nome, E-mail, CPF, Telefone) e senha através da seção "Dados Pessoais" dentro do menu de conta. |
| **Pré-condições** | Usuário autenticado (UC10). |
| **Pós-condições** | Dados e/ou senha atualizados no banco de dados com criptografia. |
| **RFs relacionados** | RF10 |
| **RNs relacionadas** | — |
| **RNFs relacionados** | RNF06 (Criptografia AES-256) |

### Fluxo Principal

1. O Cliente realiza login no App.
2. O Cliente seleciona a opção **'Conta'** na AppBar do App.
3. O Sistema abre a tela **'Minha Conta'**.
4. O Cliente seleciona a opção **'Dados Pessoais'**.
5. O Sistema exibe os campos editáveis: Nome, E-mail, CPF, Telefone e a opção de Alterar Senha.
6. O Cliente realiza as alterações desejadas.
7. O Cliente confirma a atualização.
8. O Sistema valida os novos dados e a força da nova senha (se alterada).
9. O Sistema persiste as informações no banco de dados aplicando criptografia.
10. O Sistema exibe mensagem de sucesso.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Alteração de Senha | O usuário deve inserir a senha atual ou validar via e-mail para confirmar a troca por uma nova. |
| **FE01** | CPF Inválido | O sistema valida o dígito verificador do CPF antes de permitir a alteração. |

### Diagrama de Atividades

<img width="426" height="772" alt="image" src="https://github.com/user-attachments/assets/6205c5de-e7cc-48a3-92d6-bc1fe8a3d66f" />

---

## UC12 — Rastrear Pedido em Tempo Real

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente, Sistema (Automático) |
| **Descrição** | Exibe o status atualizado do pedido e uma linha do tempo de eventos, desde a aprovação do pagamento até a entrega final. |
| **Pré-condições** | Pedido realizado (UC01); Cliente autenticado (UC10). |
| **Pós-condições** | Status visualizado pelo cliente; Notificações Push enviadas a cada transição. |
| **RFs relacionados** | RF09 |
| **RNs relacionadas** | RN08, RN10, RN13 |
| **RNFs relacionados** | RNF04 (Sincronização em tempo real < 5s) |

### Fluxo Principal

1. O Cliente acessa a seção **'Meus Pedidos'** no App Flutter.
2. O Sistema lista os pedidos recentes com seus respectivos status resumidos.
3. O Cliente seleciona um pedido específico.
4. O Sistema carrega os detalhes em tempo real:
   - **Timeline de Status:** Histórico com data e hora (Aprovado, Separação, Rota, Concluído).
   - **Dados da Compra:** Itens com preços congelados no momento da venda.
   - **Logística:** Endereço de destino e informações do entregador (se disponível).
5. O Sistema atualiza a tela automaticamente caso ocorra uma mudança de status no backend.
6. O Sistema dispara uma notificação Push para o dispositivo do cliente a cada mudança de estágio.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Pagamento Expirado | Caso o PIX não tenha sido pago em 10 min, o status muda para "Cancelado" e o sistema oculta a timeline de entrega. |
| **FE01** | Erro de Conexão | O sistema exibe o último status conhecido em cache e alerta que a atualização em tempo real está suspensa. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | UC16 — Receber e Processar Notificação Push |
| **Extend** | Complementa o UC01 — Realizar Venda |

### Diagrama de Atividades

<img width="620" height="676" alt="image" src="https://github.com/user-attachments/assets/dfcadf1d-08bb-4b02-ab53-0260c0669308" />

---

## UC13 — Cadastrar Produto (com Assistência de IA)

| Campo | Descrição |
|---|---|
| **Ator(es)** | Atendente, Gerente, Dono |
| **Descrição** | Permite o cadastro de novos itens no catálogo da farmácia, utilizando IA para gerar descrições automáticas e agilizar o preenchimento. |
| **Pré-condições** | Usuário autenticado com perfil de Atendente ou superior; Conexão ativa com o banco de dados. |
| **Pós-condições** | Produto disponível no catálogo e estoque; Descrição persistida; Log de auditoria gerado. |
| **RFs relacionados** | RF03, RF05 |
| **RNs relacionadas** | RN03 (Uso de IA), RN04 (Marcação de Controlado), RN07 (Estoque Inicial) |
| **RNFs relacionados** | RNF15 (Confiabilidade da IA) |

### Fluxo Principal

1. O Atendente realiza login no App.
2. O Atendente seleciona a opção **'Perfil'** na AppBar.
3. O Atendente escolhe a opção **'Cadastro de Produtos'**.
4. O Atendente insere o **Nome do Produto**.
5. O Atendente clica no botão **"Gerar descrição com IA"**.
6. O Sistema processa o nome e retorna uma sugestão de descrição e posologia básica.
7. O Atendente revisa a descrição e seleciona a **Categoria** do produto.
8. O Atendente insere o **Preço** (em Reais) e a **Quantidade em Estoque**.
9. O Atendente seleciona a **Data de Cadastro** (via seletor de data).
10. O Atendente define se o produto é **Controlado** ou não (Toggle/Switch).
11. O Atendente clica em **"Salvar Produto"**.
12. O Sistema valida se todos os campos obrigatórios estão preenchidos e persiste os dados.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Edição de Descrição | O atendente pode alterar manualmente a descrição gerada pela IA antes de salvar. |
| **FE01** | IA Indisponível | Se o serviço de IA falhar, o sistema permite que o atendente digite a descrição manualmente sem interrupção do cadastro. |
| **FE02** | Produto já Existente | O sistema alerta caso o nome/EAN do produto já esteja cadastrado na unidade. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | UC10 — Autenticar Usuário |
| **Include** | UC06 — Persistir Dados de Auditoria |
### Diagrama de Atividades

<img width="480" height="963" alt="image" src="https://github.com/user-attachments/assets/188f1267-bf04-4e6d-a7a0-3d1cf7a8c999" />

---

## UC14 — Gerenciar Acessos e Perfis (RBAC)

| Campo | Descrição |
|---|---|
| **Ator(es)** | Administrador (Dono) |
| **Descrição** | Permite gerenciar as permissões e níveis de acesso de cada colaborador, garantindo que cada função (Atendente, Farmacêutico, Gerente) visualize apenas o necessário para sua operação. |
| **Pré-condições** | Usuário autenticado com perfil de Administrador (Dono). |
| **Pós-condições** | Permissões atualizadas no banco de dados; Sessão do usuário afetado invalidada para atualização de Token. |
| **RFs relacionados** | — |
| **RNs relacionadas** | RN11 (Hierarquia de Acesso) |
| **RNFs relacionados** | RNF07 (Segurança de Acesso) |

### Fluxo Principal

1. O Administrador acessa o módulo de **'Controle de Acessos'** no Painel Administrativo.
2. O Sistema lista os colaboradores vinculados à unidade ou rede.
3. O Administrador seleciona um colaborador ou inicia um novo cadastro.
4. O Administrador atribui o nível de acesso conforme a hierarquia:
   - **Atendente:** Chat, busca de cliente e cadastro de produtos.
   - **Farmacêutico:** Funções de Atendente + Validação de Receitas Médicas.
   - **Gerente:** Funções de Farmacêutico + BI da Unidade e Configurações Locais.
   - **Dono:** Acesso total e visão global de todas as unidades.
5. O Administrador confirma a alteração.
6. O Sistema persiste a mudança e registra a ação no Log de Auditoria.
7. O Sistema revoga o token JWT atual do colaborador afetado, exigindo um novo login para aplicar as novas permissões.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Suspensão de Conta | O Administrador desativa um perfil; o acesso é bloqueado instantaneamente em todas as interfaces. |
| **FE01** | Hierarquia Bloqueada | O sistema impede que um Gerente tente elevar seu próprio nível para Administrador/Dono. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | UC10 — Autenticar Usuário |
| **Extend** | Define as permissões para UC02, UC05, UC07, UC09 e UC13 |

### Diagrama de Atividades

<img width="420" height="774" alt="image" src="https://github.com/user-attachments/assets/9ca0bad0-abeb-48ac-ad94-326b9321a7ad" />

---

## UC15 — Navegar no Catálogo e Consultar Produto

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente |
| **Descrição** | Permite ao cliente explorar o catálogo, pelas categorias e visualizar detalhes técnicos de produtos (foto, descrição e preço) antes de decidir pela compra. |
| **Pré-condições** | Usuário autenticado (UC10); Unidade física selecionada. |
| **Pós-condições** | Produto visualizado; Intenção de compra capturada para o checkout ou chat. |
| **RFs relacionados** | RF02, RF03 |
| **RNs relacionadas** | RN07 (Estoque), RN10 (Preço) |
| **RNFs relacionados** | RNF01 (60 FPS), RNF09 (Offline First/Cache), RNF10 (Material Design 3) |

### Fluxo Principal

1. O Cliente acessa a Home do App após a autenticação.
2. O Sistema renderiza o catálogo.
3. O Cliente navega pelas categorias ou utiliza a barra de busca por nome/marca.
4. O Sistema filtra os itens e consulta a disponibilidade em tempo real.
5. O Cliente toca em um produto para ver os detalhes.
6. O Sistema exibe:
   - Imagem do produto;
   - Descrição (previamente otimizada por IA no UC13);
   - Preço atualizado e selo de "Medicamento Controlado" (se aplicável);
   - Status de estoque (Disponível/Esgotado).
7. O Cliente opta por clicar em **"Adicionar ao Carrinho"** ou **"Comprar Agora"**.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Busca Sem Resultados | O sistema oferece sugestões baseadas em categorias populares ou marcas similares. |
| **FA02** | Cache de Imagens | Em caso de conexão instável, o sistema exibe imagens e preços salvos localmente para garantir a fluidez da navegação. |
| **FE01** | Item Esgotado | O botão de compra é desabilitado. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | UC03 — Consultar e Verificar Estoque |
| **Extend** | Dispara o UC01 — Realizar Venda |

### Diagrama de Atividades

<img width="495" height="688" alt="image" src="https://github.com/user-attachments/assets/37d9f836-bf6e-4410-963e-97a69644f6f1" />

---

## UC16 — Receber e Processar Notificação Push

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente, Sistema (Automático) |
| **Descrição** | Gerencia a entrega de alertas e o redirecionamento automático do usuário para a tela de contexto após a interação com a notificação. |
| **Pré-condições** | Permissão de notificação concedida; Evento disparado no servidor. |
| **Pós-condições** | Usuário notificado e encaminhado para o contexto correto do evento. |

### Fluxo Principal

1. O Sistema identifica um evento relevante no backend.
2. O Sistema envia uma notificação push para o dispositivo do cliente via serviço de nuvem.
3. O dispositivo recebe e exibe o alerta na bandeja do sistema operacional.
4. O Cliente toca na notificação.
5. O App abre e interpreta os dados da notificação para realizar o redirecionamento automático para a tela pertinente ao evento.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Notificação Ignorada | O alerta permanece na bandeja até ser limpo manualmente ou substituído por um novo. |
| **FE01** | Falha de Sincronização | Caso o App não consiga carregar os dados novos após o toque, exibe a tela inicial com um alerta de conexão. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | Suporte visual para o UC12 — Rastrear Pedido |
| **Extend** | Disparado por eventos de Venda, Pagamento e Validação de Receita |

### Diagrama de Atividades

v<img width="648" height="517" alt="image" src="https://github.com/user-attachments/assets/64e02696-11c8-44dd-a516-34fc6393b976" />

> **Diretriz de Implementação:** Todas as regras de negócio devem ser validadas tanto na camada de interface (Flutter) para melhor UX quanto na camada de serviços (Backend) para garantir a integridade dos dados. Referência: RNs e RNFs deste documento.


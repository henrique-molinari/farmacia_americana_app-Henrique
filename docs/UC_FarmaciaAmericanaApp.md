# Casos de Uso (UC) — Ecossistema Farmácia Americana

> Este documento detalha as interações funcionais entre os atores e o sistema, servindo como guia para o desenvolvimento da lógica de negócio no Flutter e Backend.
>

---

## Índice

### Domínio: Acesso e Identidade
- [UC10 — Autenticar Usuário](#uc10--autenticar-usuário)
- [UC11 — Gerenciar Perfil e Conta](#uc11--gerenciar-perfil-e-conta)
- [UC14 — Gerenciar Acessos e Perfis (RBAC)](#uc14--gerenciar-acessos-e-perfis-rbac)

### Domínio: Atendimento
- [UC04 — Realizar Transbordo de Atendimento](#uc04--realizar-transbordo-de-atendimento)
- [UC13 — Configurar e Gerenciar IA](#uc13--configurar-e-gerenciar-ia)

### Domínio: Operação
- [UC01 — Realizar Venda](#uc01--realizar-venda)
- [UC02 — Identificar ou Cadastrar Cliente](#uc02--identificar-ou-cadastrar-cliente)
- [UC03 — Consultar e Verificar Estoque](#uc03--consultar-e-verificar-estoque)
- [UC15 — Navegar no Catálogo e Consultar Produto](#uc15--navegar-no-catálogo-e-consultar-produto)
- [UC17 — Gerenciar Catálogo de Produtos](#uc17--gerenciar-catálogo-de-produtos)

### Domínio: Regulatório
- [UC05 — Validar Receita Médica](#uc05--validar-receita-médica)
- [UC06 — Persistir Dados de Auditoria](#uc06--persistir-dados-de-auditoria)

### Domínio: Financeiro e Logística
- [UC08 — Processar Pagamento e Confirmar Recebimento](#uc08--processar-pagamento-e-confirmar-recebimento)
- [UC12 — Rastrear Pedido em Tempo Real](#uc12--rastrear-pedido-em-tempo-real)
- [UC16 — Receber e Processar Notificação Push](#uc16--receber-e-processar-notificação-push)

### Domínio: Gestão
- [UC07 — Gerenciar Unidade](#uc07--gerenciar-unidade)
- [UC09 — Analisar Performance e Auditoria (BI)](#uc09--analisar-performance-e-auditoria-bi)

---

## Cobertura Completa

| UC | Nome | Domínio | RFs | RNs | RNFs |
|---|---|---|---|---|---|
| UC01 | Realizar Venda | Operação | RF03, RF05 | RN01, RN07, RN08, RN09, RN10 | — |
| UC02 | Identificar ou Cadastrar Cliente | Operação | RF01 | — | RNF07 |
| UC03 | Consultar e Verificar Estoque | Operação | RF14 | RN07 | RNF04 |
| UC04 | Realizar Transbordo de Atendimento | Atendimento | RF04, RF11 | RN01, RN02 | RNF02 |
| UC05 | Validar Receita Médica | Regulatório | RF06, RF13 | RN04, RN05, RN06 | RNF15 |
| UC06 | Persistir Dados de Auditoria | Regulatório | RF15 | RN05, RN06 | RNF05, RNF06, RNF08 |
| UC07 | Gerenciar Unidade | Gestão | RF14, RF18 | RN12 | RNF04 |
| UC08 | Processar Pagamento e Confirmar Recebimento | Financeiro | RF07, RF08 | RN08, RN09, RN10 | — |
| UC09 | Analisar Performance e Auditoria (BI) | Gestão | RF16, RF17 | RN11 | — |
| UC10 | Autenticar Usuário | Acesso | RF01 | — | RNF05, RNF07 |
| UC11 | Gerenciar Perfil e Conta | Acesso | RF10 | — | RNF06 |
| UC12 | Rastrear Pedido em Tempo Real | Logística | RF09 | RN13 | RNF04 |
| UC13 | Configurar e Gerenciar IA | Atendimento | RF03, RF05 | RN01, RN02, RN03 | RNF02, RNF15, RNF16 |
| UC14 | Gerenciar Acessos e Perfis (RBAC) | Acesso | — | RN11 | RNF07 |
| UC15 | Navegar no Catálogo e Consultar Produto | Operação | RF02 | — | RNF01, RNF09, RNF10 |
| UC16 | Receber e Processar Notificação Push | Logística | — | RN13 | RNF04 |
| UC17 | Gerenciar Catálogo de Produtos | Operação | RF02, RF14 | RN03, RN07 | RNF04, RNF15 |

<img width="1005" height="872" alt="image" src="https://github.com/user-attachments/assets/efa219cf-a260-40c1-a2ae-1c8e8e64a7c5" />

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
| **Ator(es)** | Atendente, Farmacêutico, Cliente, Sistema (Automático) |
| **Descrição** | Verifica a disponibilidade física de um item na unidade atual antes de permitir sua adição ao carrinho, evitando sobrevenda e garantindo integridade do estoque. |
| **Pré-condições** | Produto identificado por nome ou ID; Unidade física selecionada; Sincronização de estoque atualizada. |
| **Pós-condições** | Saldo exibido em tempo real; Validação de quantidade confirmada ou rejeitada. |
| **RFs relacionados** | RF14 |
| **RNs relacionadas** | RN07 |
| **RNFs relacionados** | RNF04 |

### Fluxo Principal

1. Atendente/Cliente pesquisa o produto durante a venda ou navegação pelo catálogo.
2. Sistema consulta a tabela de estoque da unidade em tempo real (RNF04 — máx. 30 segundos).
3. Sistema retorna o saldo disponível e indicador visual de disponibilidade.
4. Atendente/Cliente confirma a adição da quantidade desejada.
5. Se quantidade ≤ saldo: Sistema aceita e reserva temporariamente o item (bloqueio de estoque).
6. Se quantidade > saldo: Sistema rejeita a operação (RN07) e oferece alternativa (quantidade máxima ou sugestão de similar).

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Produto sem Estoque | Sistema exibe mensagem "Indisponível no momento" e oferece opção de notificação quando voltar a estar em estoque. |
| **FA02** | Última Unidade em Estoque | Sistema exibe alerta visual para o Atendente, sugerindo confirmação dupla da venda. |
| **FA03** | Sincronização Desatualizada | Se a sincronização demorar mais de 30 segundos, sistema exibe mensagem de aviso e oferece opção de aguardar ou usar última data conhecida. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | Faz parte do UC01 — Realizar Venda |
| **Include** | Faz parte do UC15 — Navegar no Catálogo |

### Diagrama de Atividades

<img width="358" height="422" alt="image" src="https://github.com/user-attachments/assets/574148f2-d573-4bdc-8f3d-b88cfeb56caa" />

---

## UC04 — Realizar Transbordo de Atendimento

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente, Sistema (IA), Atendente |
| **Descrição** | Transfere o cliente de um fluxo de atendimento automatizado (IA com opções via menu) para um atendente humano quando a IA não consegue resolver a demanda ou o cliente solicita intervenção manual. |
| **Pré-condições** | Chat iniciado; Sistema não consegue resolver pela árvore de decisão (RN01) ou cliente selecionou "Falar com Atendente". |
| **Pós-condições** | Cliente enfileirado na fila de atendimento humano; Histórico do chat transferido para o painel do Atendente. |
| **RFs relacionados** | RF04, RF11 |
| **RNs relacionadas** | RN01, RN02 |
| **RNFs relacionados** | RNF02 |

### Fluxo Principal

1. Cliente interage com opções do menu da IA (RN01) no chat nativo.
2. Sistema detecta uma das condições de transbordo:
   - Cliente selecionou o botão "Falar com Atendente" (RN02);
   - Sistema não conseguiu resolver a demanda após X tentativas (configurável em UC13);
   - Fluxo de venda requer validação de receita (estende UC05).
3. Sistema exibe mensagem: "Você será conectado com um atendente em breve".
4. Sistema enfileira o cliente na fila de atendimento (RF11).
5. Sistema transfere todo o histórico do chat para o painel administrativo do Atendente.
6. Atendente recebe notificação visual/sonora de nova solicitação na fila.
7. Atendente aceita a conversa e continua o atendimento no mesmo chat.
8. Cliente recebe notificação de que está falando com um atendente humano.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Nenhum Atendente Disponível | Sistema enfileira o cliente e exibe estimativa de tempo de espera; cliente pode abandonar ou aguardar. |
| **FA02** | Cliente Abandona Fila | Sistema registra o abandono e oferece opção de retomar conversa via chat ou deixar mensagem. |
| **FA03** | Histórico não Sincronizou | Sistema tenta ressincronizar; se falhar, exibe aviso ao Atendente para reler o histórico manualmente. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Extend** | Pode ser disparado por UC01 — Realizar Venda (FA04) |
| **Extend** | Pode ser disparado por UC05 — Validar Receita Médica |
| **Include** | UC11 — Gestão de Fila de Conversas (painel do Atendente) |

### Diagrama de Atividades

<img width="427" height="587" alt="image" src="https://github.com/user-attachments/assets/154aa6d2-989c-4003-9cb6-1a356d5a1c00" />

---

## UC05 — Validar Receita Médica

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente, Farmacêutico, Sistema |
| **Descrição** | Gerencia o fluxo de envio, recebimento e validação de receitas médicas para medicamentos controlados (com retenção), garantindo conformidade regulatória e segurança na venda. |
| **Pré-condições** | Cliente selecionou medicamento controlado (RN04); Cliente enviou imagem de receita via chat (RF06); Farmacêutico autenticado (UC10). |
| **Pós-condições** | Receita validada ou rejeitada; Dados críticos persistidos no banco de dados (RN05, RN06); Cliente notificado do resultado. |
| **RFs relacionados** | RF06, RF13 |
| **RNs relacionadas** | RN04, RN05, RN06 |
| **RNFs relacionados** | RNF15 |

### Fluxo Principal

1. Cliente navega no catálogo ou chat e seleciona um medicamento controlado.
2. Sistema detecta a necessidade de receita (marcação no cadastro do produto).
3. Sistema solicita ao cliente envio de imagem da receita médica via chat (RF06).
4. Cliente fotografa/envia a receita em formato JPEG ou PNG.
5. Sistema armazena a imagem em bucket privado com URL temporária assinada (RNF08).
6. Sistema enfileira a validação para o painel do Farmacêutico (RF13).
7. Farmacêutico acessa o painel administrativo e visualiza a receita ampliada.
8. Farmacêutico verifica:
   - Legibilidade e integridade da imagem (RNF15 — 95% de confiança mínima);
   - Assinatura e carimbagem do médico;
   - Validade da receita;
   - CRM e UF do médico prescritor;
   - Correspondência entre medicamento solicitado e o descrito na receita.
9. Farmacêutico aprova ou reprova a venda via botão na tela.
10. Sistema persiste os dados críticos: CPF do comprador, CRM do validador, CRM e UF do prescritor, imagem da receita, log completo do chat (RN05, RN06).
11. Sistema notifica o cliente do resultado via push (RN13).
12. Se aprovada: Cliente pode finalizar a compra (continua UC01).
13. Se reprovada: Sistema exibe motivo ao cliente e oferece opção de reenviar receita ou contatar suporte.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Receita Ilegível | Farmacêutico reprova; sistema notifica cliente a reenviar com melhor qualidade. |
| **FA02** | Medicamento Não Consta na Receita | Farmacêutico reprova; cliente informado de divergência. |
| **FA03** | Receita Expirada | Farmacêutico reprova; cliente deve obter nova prescrição. |
| **FA04** | CRM do Médico Inválido | Farmacêutico reprova; cliente deve validar prescritor com médico. |
| **FA05** | Cliente Não Envia Receita | Sistema aguarda por X horas; após timeout, cancela a tentativa e remove o item do carrinho. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Extend** | Pode ser disparado por UC01 — Realizar Venda (se medicamento controlado) |
| **Extend** | Dispara UC04 — Realizar Transbordo (se Farmacêutico precisar de esclarecimento) |
| **Include** | Faz parte de UC06 — Persistir Dados de Auditoria |

### Diagrama de Atividades

<img width="594" height="519" alt="image" src="https://github.com/user-attachments/assets/fe6cb68f-303d-4871-88e2-d4affa700f2c" />

---

## UC06 — Persistir Dados de Auditoria

| Campo | Descrição |
|---|---|
| **Ator(es)** | Sistema (Automático) |
| **Descrição** | Registra de forma imutável e criptografada todos os dados críticos de uma venda (incluindo receitas, validações, dados do cliente e log completo do chat) no banco de dados, garantindo conformidade regulatória e rastreabilidade. |
| **Pré-condições** | Venda finalizada (UC01) ou validação de receita concluída (UC05). |
| **Pós-condições** | Dados persistidos em banco de dados com criptografia AES-256 (RNF06); Imagens armazenadas em bucket privado (RNF08); Auditoria registrada para compliance. |
| **RFs relacionados** | RF15 |
| **RNs relacionadas** | RN05, RN06 |
| **RNFs relacionados** | RNF05, RNF06, RNF08 |

### Fluxo Principal

1. Venda é finalizada (UC01) ou validação de receita é concluída (UC05).
2. Sistema coleta os dados críticos obrigatórios (RN05):
   - Identificação do(s) Produto(s) (ID, nome, quantidade, preço);
   - CPF do comprador;
   - Data e hora exata da venda (timestamp);
   - Imagem da receita médica (se aplicável);
   - CRM do Farmacêutico responsável pela validação (se aplicável);
   - UF e CRM do Médico prescritor (se aplicável);
   - Log completo do chat contendo toda a conversa da venda.
3. Sistema encripta dados sensíveis (CPF, imagem de receita) com AES-256 (RNF06).
4. Sistema armazena a imagem em bucket privado (RNF08) e registra a URI assinada no banco de dados.
5. Sistema persiste via API no Banco de Dados em uma transação atômica.
6. Sistema registra timestamp da persistência e hash de integridade.
7. Sistema registra log de auditoria indicando usuário, ação e data.
8. Sistema retorna confirmação ao módulo de venda.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Falha na Persistência | Sistema tenta reenviar até 3 vezes; se falhar, dispara alerta ao administrador e bloqueia a venda. |
| **FA02** | Bucket de Imagens Indisponível | Sistema armazena a imagem em espera local e tenta sincronizar periodicamente. |
| **FA03** | Dados Sensíveis Corrompidos | Sistema registra o erro, notifica o administrador e solicita reenvio dos dados do cliente. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | Faz parte do UC01 — Realizar Venda |
| **Include** | Faz parte do UC05 — Validar Receita Médica |

### Diagrama de Atividades

<img width="594" height="569" alt="image" src="https://github.com/user-attachments/assets/61ce0412-d902-49ff-9860-c65b698e8a8a" />

---

## UC07 — Gerenciar Unidade

| Campo | Descrição |
|---|---|
| **Ator(es)** | Gerente, Dono |
| **Descrição** | Permite ao Gerente ou Dono da unidade configurar parâmetros operacionais e de logística, como raio de entrega, horários de funcionamento, formas de pagamento disponíveis e regulações específicas da unidade. |
| **Pré-condições** | Usuário autenticado com perfil Gerente ou Dono (UC10); Unidade vinculada ao usuário (UC14). |
| **Pós-condições** | Configurações persistidas no banco de dados; Aplicadas imediatamente ao módulo de checkout (RNF04). |
| **RFs relacionados** | RF14, RF18 |
| **RNs relacionadas** | RN12 |
| **RNFs relacionados** | RNF04 |

### Fluxo Principal

1. Gerente acessa o módulo de "Configurações da Unidade".
2. Sistema exibe os parâmetros atuais agrupados por categoria:
   - **Logística:** Raio de entrega (km), endereço da unidade, horários de funcionamento;
   - **Pagamento:** Formas ativas (PIX, dinheiro, cartão na entrega);
   - **Estoque:** Reposição mínima de itens críticos;
   - **Regulação:** Políticas locais de medicamentos controlados.
3. Gerente seleciona um parâmetro a alterar e informa o novo valor.
4. Sistema valida o valor dentro dos limites permitidos (ex: raio ≥ 1 km e ≤ 50 km).
5. Sistema persiste a configuração no banco de dados.
6. Sistema aplica imediatamente à regra de checkout (RN12 — restrição de raio).
7. Sistema registra o log da alteração para auditoria.
8. Sistema notifica todos os usuários da unidade sobre a mudança.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Valor Fora do Limite | Sistema exibe a faixa de valores aceitos e solicita nova entrada. |
| **FA02** | Falha na Persistência | Sistema registra o erro e reverte para a configuração anterior. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | UC14 — Gerenciar Acessos e Perfis (controle de acesso) |

### Diagrama de Atividades

<img width="427" height="587" alt="image" src="https://github.com/user-attachments/assets/154aa6d2-989c-4003-9cb6-1a356d5a1c00" />

---

## UC08 — Processar Pagamento e Confirmar Recebimento

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente, Sistema (Automático), Entregador, Atendente |
| **Descrição** | Gerencia o fluxo de pagamento, desde a geração da chave PIX até a confirmação final via webhook bancário ou baixa manual do entregador, garantindo integridade financeira e rastreabilidade. |
| **Pré-condições** | Venda finalizada com valores confirmados (UC01); Cliente selecionou forma de pagamento (RF07, RF08). |
| **Pós-condições** | Pagamento validado ou rejeitado; Pedido avançado para próxima etapa de separação/entrega; Comprovante de pagamento gerado. |
| **RFs relacionados** | RF07, RF08 |
| **RNs relacionadas** | RN08, RN09, RN10 |

### Fluxo Principal

#### Via PIX (RN08, RN09)
1. Cliente seleciona PIX como forma de pagamento.
2. Sistema gera chave PIX dinâmica via banco integrado.
3. Sistema exibe QR Code e chave para cópia na interface de chat.
4. Sistema inicia timer de 10 minutos para expiração da chave (RN08).
5. Cliente realiza a transferência PIX (fora do app).
6. Banco envia webhook ao backend confirmando a transação.
7. Sistema valida o webhook (origem, assinatura, montante).
8. Se válido: Sistema marca o pedido como "Pagamento Aprovado" e avança para separação.
9. Se expirado (após 10 min): Sistema cancela o pedido, libera o estoque (RN08) e notifica o cliente.

#### Via Pagamento Presencial (RN09)
1. Cliente seleciona "Pagar na Entrega" (dinheiro ou cartão).
2. Sistema marca o pedido como "Aguardando Pagamento Presencial".
3. Entregador recebe a ordem e realiza a entrega.
4. Após receber o valor, Entregador confirma o pagamento via App (baixa manual).
5. Sistema registra o pagamento confirmado e finaliza o pedido.
6. Se Entregador não confirmar em 24 horas: Sistema retorna pedido ao status "Aguardando Pagamento".

#### Preço Imutável (RN10)
1. No momento da finalização, o preço de cada item é registrado no banco de dados.
2. Alterações posteriores no cadastro de produtos não afetam pedidos já concluídos.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | PIX Expirou Sem Confirmação | Sistema cancela pedido, libera estoque e oferece opção de gerar nova chave. |
| **FA02** | Webhook Bancário Falho | Sistema tenta reconfirmar por até 3 vezes; se falhar, administrador é notificado para investigação. |
| **FA03** | Pagamento Presencial Não Confirmado em 24h | Sistema retorna pedido a "Aguardando Pagamento" e notifica o Entregador. |
| **FA04** | Montante Incorreto no PIX | Sistema rejeita e solicita novo pagamento com valor correto. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | Faz parte do UC01 — Realizar Venda |

### Diagrama de Atividades

<img width="594" height="519" alt="image" src="https://github.com/user-attachments/assets/fe6cb68f-303d-4871-88e2-d4affa700f2c" />

---

## UC09 — Analisar Performance e Auditoria (BI)

| Campo | Descrição |
|---|---|
| **Ator(es)** | Gerente, Dono |
| **Descrição** | Exibe dashboards de inteligência de negócio (BI) com indicadores de faturamento, ticket médio, taxa de recorrência de clientes e tendências de vendas, permitindo decisões estratégicas baseadas em dados. |
| **Pré-condições** | Usuário autenticado com perfil Gerente ou Dono (UC10); Dados de vendas persistidos no banco (UC06). |
| **Pós-condições** | Relatórios e gráficos exibidos em tempo real (sincronizados a cada 5 min); Exportação de dados disponível em PDF/Excel. |
| **RFs relacionados** | RF16, RF17 |
| **RNs relacionadas** | RN11 |

### Fluxo Principal

1. Usuário com perfil Gerente ou Dono acessa a seção "Relatórios e BI".
2. Sistema exibe dashboard com os seguintes indicadores (RF17):
   - **Faturamento Total:** Soma de todas as vendas no período selecionado;
   - **Ticket Médio:** Valor médio de compra por cliente;
   - **Taxa de Recorrência:** Percentual de clientes que realizaram mais de uma compra;
   - **Produtos Mais Vendidos:** Ranking com quantidade e faturamento;
   - **Forma de Pagamento:** Distribuição PIX vs. Presencial;
   - **Medicamentos Controlados:** Volume de receitas validadas.
3. Sistema oferece filtros:
   - Período (data inicial e final);
   - Unidade (se Dono) ou apenas sua unidade (se Gerente — RN11);
   - Categoria de produto.
4. Usuário seleciona os filtros e clica em "Atualizar".
5. Sistema calcula os indicadores em tempo real (máx. 5 segundos).
6. Sistema exibe gráficos interativos (linha, barra, pizza).
7. Usuário pode exportar o relatório em PDF ou Excel via botão de download.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Nenhum Dado no Período | Sistema exibe mensagem informativa "Sem dados disponíveis" e sugere expandir o período. |
| **FA02** | Cálculo Muito Lento | Sistema exibe mensagem de "Carregando..." e oferece opção de reduzir período ou unidades. |
| **FA03** | Gerente Tenta Acessar Dados de Outra Unidade | Sistema bloqueia e exibe apenas dados de sua unidade (RN11). |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | UC14 — Gerenciar Acessos e Perfis (controle por hierarquia) |

### Diagrama de Atividades

<img width="594" height="569" alt="image" src="https://github.com/user-attachments/assets/61ce0412-d902-49ff-9860-c65b698e8a8a" />

---

## UC10 — Autenticar Usuário

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente, Atendente, Farmacêutico, Gerente, Dono |
| **Descrição** | Realiza autenticação segura com e-mail e senha, emite token JWT com tempo de expiração diferenciado por perfil, e mantém a sessão ativa enquanto o token for válido. |
| **Pré-condições** | Usuário com cadastro ativo no sistema; Conexão HTTPS disponível. |
| **Pós-condições** | Token JWT gerado e armazenado localmente; Usuário autenticado com acesso às funcionalidades de seu perfil. |
| **RFs relacionados** | RF01 |
| **RNs relacionadas** | — |
| **RNFs relacionados** | RNF05, RNF07 |

### Fluxo Principal

1. Usuário acessa a tela de Login.
2. Usuário insere e-mail e senha.
3. Sistema valida as credenciais contra o banco de dados.
4. Se válido:
   - Sistema gera um token JWT com tempo de expiração diferenciado (RNF07):
     - **Clientes:** 24 horas;
     - **Colaboradores (Atendente, Farmacêutico, Gerente, Dono):** 8 horas.
   - Sistema armazena o token localmente no dispositivo.
   - Sistema redireciona para a tela principal ou dashboard.
5. Se inválido:
   - Sistema exibe mensagem de erro "E-mail ou senha incorretos";
   - Usuário pode tentar novamente ou acessar "Esqueceu a Senha".
6. Token é validado a cada requisição via HTTPS (RNF05).
7. Ao expirar, sistema força o usuário a fazer login novamente.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Usuário Bloqueado | Sistema identifica múltiplas tentativas falhas e bloqueia a conta por 30 minutos; exibe alerta de segurança. |
| **FA02** | Esqueceu a Senha | Usuário clica em "Esqueceu a Senha"; sistema envia e-mail com link de reset (válido por 1 hora). |
| **FA03** | Token Expirado em Sessão | Sistema detecta expiração, limpa o token local e redireciona para tela de login. |
| **FA04** | Conexão HTTPS Indisponível | Sistema bloqueia a autenticação e exibe mensagem de erro de segurança. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | Pré-condição para todos os demais casos de uso |

### Diagrama de Atividades

<img width="594" height="569" alt="image" src="https://github.com/user-attachments/assets/61ce0412-d902-49ff-9860-c65b698e8a8a" />

---

## UC11 — Gerenciar Perfil e Conta

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente |
| **Descrição** | Permite ao cliente visualizar e editar seus dados cadastrais, acessar histórico de compras, gerenciar endereços de entrega e preferências de notificação. |
| **Pré-condições** | Usuário autenticado (UC10); Cadastro ativo no sistema. |
| **Pós-condições** | Dados atualizados no banco de dados; Alterações aplicadas imediatamente. |
| **RFs relacionados** | RF10 |
| **RNs relacionadas** | — |
| **RNFs relacionados** | RNF06 |

### Fluxo Principal

1. Cliente acessa a seção "Minha Conta" ou "Perfil".
2. Sistema exibe os dados cadastrais: Nome, E-mail, Telefone, CPF (parcialmente mascarado), Endereço.
3. Cliente pode:
   - **Editar Dados:** Clica em "Editar", altera nome, telefone ou endereço, e salva.
   - **Histórico de Compras:** Acessa lista de compras anteriores com data, itens e valor.
   - **Endereços de Entrega:** Adiciona, edita ou remove endereços secundários.
   - **Notificações:** Ativa/desativa notificações push de status e promoções.
4. Sistema valida os dados e persiste no banco de dados com criptografia (RNF06).
5. Sistema exibe confirmação de alteração.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Dados Incompletos | Sistema sinaliza campos obrigatórios e impede salvar sem preenchê-los. |
| **FA02** | E-mail Já Cadastrado | Sistema exibe alerta e solicita um e-mail diferente ou confirmação de vinculação. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | UC10 — Autenticar Usuário (pré-condição) |

### Diagrama de Atividades

<img width="427" height="587" alt="image" src="https://github.com/user-attachments/assets/154aa6d2-989c-4003-9cb6-1a356d5a1c00" />

---

## UC12 — Rastrear Pedido em Tempo Real

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente, Sistema (Automático) |
| **Descrição** | Exibe o status atual do pedido e histórico de atualizações em tempo real, incluindo confirmação de pagamento, separação, saída para entrega e entrega concluída. |
| **Pré-condições** | Pedido criado (UC01); Cliente autenticado (UC10). |
| **Pós-condições** | Cliente acompanha pedido até entrega; Notificações push disparadas em cada mudança de status (RN13). |
| **RFs relacionados** | RF09 |
| **RNs relacionadas** | RN13 |
| **RNFs relacionados** | RNF04 |

### Fluxo Principal

1. Cliente acessa a seção "Meus Pedidos" ou "Rastreamento".
2. Sistema lista todos os pedidos do cliente com status atual.
3. Cliente seleciona um pedido para ver detalhes.
4. Sistema exibe:
   - **Número do Pedido** e **Data**;
   - **Status Atual** (Pagamento Pendente, Pagamento Aprovado, Em Separação, Saiu para Entrega, Entregue);
   - **Timeline Visual** mostrando cada mudança de status e hora;
   - **Detalhes da Entrega** (endereço, previsão de chegada, contato do entregador);
   - **Items do Pedido** com quantidades e preços unitários (imutáveis — RN10).
5. Sistema sincroniza a cada 10 segundos com o backend (RNF04).
6. A cada mudança de status, sistema dispara notificação push ao cliente (RN13 — UC16).

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Pedido Ainda Não Iniciado | Sistema exibe "Processando pagamento..." e oferece opção de gerar nova chave PIX se expirada. |
| **FA02** | Entrega Atrasada | Sistema exibe alerta visual e oferece opção de contatar suporte ou entregador via chat. |
| **FA03** | Sem Conexão | App enfileira sincronizações localmente e atualiza assim que restabelecida (RNF13). |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | UC16 — Receber e Processar Notificação Push |

### Diagrama de Atividades

<img width="594" height="569" alt="image" src="https://github.com/user-attachments/assets/61ce0412-d902-49ff-9860-c65b698e8a8a" />

---

## UC13 — Configurar e Gerenciar IA

| Campo | Descrição |
|---|---|
| **Ator(es)** | Administrador |
| **Descrição** | Permite ao Administrador configurar parâmetros da IA (gatilhos de transbordo, base de conhecimento, modelos de geração de texto para cadastro) e gerenciar o comportamento dos fluxos de atendimento automatizado. |
| **Pré-condições** | Usuário autenticado com perfil Administrador (UC10). |
| **Pós-condições** | Novos parâmetros persistidos e aplicados ao comportamento da IA em tempo real. |
| **RFs relacionados** | RF03, RF05 |
| **RNs relacionadas** | RN01, RN02, RN03 |
| **RNFs relacionados** | RNF02, RNF15, RNF16 |

### Fluxo Principal

1. Administrador acessa o módulo de "Configurações da IA".
2. Sistema exibe os parâmetros atuais agrupados por categoria:
   - **Comportamento de Atendimento:** Tempo máximo de resposta (máx. 5 seg — RNF02); Tom de comunicação;
   - **Gatilhos de Transbordo:** Número de tentativas da IA antes de acionar UC04 (RN01, RN02); Palavras-chave que disparam transbordo automático;
   - **Base de Conhecimento:** Links para FAQs, posologias e informações de medicamentos;
   - **Geração de Descrições (Cadastro):** Configuração de IA generativa para auto-gerar descrições e tags de produtos (RN03; RNF15).
3. Administrador seleciona o parâmetro a alterar e informa o novo valor.
4. Sistema valida o valor dentro dos limites permitidos (ex: tempo de resposta ≤ 5 seg).
5. Sistema persiste a configuração e aplica ao módulo de IA (RNF16 — sem impacto nas funções vitais de catálogo/checkout).
6. Sistema registra o log da alteração para auditoria.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Valor Fora do Limite | Sistema exibe a faixa de valores aceitos e solicita nova entrada. |
| **FA02** | Falha na Aplicação do Parâmetro | Sistema registra o erro, reverte para configuração anterior e notifica o Administrador. |
| **FA03** | IA Generativa Produzindo Alucinações | Administrador reduz o limiar de confiança (RNF15) ou desativa a funcionalidade. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Extend** | Impacta diretamente o comportamento do UC01 — Realizar Venda (fluxo de chat) |
| **Extend** | Impacta o UC04 — Realizar Transbordo (gatilhos) |
| **Include** | UC14 — Gerenciar Acessos e Perfis (acesso restrito ao Administrador) |

### Diagrama de Atividades

<img width="427" height="587" alt="image" src="https://github.com/user-attachments/assets/154aa6d2-989c-4003-9cb6-1a356d5a1c00" />

---

## UC14 — Gerenciar Acessos e Perfis (RBAC)

| Campo | Descrição |
|---|---|
| **Ator(es)** | Administrador |
| **Descrição** | Permite ao Administrador criar, editar, suspender e revogar perfis de usuários colaboradores, definindo as permissões de acesso a telas e funcionalidades conforme a hierarquia RBAC do sistema. |
| **Pré-condições** | Usuário autenticado com perfil Administrador (UC10). |
| **Pós-condições** | Permissões do usuário atualizadas e aplicadas imediatamente na próxima sessão do colaborador. |
| **RFs relacionados** | — |
| **RNs relacionadas** | RN11 |
| **RNFs relacionados** | RNF07 |

### Fluxo Principal

1. Administrador acessa o módulo de "Controle de Acessos".
2. Sistema lista todos os usuários colaboradores com nome, perfil e status (ativo/suspenso).
3. Administrador seleciona um usuário ou cria um novo.
4. Administrador define ou altera o perfil de acesso (RN11):
   - **Atendente:** Acesso ao chat nativo, histórico de clientes (UC02), catálogo e fila de conversas;
   - **Farmacêutico:** Tudo do Atendente + validação de receitas (UC05) + seleção de pagamento presencial;
   - **Gerente:** Tudo do Farmacêutico + relatórios de sua unidade (UC09) + configurações da unidade (UC07);
   - **Dono:** Tudo do Gerente + dashboards globais de todas as unidades (faturamento total, análise consolidada).
5. Sistema salva a configuração e invalida o token atual do colaborador (se ativo), forçando novo login (RNF07).

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Suspender Usuário | Administrador suspende o acesso; sistema invalida a sessão ativa imediatamente. |
| **FA02** | Rebaixar Perfil | Sistema invalida a sessão ativa após rebaixamento, forçando novo login com novas permissões. |
| **FA03** | Tentativa de Auto-Edição | Sistema impede que o Administrador altere seu próprio perfil para evitar bloqueio acidental. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | UC10 — Autenticar Usuário (pré-condição) |
| **Extend** | Controla o acesso ao UC07, UC09, UC13 e UC17 |

### Diagrama de Atividades

<img width="594" height="519" alt="image" src="https://github.com/user-attachments/assets/fe6cb68f-303d-4871-88e2-d4affa700f2c" />

---

## UC15 — Navegar no Catálogo e Consultar Produto

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente |
| **Descrição** | Permite ao cliente navegar pelo catálogo de produtos, filtrar por categorias, realizar buscas por texto e consultar detalhes individuais de um produto (foto, descrição, preço e disponibilidade), de forma independente do fluxo de venda. |
| **Pré-condições** | Usuário autenticado (UC10); Catálogo com produtos cadastrados. |
| **Pós-condições** | Produto consultado; Cliente pode iniciar uma compra a partir do catálogo ou do chat. |
| **RFs relacionados** | RF02 |
| **RNFs relacionados** | RNF01, RNF09, RNF10 |

### Fluxo Principal

1. Cliente acessa a tela inicial do app (após UC10).
2. Sistema exibe o catálogo de produtos organizados por categorias com foto, nome, preço e indicador de estoque.
3. Cliente navega por categorias ou utiliza a busca por texto (nome, fabricante, código).
4. Sistema retorna os resultados filtrando em tempo real (60 FPS — RNF01; Material Design 3 — RNF10).
5. Cliente seleciona um produto para ver o detalhe.
6. Sistema exibe a tela do produto com:
   - Foto ampliada e zoom;
   - Descrição completa (potencialmente gerada pela IA — UC13);
   - Preço atual (RN10);
   - Indicação de disponibilidade em estoque;
   - Componentes principais e modo de uso.
7. Cliente pode iniciar a compra pelo botão "Comprar via Chat" ou retornar ao catálogo.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Nenhum Produto Encontrado | Sistema exibe mensagem informativa e sugere termos similares ou categorias relacionadas. |
| **FA02** | Produto Sem Estoque | Sistema exibe o produto com indicação visual de "Indisponível" e oculta o botão de compra. |
| **FA03** | Conexão Lenta | Sistema exibe imagens em baixa resolução inicialmente e carrega em alta resolução quando a conexão melhorar. |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Extend** | Pode iniciar o UC01 — Realizar Venda (via botão "Comprar via Chat") |
| **Include** | UC03 — Consultar e Verificar Estoque (indicador de disponibilidade) |

### Diagrama de Atividades

<img width="594" height="569" alt="image" src="https://github.com/user-attachments/assets/61ce0412-d902-49ff-9860-c65b698e8a8a" />

---

## UC16 — Receber e Processar Notificação Push

| Campo | Descrição |
|---|---|
| **Ator(es)** | Cliente, Sistema (Automático) |
| **Descrição** | Gerencia o recebimento de notificações push pelo dispositivo do cliente e o comportamento do app ao interagir com elas, redirecionando o usuário para a tela correta conforme o tipo de evento. |
| **Pré-condições** | Permissão de notificação push concedida pelo cliente no dispositivo (UC10); Evento disparado no backend (mudança de status, mensagem de chat, receita reprovada). |
| **Pós-condições** | Cliente notificado sobre o evento; App redirecionado para a tela correspondente ao toque na notificação. |
| **RFs relacionados** | — |
| **RNs relacionadas** | RN13 |
| **RNFs relacionados** | RNF04 |

### Fluxo Principal

1. O Sistema detecta um evento de mudança de status (pagamento aprovado, separação iniciada, saiu para entrega, entregue, receita reprovada).
2. O Sistema dispara uma notificação push para o dispositivo do cliente via serviço de push (Firebase Cloud Messaging/APNs).
3. O dispositivo do cliente exibe a notificação na barra de status.
4. Cliente toca na notificação.
5. App abre (ou sai do background) e redireciona para a tela correspondente:
   - **Status de pedido** → Tela de Rastreamento (UC12);
   - **Mensagem no chat** → Tela de Chat;
   - **Receita reprovada** → Tela de Chat com a nota do Farmacêutico;
   - **Erro / Expiração de PIX** → Tela de Pagamento com opção de gerar nova chave.

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | Permissão de Push Negada | Sistema registra a preferência; atualizações ficam visíveis apenas na tela de notificações interna do app. |
| **FA02** | App Fechado ao Tocar na Notificação | App inicializa normalmente (UC10) e, após autenticação, redireciona para tela correspondente. |
| **FA03** | Notificação Expirada | Se o evento já foi resolvido, app exibe tela correspondente com status atualizado. |
| **FA04** | Sem Conexão | App enfileira a sincronização localmente e exibe último estado conhecido até restabelecer conexão (RNF04 — máx. 30 seg). |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | Faz parte do UC12 — Rastrear Pedido em Tempo Real |
| **Extend** | Pode ser disparado por UC01 — Realizar Venda, UC05 — Validar Receita, UC08 — Processar Pagamento |

### Diagrama de Atividades

<img width="594" height="330" alt="image" src="https://github.com/user-attachments/assets/dc539536-8fbf-4bba-b8b0-fa6ca8fe39be" />

---

## UC17 — Gerenciar Catálogo de Produtos

| Campo | Descrição |
|---|---|
| **Ator(es)** | Atendente, Gerente, Administrador |
| **Descrição** | Permite aos usuários autorizados cadastrar novos produtos, editar informações (nome, descrição, categoria, preço) e gerenciar estoque, com suporte a IA generativa para auto-gerar descrições e categorias. |
| **Pré-condições** | Usuário autenticado com permissão de catálogo (UC10, UC14); Unidade ou contexto global definido. |
| **Pós-condições** | Produto cadastrado ou atualizado no banco de dados; Alterações sincronizadas em tempo real (RNF04). |
| **RFs relacionados** | RF02, RF14 |
| **RNs relacionadas** | RN03, RN07 |
| **RNFs relacionados** | RNF04, RNF15 |

### Fluxo Principal

1. Atendente/Gerente acessa o módulo "Gerenciar Catálogo".
2. Sistema oferece opções:
   - **Novo Produto:** Clica em "Adicionar Produto";
   - **Editar Existente:** Busca o produto e clica em "Editar".
3. Usuário preenche os campos obrigatórios:
   - Nome do produto;
   - Categoria (dropdown com sugestões da IA — RN03);
   - Preço unitário;
   - Estoque inicial;
   - Foto do produto;
   - Se medicamento controlado: marcar checkbox "Requer Receita".
4. Usuário clica em "Gerar Descrição com IA" (RN03).
5. Sistema chama o motor de IA generativa e:
   - Gera automaticamente a descrição com base no nome e categoria (máx. 5 seg — RNF02);
   - Sugere tags/categorias secundárias;
   - Valida confiança mínima de 95% (RNF15).
6. Usuário revisa a descrição gerada:
   - **Aceita:** Clica em "Usar"; descrição é inserida automaticamente;
   - **Rejeita:** Clica em "Editar Manualmente" e insere texto customizado;
   - **Regenera:** Clica em "Tentar Novamente" para gerar nova versão.
7. Usuário confirma o cadastro/edição.
8. Sistema valida os dados e persiste no banco de dados.
9. Sistema sincroniza as alterações com o catálogo móvel (RNF04 — máx. 30 seg).

### Fluxos Alternativos / Exceções

| ID | Nome | Descrição |
|---|---|---|
| **FA01** | IA Geradora Produz Alucinações | Sistema exibe aviso "Descrição pode conter informações inexatas"; usuário revisa manualmente. |
| **FA02** | Foto Não Atende Padrão | Sistema solicita imagem em formato PNG/JPEG com mínimo 300x300 pixels. |
| **FA03** | Produto Duplicado | Sistema detecta produto com mesmo nome na mesma categoria e alerta o usuário. |
| **FA04** | Sincronização Falhou | Sistema enfileira a alteração e tenta sincronizar em background (RNF04). |

### Relacionamentos

| Tipo | Casos de Uso |
|---|---|
| **Include** | UC14 — Gerenciar Acessos e Perfis (controle de permissão) |
| **Include** | UC13 — Configurar e Gerenciar IA (motor de geração de descrições) |
| **Extend** | Afeta UC15 — Navegar no Catálogo (dados exibidos) |

### Diagrama de Atividades

<img width="594" height="569" alt="image" src="https://github.com/user-attachments/assets/61ce0412-d902-49ff-9860-c65b698e8a8a" />

---

> **Diretriz de Implementação:** Todas as regras de negócio devem ser validadas tanto na camada de interface (Flutter) para melhor UX quanto na camada de serviços (Backend) para garantir a integridade dos dados. Referência: RNs e RNFs deste documento.


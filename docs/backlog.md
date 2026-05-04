# Backlog do Produto — Farmácia Americana App

> Backlog inicial revisado com base no projeto atual, considerando o que faz sentido para o produto, o que já existe parcialmente no app e o que ainda pode ser evoluído.

---

## Estrutura do Backlog

| Épico | Nome | Domínio |
|---|---|---|
| EP01 | Acesso e Conta | Cadastro, login, sessão e perfil |
| EP02 | Catálogo e Descoberta | Produtos, categorias, busca e detalhes |
| EP03 | Atendimento pelo Chat | Fluxo por opções, anexos e transbordo humano |
| EP04 | Carrinho e Checkout | Carrinho, entrega/retirada e pagamento |
| EP05 | Pedidos e Acompanhamento | Histórico, status e rastreamento |
| EP06 | Painel de Atendimento | Conversas, consulta de cliente e suporte operacional |
| EP07 | Gestão de Produtos e Estoque | Cadastro, edição e controle de estoque |
| EP08 | Indicadores e Gestão | BI, relatórios e visão gerencial |

---

## EP01 — Acesso e Conta

> Cobre autenticação, sessão, perfil do usuário e dados cadastrais.

### US01.1 — Cadastro de cliente

**Como** cliente,  
**quero** criar uma conta com nome, e-mail e senha,  
**para que** eu possa acessar o app e realizar pedidos.

**Critérios de Aceitação:**
- O sistema deve permitir cadastro com nome, e-mail e senha.
- O e-mail deve ser validado antes da conclusão do cadastro.
- O sistema deve impedir cadastro duplicado com o mesmo e-mail.
- Após cadastro válido, o usuário deve conseguir acessar o sistema.

---

### US01.2 — Login no sistema

**Como** usuário cadastrado,  
**quero** entrar com meu e-mail e senha,  
**para que** eu acesse minhas funcionalidades no app.

**Critérios de Aceitação:**
- O sistema deve autenticar usuários com e-mail e senha.
- Em caso de erro, deve exibir mensagem de credenciais inválidas.
- Após login, o usuário deve ser redirecionado conforme seu perfil.
- A sessão deve permanecer ativa até logout ou expiração.

---

### US01.3 — Direcionamento por perfil

**Como** usuário autenticado,  
**quero** ser direcionado para a área correta do sistema,  
**para que** eu acesse apenas as funções do meu perfil.

**Critérios de Aceitação:**
- Cliente deve acessar a área do app cliente.
- Atendente e farmacêutico devem acessar a área de atendimento.
- Gerente e administrador devem acessar a área gerencial.
- O sistema não deve exibir rotas incompatíveis com o perfil ativo.

---

### US01.4 — Editar dados pessoais

**Como** usuário autenticado,  
**quero** atualizar meus dados cadastrais,  
**para que** minhas informações permaneçam corretas.

**Critérios de Aceitação:**
- O sistema deve permitir editar ao menos nome e e-mail.
- O sistema deve validar os dados antes de salvar.
- O sistema deve persistir as alterações no banco.
- O usuário deve receber feedback após salvar.

---

### US01.5 — Alterar senha

**Como** usuário autenticado,  
**quero** alterar minha senha,  
**para que** eu mantenha minha conta segura.

**Critérios de Aceitação:**
- O sistema deve solicitar senha atual, nova senha e confirmação.
- O sistema deve validar se a confirmação coincide.
- O sistema deve impedir alteração com senha atual incorreta.
- Após alteração, o usuário deve receber mensagem de sucesso.

---

## EP02 — Catálogo e Descoberta

> Cobre visualização, busca, filtro e detalhe dos produtos.

### US02.1 — Visualizar catálogo de produtos

**Como** cliente,  
**quero** visualizar os produtos disponíveis no app,  
**para que** eu encontre itens de interesse.

**Critérios de Aceitação:**
- O catálogo deve exibir nome, preço, imagem e categoria dos produtos.
- Apenas produtos ativos devem ser exibidos.
- O carregamento deve buscar os dados no repositório oficial do app.
- Em caso de falha, o sistema deve informar erro de carregamento.

---

### US02.2 — Navegar por categorias

**Como** cliente,  
**quero** explorar produtos por categoria,  
**para que** eu encontre itens com mais facilidade.

**Critérios de Aceitação:**
- O sistema deve listar categorias disponíveis.
- Ao selecionar uma categoria, os produtos devem ser filtrados.
- O usuário deve poder voltar à visão completa do catálogo.
- A atualização da lista deve ocorrer sem sair da tela.

---

### US02.3 — Buscar produtos

**Como** cliente,  
**quero** pesquisar produtos por texto,  
**para que** eu localize rapidamente um item específico.

**Critérios de Aceitação:**
- A busca deve considerar ao menos o nome do produto.
- A lista deve ser filtrada conforme o texto informado.
- O sistema deve permitir limpar a busca.
- Quando não houver resultado, deve exibir estado vazio.

---

### US02.4 — Visualizar detalhes do produto

**Como** cliente,  
**quero** abrir a tela de detalhes de um produto,  
**para que** eu veja mais informações antes de comprar.

**Critérios de Aceitação:**
- A tela deve exibir nome, descrição, preço e imagem.
- O sistema deve indicar informações básicas de categoria.
- O cliente deve poder iniciar a ação de compra a partir da tela.
- A navegação deve preservar o contexto do catálogo.

---

## EP03 — Atendimento pelo Chat

> Cobre o atendimento automatizado por opções, anexos e encaminhamento para humano.

### US03.1 — Iniciar atendimento no chat

**Como** cliente,  
**quero** abrir um chat de atendimento,  
**para que** eu receba orientação dentro do app.

**Critérios de Aceitação:**
- O chat deve iniciar com uma mensagem de boas-vindas.
- O sistema deve apresentar opções iniciais de atendimento.
- O fluxo deve orientar o cliente por categorias de assunto.
- O histórico da conversa deve permanecer visível na tela.

---

### US03.2 — Avançar por opções no chat

**Como** cliente,  
**quero** navegar pelo atendimento escolhendo opções,  
**para que** eu resolva minha necessidade sem digitação obrigatória.

**Critérios de Aceitação:**
- Cada opção deve levar a uma próxima etapa do fluxo.
- O sistema deve registrar a escolha do cliente na conversa.
- O fluxo deve permitir retorno ao menu principal.
- O sistema deve manter a consistência do estado da conversa.

---

### US03.3 — Solicitar atendimento humano

**Como** cliente,  
**quero** pedir atendimento humano pelo chat,  
**para que** uma pessoa assuma minha conversa quando necessário.

**Critérios de Aceitação:**
- O fluxo deve oferecer a opção de falar com humano.
- O sistema deve informar quando a conversa foi transferida.
- Após a transferência, o chat deve aceitar entrada manual.
- O histórico anterior deve permanecer disponível.

---

### US03.4 — Enviar arquivos no chat

**Como** cliente,  
**quero** enviar imagens ou documentos no chat,  
**para que** eu complemente o atendimento com anexos.

**Critérios de Aceitação:**
- O sistema deve permitir anexar imagem ou documento.
- O sistema deve validar o tipo de arquivo aceito.
- O anexo deve aparecer como mensagem na conversa.
- Caso o acesso ao arquivo falhe, o sistema deve informar o erro.

---

### US03.5 — Registrar recado ou solicitação de retorno

**Como** cliente,  
**quero** deixar recado ou solicitar retorno,  
**para que** eu continue o atendimento mesmo fora do horário.

**Critérios de Aceitação:**
- O fluxo deve permitir registrar um recado.
- O fluxo deve permitir solicitar retorno com contato.
- O sistema deve confirmar o registro para o usuário.
- O cliente deve poder voltar ao menu principal após o registro.

---

## EP04 — Carrinho e Checkout

> Cobre seleção de produtos, resumo da compra e confirmação do pedido.

### US04.1 — Adicionar produto ao carrinho

**Como** cliente,  
**quero** adicionar produtos ao carrinho,  
**para que** eu reúna os itens antes de finalizar a compra.

**Critérios de Aceitação:**
- O cliente deve conseguir adicionar item pelo catálogo ou detalhe.
- O carrinho deve atualizar quantidade e subtotal.
- O sistema deve manter os itens adicionados durante a sessão.
- O usuário deve receber feedback após a adição.

---

### US04.2 — Gerenciar itens do carrinho

**Como** cliente,  
**quero** alterar quantidades e remover itens do carrinho,  
**para que** eu ajuste meu pedido antes da compra.

**Critérios de Aceitação:**
- O sistema deve permitir incrementar quantidade.
- O sistema deve permitir decrementar quantidade.
- O sistema deve permitir remover item.
- O valor total deve ser recalculado a cada alteração.

---

### US04.3 — Escolher forma de recebimento

**Como** cliente,  
**quero** escolher entre entrega e retirada,  
**para que** eu receba o pedido da forma mais conveniente.

**Critérios de Aceitação:**
- O checkout deve permitir selecionar entrega ou retirada.
- Em entrega, o sistema deve usar um endereço selecionado.
- Em retirada, o sistema deve exibir a unidade definida.
- O resumo da compra deve refletir a escolha.

---

### US04.4 — Escolher forma de pagamento

**Como** cliente,  
**quero** escolher a forma de pagamento do pedido,  
**para que** eu conclua a compra conforme minha preferência.

**Critérios de Aceitação:**
- O sistema deve oferecer Pix, dinheiro e cartão na entrega.
- A forma escolhida deve ser exibida no resumo.
- O total final deve refletir regras de pagamento aplicáveis.
- O pedido deve ser salvo com a forma de pagamento selecionada.

---

### US04.5 — Finalizar pedido

**Como** cliente,  
**quero** confirmar o checkout,  
**para que** meu pedido seja criado no sistema.

**Critérios de Aceitação:**
- O sistema deve montar os itens e dados do pedido.
- O pedido deve ser persistido no backend.
- Em caso de sucesso, o sistema deve exibir confirmação.
- Em caso de erro, o sistema deve informar o motivo ao usuário.

---

## EP05 — Pedidos e Acompanhamento

> Cobre listagem, detalhe, histórico e rastreamento do pedido.

### US05.1 — Visualizar lista de pedidos

**Como** cliente,  
**quero** acessar meus pedidos realizados,  
**para que** eu acompanhe meu histórico de compras.

**Critérios de Aceitação:**
- O sistema deve listar pedidos do usuário autenticado.
- A lista deve exibir identificador, data, status e valor.
- Os pedidos mais recentes devem aparecer primeiro.
- O usuário deve poder abrir o detalhe de cada pedido.

---

### US05.2 — Visualizar detalhes do pedido

**Como** cliente,  
**quero** ver os detalhes de um pedido,  
**para que** eu consulte itens, valores e status.

**Critérios de Aceitação:**
- O detalhe deve exibir itens do pedido.
- O detalhe deve exibir total, endereço e forma de pagamento.
- O status atual deve estar visível.
- Quando aplicável, o sistema deve exibir previsão de entrega.

---

### US05.3 — Acompanhar rastreamento

**Como** cliente,  
**quero** acompanhar o andamento da entrega,  
**para que** eu saiba em que etapa meu pedido está.

**Critérios de Aceitação:**
- O sistema deve exibir a linha do tempo do pedido.
- O rastreio deve refletir os estados principais do fluxo.
- O sistema deve exibir tempo estimado quando disponível.
- O cliente deve conseguir abrir o rastreio a partir do pedido.

---

### US05.4 — Visualizar histórico de compras concluídas

**Como** cliente,  
**quero** consultar minhas compras entregues,  
**para que** eu acompanhe meu histórico consolidado.

**Critérios de Aceitação:**
- O sistema deve listar pedidos concluídos/entregues.
- O sistema deve calcular total gasto e total de pedidos.
- O histórico deve ser carregado do repositório de pedidos.
- O sistema deve exibir mensagem em caso de erro de carregamento.

---

## EP06 — Painel de Atendimento

> Cobre visão operacional do atendente e consulta de clientes/conversas.

### US06.1 — Visualizar fila de conversas

**Como** atendente,  
**quero** visualizar as conversas disponíveis no painel,  
**para que** eu acompanhe os atendimentos em andamento.

**Critérios de Aceitação:**
- O painel deve listar clientes em atendimento.
- Cada item deve exibir nome, identificação resumida e referência temporal.
- O atendente deve poder selecionar uma conversa.
- O sistema deve abrir o detalhe da conversa selecionada.

---

### US06.2 — Buscar cliente no painel

**Como** atendente,  
**quero** buscar clientes no painel por nome ou CPF,  
**para que** eu encontre rapidamente o atendimento desejado.

**Critérios de Aceitação:**
- O sistema deve filtrar a lista conforme o texto informado.
- A busca deve considerar nome e CPF.
- Quando o texto for limpo, a lista completa deve voltar.
- O painel não deve exigir recarregamento total da tela para filtrar.

---

### US06.3 — Consultar dados de apoio ao atendimento

**Como** atendente,  
**quero** acessar informações básicas do cliente e do contexto da conversa,  
**para que** eu atenda com mais agilidade.

**Critérios de Aceitação:**
- O sistema deve permitir abrir o detalhe do atendimento.
- O histórico da conversa deve ficar visível.
- O atendente deve conseguir retomar a partir do contexto já registrado.
- O fluxo deve preservar a conversa anterior do cliente.

---

## EP07 — Gestão de Produtos e Estoque

> Cobre cadastro, edição e acompanhamento operacional de produtos.

### US07.1 — Cadastrar produto

**Como** usuário autorizado,  
**quero** cadastrar um novo produto,  
**para que** ele fique disponível no sistema.

**Critérios de Aceitação:**
- O sistema deve permitir informar nome, descrição, categoria, preço e estoque.
- O sistema deve permitir associar imagem ao produto.
- O cadastro deve persistir os dados no backend.
- O sistema deve informar sucesso ou falha ao salvar.

---

### US07.2 — Editar produto existente

**Como** usuário autorizado,  
**quero** editar um produto já cadastrado,  
**para que** suas informações permaneçam atualizadas.

**Critérios de Aceitação:**
- O sistema deve carregar os dados atuais do produto em edição.
- O usuário deve poder alterar campos principais do cadastro.
- As alterações devem ser salvas no backend.
- O sistema deve confirmar quando a atualização for concluída.

---

### US07.3 — Atualizar estoque de produto

**Como** usuário autorizado,  
**quero** ajustar a quantidade em estoque,  
**para que** a disponibilidade reflita a operação real.

**Critérios de Aceitação:**
- O sistema deve permitir informar quantidade de estoque.
- O valor deve ser validado antes de salvar.
- A atualização deve refletir na visão gerencial e no catálogo.
- O sistema deve destacar produtos com baixo estoque.

---

### US07.4 — Filtrar produtos na gestão

**Como** gerente ou atendente,  
**quero** pesquisar e filtrar produtos na área administrativa,  
**para que** eu localize rapidamente itens do catálogo.

**Critérios de Aceitação:**
- O sistema deve permitir filtro por categoria.
- O sistema deve permitir busca textual por nome.
- O resultado deve considerar a combinação dos filtros.
- A listagem deve atualizar sem troca de tela.

---

## EP08 — Indicadores e Gestão

> Cobre visão gerencial de vendas, produtos e indicadores do negócio.

### US08.1 — Visualizar indicadores de faturamento

**Como** gerente,  
**quero** visualizar indicadores de faturamento por período,  
**para que** eu acompanhe o desempenho da operação.

**Critérios de Aceitação:**
- O sistema deve apresentar visão diária, semanal e mensal.
- O painel deve exibir valor atual e comparativo com período anterior.
- O sistema deve atualizar os indicadores a partir dos pedidos cadastrados.
- O gerente deve conseguir alternar o período visualizado.

---

### US08.2 — Visualizar gráficos de vendas

**Como** gerente,  
**quero** ver gráficos de comportamento das vendas,  
**para que** eu identifique tendências de desempenho.

**Critérios de Aceitação:**
- O painel deve exibir gráfico de vendas por período.
- O gráfico deve mudar conforme o período selecionado.
- Os dados devem ser carregados do repositório gerencial.
- O sistema deve exibir estado de erro se a carga falhar.

---

### US08.3 — Visualizar produtos mais vendidos

**Como** gerente,  
**quero** acompanhar os produtos com maior saída,  
**para que** eu apoie decisões de estoque e reposição.

**Critérios de Aceitação:**
- O painel deve listar os produtos mais vendidos.
- A listagem deve refletir o período selecionado.
- O sistema deve ordenar os produtos por volume vendido.
- O painel deve exibir os principais itens do período.

---

### US08.4 — Consultar visão consolidada da operação

**Como** gerente,  
**quero** acessar uma visão resumida de pedidos, produtos e clientes,  
**para que** eu tenha apoio rápido para tomada de decisão.

**Critérios de Aceitação:**
- O sistema deve consolidar dados principais da operação.
- O painel deve reunir pedidos, produtos e métricas de clientes.
- O carregamento deve ocorrer a partir do repositório gerencial.
- O usuário deve conseguir acessar essa visão sem navegar por múltiplas telas.

---

## Observações de Revisão

- O backlog foi simplificado para refletir melhor o projeto atual e evitar histórias que dependem de funcionalidades fora do escopo real do app.
- Alguns itens foram escritos de forma mais genérica para permitir evolução futura sem prender o backlog a decisões técnicas já abandonadas.

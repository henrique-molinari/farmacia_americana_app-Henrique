## Diagramas de Sequência

Os diagramas de sequência apresentados nesta seção representam os principais fluxos de interação da aplicação **Farmácia Americana App**, demonstrando como os usuários interagem com as telas do sistema e como essas telas se comunicam com as camadas de ViewModel, repositórios e banco de dados.

A modelagem segue o padrão arquitetural **MVVM (Model-View-ViewModel)**, no qual a interface visual é responsável por receber as ações do usuário, os ViewModels concentram a lógica de apresentação e os repositórios realizam a comunicação com os serviços externos, como autenticação, banco de dados e armazenamento de arquivos.

---

## Login de Usuário

Este diagrama representa o fluxo de autenticação do usuário na aplicação. O processo inicia quando o usuário informa seu e-mail e senha na tela de login. A tela encaminha esses dados para o `LoginViewModel`, que solicita ao `AuthRepository` a validação das credenciais.

O repositório realiza a autenticação no **Supabase Auth** e, após obter uma sessão válida, consulta os dados complementares do perfil do usuário no **Supabase Profiles**. Com essas informações, o usuário autenticado é retornado ao ViewModel, que atualiza a sessão por meio do `AuthSessionViewModel`.

Ao final do processo, a interface recebe o estado de sucesso e pode redirecionar o usuário de acordo com seu perfil de acesso, como cliente, atendente, farmacêutico, gerente ou administrador.

<img width="1968" height="983" alt="image" src="https://github.com/user-attachments/assets/6588bfbe-a788-456f-b6df-1ec460f8b7f0" />

---

## Carregamento do Catálogo e Busca

Este diagrama descreve o fluxo de carregamento dos produtos exibidos na tela inicial do cliente. Quando o cliente acessa a tela, a interface solicita ao `HomeClientViewModel` a atualização da lista de produtos.

O ViewModel consulta o `ProductsRepository`, que busca no banco de dados os produtos ativos cadastrados no **Supabase Products**. Após receber a lista, o ViewModel organiza as categorias, aplica os filtros iniciais e envia os dados tratados para a interface.

O diagrama também representa as ações de busca por texto e seleção de categoria. Nesses casos, os filtros são aplicados diretamente no ViewModel, atualizando a lista exibida ao cliente sem a necessidade de uma nova consulta imediata ao banco de dados.

<img width="659" height="727" alt="image" src="https://github.com/user-attachments/assets/ca536476-1813-4b9a-b553-a85f412327df" />

---

## Atendimento Automatizado com Transbordo

Este diagrama representa o funcionamento do chat automatizado da aplicação. O fluxo começa quando o cliente abre a tela de chat, fazendo com que o `ClientChatViewModel` inicialize a conversa e carregue as etapas disponíveis do atendimento automático.

O sistema exibe uma mensagem inicial e apresenta opções ao cliente. Quando uma opção é selecionada, o ViewModel registra a mensagem do cliente, localiza a próxima etapa do fluxo e adiciona uma resposta automática à conversa.

O diagrama também contempla o cenário de transbordo para atendimento humano. Caso o cliente escolha falar com um atendente, o sistema adiciona uma mensagem de transferência, simula ou inicia a resposta do atendente e habilita a entrada manual de mensagens. Caso contrário, o cliente permanece no fluxo automatizado do bot.

<img width="1139" height="1220" alt="image" src="https://github.com/user-attachments/assets/f79ca83e-a04b-4b0f-a39d-8e88b177225a" />

---

## Envio de Arquivo no Chat

Este diagrama descreve o processo de envio de imagens ou documentos dentro do chat da aplicação. O fluxo inicia quando o cliente solicita anexar um arquivo na conversa.

A interface envia essa ação ao `ClientChatViewModel`, que verifica se é necessário solicitar permissões ao dispositivo. Caso seja necessário, o sistema utiliza recursos como `FilePicker` e `PermissionHandler` para solicitar autorização e permitir a seleção do arquivo.

Após a escolha do arquivo, o ViewModel adiciona uma nova mensagem com anexo à conversa. Caso o atendimento humano ainda não esteja ativo, o sistema também pode inserir uma mensagem automática orientando a continuidade do atendimento. Por fim, a interface é atualizada para exibir o arquivo enviado no chat.

<img width="1367" height="885" alt="image" src="https://github.com/user-attachments/assets/50fd32a8-b39e-4e62-8f15-1f7af1684409" />

---

## Checkout e Criação de Pedido

Este diagrama representa o fluxo de finalização de compra e criação de pedido. O processo começa quando o cliente confirma o pedido na tela de checkout.

A interface aciona o `CartViewModel`, que monta os itens do pedido com base nos produtos presentes no carrinho. Em seguida, o pedido é enviado ao `OrdersStore`, que encaminha os dados para o `OrdersRepository`.

O repositório utiliza uma chamada RPC no Supabase, responsável por criar o pedido, inserir seus itens e validar o estoque disponível. Caso o processo seja concluído com sucesso, o pedido criado é retornado para as camadas superiores.

Ao final, o carrinho é limpo, a interface recebe uma resposta de sucesso e o cliente é direcionado para a tela de confirmação do pedido.

<img width="2825" height="1402" alt="image" src="https://github.com/user-attachments/assets/73c3558c-7fe0-42f2-b2b5-dba935ec6f6f" />

---

## Consulta de Pedidos do Cliente

Este diagrama apresenta o fluxo de consulta dos pedidos realizados pelo cliente. O processo inicia quando o cliente acessa a tela “Meus Pedidos”.

A interface solicita ao `OrdersViewModel` o carregamento dos pedidos, que por sua vez consulta o `OrdersStore`. O Store acessa o `OrdersRepository`, responsável por buscar no **Supabase Orders** todos os pedidos associados ao usuário autenticado.

Após a consulta, o banco retorna os pedidos e seus respectivos itens. Esses dados são enviados de volta ao ViewModel, que organiza o estado da tela, controlando situações como carregamento, erro ou sucesso.

Por fim, a interface exibe a lista de pedidos. Caso o cliente selecione um pedido específico, o aplicativo navega para a tela de detalhes daquele pedido.

<img width="2361" height="1470" alt="image" src="https://github.com/user-attachments/assets/8635d15f-c5b6-4939-953e-1f9278480481" />

---

## BI Gerencial

Este diagrama representa o fluxo de carregamento dos dados do painel gerencial da aplicação. O processo começa quando o gerente acessa a tela de BI.

A interface solicita ao `BiManagerViewModel` o carregamento das informações. O ViewModel aciona o `ManagerDashboardRepository`, que consulta dados relacionados a pedidos, produtos e perfis no Supabase.

Com os dados obtidos, o repositório realiza cálculos internos, como faturamento por período, montagem de gráficos e identificação dos produtos mais vendidos. Em seguida, essas informações são agrupadas em uma estrutura de dados gerencial.

O ViewModel recebe os dados processados e os envia para a interface, que exibe cards, gráficos e rankings. O diagrama também mostra a troca de período, que atualiza visualmente os dados apresentados sem alterar a estrutura principal do fluxo.

<img width="1968" height="1227" alt="image" src="https://github.com/user-attachments/assets/9a6b8d84-f621-4c57-af17-35938e4d629b" />

---

## Cadastro ou Edição de Produto

Este diagrama representa o fluxo de cadastro ou edição de produtos realizado pelo atendente. O processo começa quando o atendente preenche o formulário com os dados do produto.

Durante o preenchimento, a tela envia as alterações ao `AttendantProductRegistrationViewModel`, mantendo o estado do formulário atualizado. O fluxo também prevê ações opcionais, como gerar uma descrição automaticamente e selecionar uma imagem para o produto.

Ao salvar, o ViewModel envia os dados para o `AttendantProductsRepository`. Caso exista uma imagem, ela é enviada primeiro ao **Supabase Storage**, que retorna a URL do arquivo armazenado. Em seguida, os dados do produto são inseridos ou atualizados no **Supabase Products** junto com a imagem.

Caso não exista imagem, o produto é salvo diretamente no banco de dados. Ao final, o repositório retorna a confirmação de sucesso, e a interface exibe uma mensagem informando que o produto foi salvo corretamente.

<img width="1968" height="1551" alt="image" src="https://github.com/user-attachments/assets/f1f698d3-1753-4507-838d-f9b51cd4af0d" />

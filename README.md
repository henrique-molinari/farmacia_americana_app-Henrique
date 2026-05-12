# 💊 Farmácia Americana App

Aplicação mobile desenvolvida em **Flutter e Dart** para apoiar o atendimento digital, a consulta de produtos, a realização de pedidos e a gestão operacional da **Farmácia Americana**.

---

## 📘 Sobre o Projeto

O **Farmácia Americana App** foi concebido para centralizar, em uma única plataforma, etapas importantes da jornada do cliente e da operação da farmácia.

O sistema busca oferecer uma experiência mais organizada, prática e moderna, reunindo em um só ambiente:

- 💬 atendimento digital por chat com fluxo automatizado por opções;
- 🛍️ catálogo de produtos com busca e navegação por categorias;
- 🛒 carrinho e checkout com diferentes formas de recebimento e pagamento;
- 📦 acompanhamento de pedidos;
- 🧑‍⚕️ painel interno de apoio ao atendimento;
- 📊 gestão de produtos, estoque e indicadores básicos.

---

## ⚠️ Problema

Parte do atendimento tradicional da farmácia depende de canais pouco estruturados, o que pode gerar:

- ⏳ demora em respostas para dúvidas simples;
- 🧩 dificuldade para organizar conversas e pedidos;
- 🔄 experiência de compra fragmentada;
- 📉 baixa rastreabilidade operacional;
- 💸 perda de oportunidades de venda por atrito no processo.

Esses fatores dificultam a escalabilidade do atendimento e aumentam a dependência de intervenção manual em tarefas repetitivas.

---

## 🎯 Objetivo

O objetivo do projeto é construir um canal digital próprio para a farmácia, capaz de:

- melhorar a experiência do cliente;
- organizar o fluxo de atendimento;
- facilitar a jornada de compra;
- apoiar a operação interna;
- criar base para evolução futura do produto.

---

## 👥 Público-Alvo

| Perfil | Necessidade |
|---|---|
| **Clientes da farmácia** | Consultar produtos, pedir atendimento, comprar e acompanhar pedidos |
| **Atendentes e farmacêuticos** | Organizar conversas e dar continuidade ao atendimento humano |
| **Gestores** | Acompanhar produtos, estoque, pedidos e indicadores operacionais |

---

## ✨ Funcionalidades Principais

### 🔐 Acesso e Conta
- Cadastro de usuários
- Login e logout
- Direcionamento por perfil
- Edição de dados pessoais
- Alteração de senha

### 🛍️ Catálogo e Busca
- Listagem de produtos ativos
- Navegação por categorias
- Busca textual
- Visualização de detalhes do produto

### 💬 Atendimento pelo Chat
- Fluxo automatizado por opções
- Encaminhamento para atendimento humano
- Registro de recados e solicitação de retorno
- Envio de imagens e documentos no chat

### 🛒 Carrinho e Checkout
- Adição e remoção de produtos
- Alteração de quantidades
- Escolha entre entrega e retirada
- Pagamento por Pix, dinheiro ou cartão na entrega
- Confirmação do pedido

### 📦 Pedidos
- Consulta de pedidos realizados
- Visualização de detalhes
- Histórico de compras
- Acompanhamento do andamento do pedido

### 🧑‍💼 Operação Interna
- Painel de conversas
- Busca de clientes por nome ou CPF
- Cadastro e edição de produtos
- Atualização de estoque
- Indicadores gerenciais básicos

---

## 🗂️ Estrutura da Documentação

```text
docs/
├── RF.md                         # Requisitos Funcionais
├── RNF.md                        # Requisitos Não Funcionais
├── RN.md                         # Regras de Negócio
├── Backlog.md                    # Épicos e User Stories
├── CasosDeUso.md                 # Casos de Uso
├── VisãoDoProduto.md             # Visão do Produto
├── MVP.md                        # Escopo do MVP
├── DiagramasDeSequencia.md       # Diagramas de Sequência
├── DiagramasDeClasse.md          # Diagrama de Classes
└── supabase/                     # Scripts SQL e ajustes do banco de dados
```

---

## 📁 Estrutura do Projeto

```text
farmacia_americana_app-/
├── README.md
├── docs/                         # Documentação de requisitos, regras e diagramas
├── test.txt                      # Arquivo auxiliar usado durante o desenvolvimento
└── farmacinha_app/               # Aplicação Flutter
    ├── lib/
    │   ├── app/                  # Rotas e configuração de navegação
    │   ├── core/                 # Configurações, tema, paleta, widgets e utilitários
    │   ├── features/             # Módulos principais do sistema
    │   │   ├── auth/             # Login, cadastro, sessão e regras de perfil
    │   │   ├── client/           # Jornada do cliente: catálogo, carrinho, pedidos e conta
    │   │   ├── attendant/        # Telas e fluxos do atendente
    │   │   ├── manager/          # Gestão, estoque, BI e perfil gerencial
    │   │   ├── splash/           # Tela inicial e redirecionamento
    │   │   └── support/          # Repositórios de suporte e chat
    │   ├── main.dart             # Inicialização do app e Supabase
    │   └── welcome_screen.dart   # Tela inicial legada
    ├── assets/
    │   ├── images/               # Imagens do app
    │   └── svgs/                 # Ícones e logos em SVG
    ├── backend_ai_description/   # Backend Node.js para descrição de produtos com Ollama
    ├── test/                     # Testes automatizados Flutter
    ├── android/                  # Projeto Android gerado pelo Flutter
    ├── ios/                      # Projeto iOS gerado pelo Flutter
    ├── web/                      # Configurações para build web
    ├── windows/                  # Projeto Windows gerado pelo Flutter
    ├── linux/                    # Projeto Linux gerado pelo Flutter
    ├── macos/                    # Projeto macOS gerado pelo Flutter
    └── pubspec.yaml              # Dependências, assets e metadados do app
```

---

## 🏗️ Épicos do Produto

| Épico | Escopo |
|---|---|
| **EP01** | Acesso e Conta |
| **EP02** | Catálogo e Descoberta |
| **EP03** | Atendimento pelo Chat |
| **EP04** | Carrinho e Checkout |
| **EP05** | Pedidos e Acompanhamento |
| **EP06** | Painel de Atendimento |
| **EP07** | Gestão de Produtos e Estoque |
| **EP08** | Indicadores e Gestão |

---

## 🧭 Escopo Atual do Produto

A direção atual do projeto prioriza:

- atendimento automatizado por opções, e não por IA generativa;
- transbordo para atendimento humano quando necessário;
- fluxo de compra simples e funcional;
- apoio operacional à equipe da farmácia;
- arquitetura organizada para manutenção e evolução.

Funcionalidades antigas ligadas a **OCR**, **IA generativa no chat** e **automação preditiva** não fazem parte da linha principal atual do sistema.

---

## 📋 Requisitos em Destaque

### ✅ Funcionais
- autenticação de usuários;
- catálogo com busca e categorias;
- atendimento digital por chat;
- transbordo para humano;
- carrinho, checkout e pedidos;
- gestão de estoque e produtos;
- indicadores gerenciais básicos.

### 🛡️ Não Funcionais
- interface fluida e responsiva;
- comunicação segura;
- proteção de dados;
- persistência confiável;
- organização arquitetural em **MVVM**.

---

## 🧱 Arquitetura

O projeto segue a abordagem **MVVM (Model-View-ViewModel)**, favorecendo a separação entre:

- **View**: interface e interação com o usuário;
- **ViewModel**: regras de apresentação e estados da tela;
- **Model/Repository**: modelos de dados e acesso às fontes de persistência.

Essa organização facilita a manutenção, a legibilidade e a evolução do sistema.

---

## 🛠️ Stack Tecnológica

| Camada | Tecnologia |
|---|---|
| **Mobile** | Flutter |
| **Linguagem** | Dart |
| **Backend / Dados** | Supabase |
| **Arquitetura** | MVVM |
| **Diagramas** | PlantUML |
| **Backend auxiliar** | Node.js, Express e Ollama |
| **Gerência de estado** | Provider |

---

## ▶️ Como Executar o Projeto

### Pré-requisitos

- Flutter instalado e configurado;
- Dart compatível com o SDK definido no `pubspec.yaml`;
- Android Studio, emulador Android ou dispositivo físico;
- Node.js, caso queira executar o backend auxiliar de descrição de produtos;
- Ollama com o modelo `llama3.2`, caso use a geração local de descrições.

### Executar o app Flutter

```bash
cd farmacinha_app
flutter pub get
flutter run
```

Para rodar os testes:

```bash
cd farmacinha_app
flutter test
```

### Executar o backend auxiliar de IA

O backend em `farmacinha_app/backend_ai_description` é usado para gerar descrições curtas de produtos por meio do Ollama local.

```bash
cd farmacinha_app/backend_ai_description
npm install
npm start
```

O serviço fica disponível em:

```text
http://localhost:3000
```

No emulador Android, o app usa `http://10.0.2.2:3000` para acessar o backend local. Em dispositivo físico, esse endereço deve ser trocado pelo IP local do computador em `lib/core/config/api_config.dart`.

---

## 🗄️ Banco de Dados e Supabase

O app utiliza **Supabase** para autenticação, persistência e recursos ligados aos perfis do sistema. A inicialização fica em `farmacinha_app/lib/main.dart`.

Os scripts SQL de apoio estão em:

```text
docs/supabase/
```

Essa pasta reúne ajustes relacionados a autenticação, perfis, atendimento por chat, estoque, pedidos e permissões gerenciais.

---

## 👤 Perfis do Sistema

| Ator | Responsabilidade |
|---|---|
| **Cliente** | Navega no catálogo, conversa no chat, monta pedido e acompanha compras |
| **Atendente / Farmacêutico** | Acompanha conversas e realiza atendimento operacional |
| **Gerente / Administrador** | Acompanha indicadores, produtos, estoque e visão gerencial |

---

## 🚧 Status do Projeto

Este repositório representa a evolução acadêmica e prática do **Farmácia Americana App**, com foco em consolidar uma primeira solução digital funcional, coerente com o contexto do negócio e aberta a melhorias futuras.

---

*Repositório acadêmico — Projeto Integrado 3º Semestre · UNIFEOB*

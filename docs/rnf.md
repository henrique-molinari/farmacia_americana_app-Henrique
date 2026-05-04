# Requisitos Não Funcionais (RNF) — Ecossistema Farmácia Americana

Este documento estabelece os critérios de qualidade, segurança, performance e padrões técnicos que o sistema deve cumprir para garantir uma operação robusta e escalável.

---

## 1. Desempenho e Escalabilidade

**RNF01 — Performance de Interface (Flutter)**
O aplicativo deve manter uma taxa de atualização de 60 FPS (quadros por segundo) estáveis em dispositivos homologados, garantindo transições fluidas e ausência de travamentos (*jank*).

**RNF02 — Tempo de Resposta da IA**
O processamento para o chat e a geração automática de descrições de produtos não devem exceder o tempo máximo de 5 segundos. 

**RNF03 — Capacidade de Carga**
O backend deve ser dimensionado para suportar no mínimo **150 usuários** simultâneos realizando transações de chat e consultas ao catálogo sem degradação de performance.

**RNF04 — Latência de Sincronização**
Atualizações críticas feitas no módulo administrativo (como alteração de estoque ou preço) devem ser refletidas no aplicativo do cliente em no máximo **30 segundos**.

---

## 2. Segurança e Conformidade (Privacidade)

**RNF05 — Criptografia de Dados em Trânsito**
Toda comunicação entre o aplicativo Flutter e as APIs deve ser realizada obrigatoriamente via protocolo HTTPS com TLS 1.3.

**RNF06 — Proteção de Dados Sensíveis (LGPD)**
Dados sensíveis, incluindo CPF, históricos de saúde e imagens de receitas médicas, devem ser armazenados com criptografia em repouso utilizando o padrão AES-256.

**RNF07 — Gestão de Sessão (JWT)**
A autenticação deve ser baseada em tokens JWT (JSON Web Token) com tempo de expiração de 24 horas para clientes e 8 horas para colaboradores (funcionários/gerentes).

**RNF08 — Isolamento de Mídia**
As imagens de receitas médicas devem ser armazenadas em repositórios privados (buckets), com acesso permitido apenas através de URLs temporárias assinadas geradas pelo servidor.

---

## 3. Usabilidade e Acessibilidade

**RNF09 — Responsividade Multiplataforma**
O código Dart deve garantir que a interface seja adaptável (responsive design) para diferentes tamanhos de tela, variando de smartphones (4 polegadas) a tablets (12.9 polegadas).

**RNF10 — Design Consistente (Material Design 3)**
O sistema deve seguir rigorosamente os padrões de Design System definidos, garantindo paridade visual e funcional entre as versões Android e iOS.

**RNF11 — Intuitividade de Atendimento**
O painel administrativo deve ser projetado para que o atendente consiga concluir o registro de uma venda em no máximo 4 cliques após o recebimento dos dados da receita.

---

## 4. Disponibilidade e Confiabilidade

**RNF12 — Disponibilidade (SLA)**
O ecossistema (App, Web e APIs) deve garantir um tempo de atividade (Uptime) mínimo de 99,5% ao mês.

**RNF13 — Persistência de Chat Offline**
Em caso de perda temporária de conexão, o aplicativo Flutter deve enfileirar as mensagens do cliente localmente e sincronizá-las automaticamente assim que a conexão for restabelecida.

---

## 5. Manutenibilidade e Tecnologia

**RNF14 — Padrão de Arquitetura (MVVM)**
O desenvolvimento do software deve seguir rigorosamente a documentação de estrutura e o padrão de projeto **MVVM (Model-View-ViewModel)** no Flutter, garantindo a separação clara entre lógica de negócio, estados da UI e modelos de dados.

**RNF15 — Coerência da IA de Cadastro**
A inteligência artificial de geração de descrições deve garantir que os textos gerados estejam em conformidade com o nome e categoria do produto fornecidos, evitando alucinações de dados (informações inventadas) em 95% das gerações. 

**RNF16 — Arquitetura de Módulos de IA **
O backend deve permitir que o motor de geração de texto (cadastro) e o motor do chat sejam atualizados ou substituídos sem impactar as funções vitais de catálogo e checkout. 

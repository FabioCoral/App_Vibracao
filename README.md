#  Monitor de Vibração Industrial

Aplicativo mobile desenvolvido em Flutter para o monitoramento em tempo real de equipamentos industriais e prevenção de falhas, focado na leitura de telemetrias de vibração via sensores.

##  Funcionalidades

* **Autenticação Segura e RBAC:** Sistema de login integrado ao Firebase Authentication, com persistência local (Auto-login) e Controle de Acesso Baseado em Funções (Gerentes possuem permissão para gerenciar ativos; Operadores possuem acesso de visualização).
* **Monitoramento em Tempo Real:** Conexão direta com sensores (ESP32/Node.js) através de WebSockets para recebimento de telemetria de vibração sem latência.
* **Gestão de Ativos Industriais:** Operações completas de CRUD (Criar, Ler, Atualizar, Deletar) no Firestore para registro de máquinas, vinculando endereços MAC, nomes e setores de operação.
* **Histórico de Alertas:** Registro em memória de picos de vibração e eventos críticos classificados como emergência pela API.

##  Tecnologias Utilizadas

* **Frontend Mobile:** Flutter & Dart
* **Gerenciamento de Estado:** Provider (Arquitetura orientada a Repositórios)
* **Backend as a Service (BaaS):** Firebase (Auth e Cloud Firestore)
* **Comunicação:** `web_socket_channel` para comunicação bidirecional de baixa latência
* **Segurança:** Gestão de variáveis sensíveis via `flutter_dotenv`

##  Como executar o projeto localmente

### Pré-requisitos
* Flutter SDK instalado na máquina.
* Conta no Firebase com projeto configurado (Auth e Firestore ativados).
* API Node.js/ESP32 configurada para transmissão via WebSocket.

### Passo a Passo

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/FabioCoral/App_Vibracao.git

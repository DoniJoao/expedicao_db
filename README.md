# 📦 Sistema de Gestão de Expedição e Coletas

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Status](https://img.shields.io/badge/Status-Em%20Desenvolvimento-orange?style=for-the-badge)

Aplicativo móvel e backend desenvolvidos para otimizar, controlar e automatizar o processo de conferência de carga, separação por lotes, validação de volumes e gestão de coletas na expedição.

---

## 🚀 Sobre o Projeto

O objetivo do sistema é eliminar erros na conferência de pedidos antes do envio para transportadoras ou frota própria, garantindo que as quantidades por lote e volumes conferidos estejam 100% alinhados com o ERP.

### ✨ Funcionalidades Atuais
- 📋 **Listagem Dinâmica de Pedidos:** Integração via API REST com banco de dados MySQL.
- 🔍 **Conferência por Lotes:** Controle individualizado de cada lote por item do pedido.
- ⚖️ **Validação de Divergências:** Bloqueio automático no app caso falte ou sobras de mercadorias em relação ao pedido original.
- 📦 **Consolidação de Volumes:** Leitura e salvamento da quantidade final de volumes transportados.

---

## 🛠️ Tecnologias Utilizadas

* **Front-end / Mobile:** [Flutter](https://flutter.dev/) (Dart)
* **Back-end:** PHP (API REST com PDO e Transações Seguras)
* **Banco de Dados:** MySQL
* **Servidor Local:** Apache (WampServer / XAMPP)

---

## 📌 Roadmap & Monitoramento do Desenvolvimento

Acompanhamento das próximas etapas, funcionalidades pendentes e novos módulos do sistema.

### 🔴 Pendente / Em Andamento (Sprint Atual)

- [ ] **Integração de Coleta de Pedidos**
  - [ ] Implementar botão *"Confirmar Pedidos"* (Salvar conferência final e subir registro para a fila de coleta).
- [ ] **Módulo de Assinatura Digital**
  - [ ] Criar tela de assinatura de coletas (Canvas para captura de assinatura na tela do celular).
  - [ ] Criar botão e fluxo *"Confirmar Assinatura de Coletas"* (Envio do blob/imagem da assinatura para o servidor PHP).

### 🟡 Planejamento de Futuros Módulos

- [ ] **Módulo Administrativo (Admin)**
  - [ ] Gestão de usuários, permissões (Conferente, Motorista, Admin).
  - [ ] Relatórios de auditoria e métricas de produtividade da expedição.
- [ ] **Módulo de Vendas**
  - [ ] Acompanhamento em tempo real do status do pedido (Pendente ➔ Em Conferência ➔ Aguardando Coleta ➔ Enviado).
- [ ] **Módulo de Entregas**
  - [ ] Roteirização simples de entregas.
  - [ ] Baixa de entrega no destino final com confirmação/geolocalização.

---

## ⚙️ Estrutura do Projeto

```text
├── lib/
│   ├── models/        # Modelos de dados (Pedido, Item, Lote)
│   ├── screens/       # Telas do App (Lista, Detalhes, Assinatura)
│   └── main.dart      # Ponto de entrada da aplicação Flutter
│
├── backend/ (php)
│   ├── conexao.php    # Conexão PDO com MySQL
│   ├── buscar_pedidos.php
│   └── confirmar_conferencia.php
│
└── README.md
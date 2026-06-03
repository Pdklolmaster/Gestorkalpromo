<img width="576" height="1280" alt="photo_4_2026-06-02_22-43-44" src="https://github.com/user-attachments/assets/763f5f14-9ae5-401c-97cb-c5155204c5ed" />
<img width="576" height="1280" alt="photo_3_2026-06-02_22-43-44" src="https://github.com/user-attachments/assets/dd756d2b-67be-456c-8cc8-a120b5c34ddf" />
<img width="576" height="1280" alt="photo_2_2026-06-02_22-43-44" src="https://github.com/user-attachments/assets/2c4e4581-6607-43bb-9329-f0146f8593a7" />
<img width="576" height="1280" alt="photo_1_2026-06-02_22-43-44" src="https://github.com/user-attachments/assets/d941efbc-6414-48a5-a343-6a9c837c2d2f" />
# Gestor-kal 📱📊

O **Gestor-kal** é um aplicativo mobile de gestão financeira desenvolvido em Flutter, focado em inteligência orçamentária baseada na metodologia 50/30/20 e total privacidade dos dados do utilizador.

## 🧠 Filosofia e Regras de Negócio

O diferencial do aplicativo está na aplicação rigorosa e inteligente da metodologia de finanças pessoais, operando sob três pilares de consistência:

1. **Divisão Orçamentária Estruturada:**
   - **50% (Necessidades):** Gastos fixos e essenciais para a subsistência.
   - **30% (Desejos, Vontades):** Gastos flexíveis, lazer e estilo de vida.
   - **20% (Metas Investimento):** Foco em evolução patrimonial, poupança e investimentos.

2. **Flexibilidade de Saldo Corrente:**
   - Ajustes manuais diretos no campo de **Saldo Disponível** recalculam automaticamente o valor da renda total do período atual, mantendo os registos fixos de salário mensal e rendas extras completamente intactos.

3. **Isolamento de Histórico (Data Isolation):**
   - A edição do `Saldo_Final` de um mês passado **não altera** o saldo inicial do mês atual. Isso garante proteção total contra o efeito cascata indesejado e dá autonomia ao utilizador sobre cada ciclo financeiro.

## 🛠️ Tecnologias e Arquitetura

O projeto foi construído para ser rápido, seguro e independente de servidores externos:
- **Framework:** Flutter 3.x & Dart — Performance nativa e UI fluida.
- **Base de Dados Local:** Hive & `hive_flutter` — Persistência NoSQL local ultrarrápida (armazenamento em caixas isoladas).
- **Segurança:** `local_auth` — Bloqueio e autenticação por biometria nativa do dispositivo.
- **Gráficos:** `fl_chart` — Renderização analítica de relatórios e desempenho de gastos.

## 📂 Estrutura do Projeto

```text
lib/
├── main.dart          # Ponto de entrada e inicialização (Hive/Temas)
├── pages/             # Interfaces de utilizador e navegação (Dashboard, Relatórios)
├── models/            # Modelos de dados e TypeAdapters do Hive
├── services/          # Lógica de negócio (Cálculos, Biometria, Persistência)
├── theme/             # Definições de estilo visual do app
└── widgets/           # Componentes customizados e reaproveitáveis da UI

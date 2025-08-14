# 📘 Estudo de SQL e SQL Server

---

## 📚 Conceitos Gerais de SQL

### 🔸 Conceitos Fundamentais

* **Registro (ou Tupla):** Conjunto de dados em uma linha da tabela.
* **Campo (ou Atributo):** Coluna da tabela.
* **SGBD (Sistema Gerenciador de Banco de Dados):** Software que permite gerenciar bancos de dados (ex: SQL Server, MySQL, PostgreSQL etc).
* **SQL (Structured Query Language):** Linguagem de quarta geração usada para gerenciamento e consulta de dados.
* **Delimitador de comandos:** `;`

### 🔸 Operações básicas

* **Seleção:** Filtragem com `WHERE`, resultando em subconjuntos dos dados.
* **Projeção:** Seleção de colunas com `SELECT`.
* **Junção (JOIN):** Combinação de tabelas relacionadas por chaves.

### 🔸 Linguagens SQL

* **DML (Data Manipulation Language):** `SELECT`, `INSERT`, `UPDATE`, `DELETE`
* **DDL (Data Definition Language):** `CREATE`, `ALTER`, `DROP`
* **DCL (Data Control Language):** `GRANT`, `REVOKE`
* **TCL (Transaction Control Language):** `BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`

---

## 🧱 Modelagem de Banco de Dados

### 🔹 Tipos de Modelagem

* **Conceitual:** Diagrama de alto nível (ex: ER).
* **Lógica:** Esquema detalhado com chaves, tipos, relacionamentos.
* **Física:** Script real que será executado no SGBD.

### 🔹 Chaves

* **Chave Primária:** Identificador único de um registro.
* **Chave Estrangeira (FK):** Estabelece relação entre tabelas.
* **Chave Natural:** Já existe no mundo real (ex: CPF).
* **Chave Artificial:** Criada para ser chave (ex: ID incremental).

---

## 🧪 Formas Normais (Normalização de Dados)

A normalização é um processo que organiza os dados no banco para reduzir redundância e melhorar a integridade. As três primeiras formas normais são as mais usadas:

### **1ª Forma Normal (1NF)** – Eliminar dados repetidos e campos compostos

Uma tabela está na 1ª forma normal quando:

* Cada campo contém **apenas um valor atômico** (não dividido ou agrupado).
* **Não há colunas multivaloradas** (ex: telefones separados por vírgula).
* Todos os registros têm a **mesma estrutura de colunas**.

✅ **Exemplo errado:**

| ID | Nome  | Telefones          |
| -- | ----- | ------------------ |
| 1  | Maria | (11)1111, (11)2222 |

✅ **Forma correta (tabela separada):**

| ID | Nome  |
| -- | ----- |
| 1  | Maria |

| ID\_Usuario | Telefone |
| ----------- | -------- |
| 1           | (11)1111 |
| 1           | (11)2222 |

---

### **2ª Forma Normal (2NF)** – Eliminar dependências parciais

Uma tabela está na 2NF quando:

* Está **na 1NF**.
* **Todos os campos não-chave dependem de toda a chave primária**, e não apenas de parte dela (em chaves compostas).

✅ Exemplo típico:

* Se você tem uma tabela com chave composta (por exemplo: `AlunoID`, `CursoID`) e um campo como `NomeAluno`, este campo depende **somente de AlunoID**, não do par inteiro — então deve estar em outra tabela.

---

### **3ª Forma Normal (3NF)** – Eliminar dependências transitivas

Uma tabela está na 3NF quando:

* Está **na 2NF**.
* **Nenhum campo não-chave depende de outro campo não-chave**.

✅ Exemplo errado:

| ID | Nome | CEP       | Cidade   |
| -- | ---- | --------- | -------- |
| 1  | João | 18000-000 | Sorocaba |

`Cidade` depende de `CEP`, não de `ID`. A solução é criar uma tabela para endereços com relação por CEP.

---

## ⚙️ Comandos e Boas Práticas

### 🔹 UPDATE

* Nunca executar `UPDATE` sem `WHERE` e sem testar com `SELECT`.
* Ideal: testar em ambiente seguro e/ou com backup.

### 🔹 Funções de Agrupamento

* `SUM()`, `AVG()`, `COUNT()`, `MIN()`, `MAX()` — geralmente usados com `GROUP BY`.

### 🔹 Operadores de Comparação

| Operador | Descrição      |
| -------- | -------------- |
| =        | Igual          |
| <> ou != | Diferente      |
| >        | Maior que      |
| <        | Menor que      |
| >=       | Maior ou igual |
| <=       | Menor ou igual |

---

## 📊 OLTP x OLAP

| OLTP (Transacional)        | OLAP (Analítico)    |
| -------------------------- | ------------------- |
| Muitas transações pequenas | Consultas complexas |
| Normalização               | Desnormalização     |
| Foco em integridade        | Foco em performance |

---

## 🔧 Tuning e Performance

* Evite `SELECT *` — escolha somente os campos necessários.
* Prefira filtrar no banco, não na aplicação.
* Use tipos de dados apropriados: `INT` para cálculos, `CHAR` para dados fixos etc.
* Evite `GROUP BY` ou `ORDER BY` em produção durante horários de pico.
* Teste índices e particionamento quando necessário.
* Priorize condições mais seletivas nos `WHERE`.

---

## 🧩 Teoria dos Conjuntos

Base para operações como `UNION`, `INTERSECT`, `EXCEPT`:

* **UNION:** União de dois conjuntos (sem duplicatas).
* **INTERSECT:** Interseção (o que existe em ambos).
* **EXCEPT:** Diferença (o que existe em um e não no outro).

---

## 🧰 Variáveis e Programação no Banco

* **Procedures:** Blocos nomeados que podem receber parâmetros e executar múltiplas instruções.
* **Functions:** Retornam valores e podem ser usadas dentro de consultas.
* **Views:** Consultas armazenadas que podem ser tratadas como tabelas.
* **Constraints:** Regras de integridade: `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `NOT NULL`.
* **Triggers:** Blocos de código que são executados automaticamente em resposta a eventos como `INSERT`, `UPDATE` ou `DELETE` em uma tabela. Usados para automatizar validações, atualizações em cascata, logs de auditoria, entre outros.

---

## 📌 Específico do SQL Server

### 🔹 Arquivos

* **.MDF (Master Database File):** Arquivo principal do banco.
* **.LDF (Log Database File):** Arquivo de log de transações.

### 🔹 Comandos e Características

* Interface gráfica (SSMS) baseada em queries, mas facilita a administração visualmente.
* Uso frequente de **Stored Procedures** como alternativa a comandos simples (`SHOW TABLES`, etc.).
* Utilização de tipos como `VARCHAR(MAX)` e `NVARCHAR` para Unicode.
* `ENUM` não existe diretamente — pode ser simulado com `CHECK` ou tabela relacionada.

---

## ✅ Dicas e Práticas Úteis

* Use `DESC [tabela]` (ou `sp_help [tabela]` no SQL Server) para consultar colunas.
* Crie `CONSTRAINTS` separadamente para poder nomeá-las manualmente.
* Em relacionamento 1:1, a FK fica na tabela "mais fraca".
* O primeiro número na notação (0..1, 1..n) representa obrigatoriedade (controlada pela aplicação), e o segundo representa a cardinalidade (controlada no banco).
* Use variáveis locais (`DECLARE`) e globais (`@@`) conforme o contexto.


teoria dos conjuntos
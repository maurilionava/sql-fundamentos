# 📘 Estudos de SQL e SQL Server

Este repositório reúne anotações e conceitos fundamentais de **SQL** e **SQL Server**, 
servindo como material de estudo e referência rápida.  
Os scripts completos estão em arquivos separados para não poluir o conteúdo principal.

---

## 📑 Sumário
- [Conceitos Gerais](#-conceitos-gerais)
- [Modelagem de Banco de Dados](#-modelagem-de-banco-de-dados)
- [Normalização e Desnormalização](#-normalização-e-desnormalização)
- [Linguagens SQL](#-linguagens-sql)
- [OLTP x OLAP](#-oltp-x-olap)
- [Tuning e Performance](#-tuning-e-performance)
- [Funções de Agregação](#-funções-de-agregação)
- [Outros Conceitos](#-outros-conceitos)
- [Q&A Rápido](#-qa-rápido)
- [Prática Recomendada](#-prática-recomendada)

---

## 📚 Conceitos Gerais

- **Registro (ou Tupla):** Linha da tabela, representa uma ocorrência de dados.  
- **Campo (ou Atributo):** Coluna da tabela.  
- **Tabela:** Estrutura que organiza dados em linhas e colunas.  
- **Banco de Dados:** Conjunto estruturado de tabelas e outros objetos.  
- **SGBD (Sistema Gerenciador de Banco de Dados):** Software que permite gerenciar bancos de dados (ex: SQL Server, MySQL, PostgreSQL).  
- **SQL (Structured Query Language):** Linguagem padrão para manipulação de bancos relacionais.  
- **T-SQL (Transact-SQL):** Extensão do SQL usada no SQL Server, inclui variáveis, loops e tratamento de erros.  

### 🔹 Chaves

- **Primária (PK):** Identifica de forma única um registro.  
- **Estrangeira (FK):** Relaciona registros entre tabelas, garantindo integridade referencial.  
- **Natural:** Já possui significado no mundo real (ex: CPF).  
- **Artificial:** Criada apenas para identificar registros (ex: ID incremental).  

### 🔹 Índices

Melhoram a performance de consultas.  
```sql
CREATE INDEX idx_nome ON tabela(coluna);
```

### 🔹 Integridade Referencial

Garante consistência entre tabelas relacionadas. Exemplo: não permitir inserir uma venda com um cliente inexistente.

### 🔹 Transações e ACID

**Transação:** Conjunto de operações SQL que devem ser executadas como uma unidade.  
- Se todas as operações ocorrerem com sucesso, a transação é confirmada.  
- Se houver erro, a transação é revertida, garantindo a consistência dos dados.  

```sql
BEGIN TRANSACTION;
-- operações
COMMIT;
-- ou, em caso de erro
ROLLBACK;
```

**ACID:** Conjunto de propriedades que garantem a confiabilidade das transações.  
- **Atomicidade:** ou todas as operações da transação são aplicadas, ou nenhuma.  
- **Consistência:** a transação leva o banco de dados de um estado válido para outro estado válido.  
- **Isolamento:** transações simultâneas não interferem entre si.  
- **Durabilidade:** após confirmada, a transação permanece registrada, mesmo em caso de falha no sistema.  

---

## 🧱 Modelagem de Banco de Dados

- **Conceitual:** visão geral (diagramas ER).  
- **Lógica:** detalha entidades, atributos e relacionamentos.  
- **Física:** implementação real no SGBD.  

### Cardinalidade

- **1:1, 1:N, N:1, N:N** — indicam como tabelas se relacionam.  
- Relações muitos-para-muitos normalmente usam **tabelas associativas**.

---

## 🧪 Normalização e Desnormalização

- **1ª Forma Normal (1NF):** dados atômicos, sem campos multivalorados.  
- **2ª Forma Normal (2NF):** elimina dependências parciais (em chaves compostas).  
- **3ª Forma Normal (3NF):** elimina dependências transitivas.  

> Objetivo: reduzir redundância e melhorar integridade.  

- **Desnormalização:** introduz redundância para ganho de performance (usada com cautela).  

---

## ⚙️ Linguagens SQL

- **DDL (Data Definition Language):** criar e alterar estruturas.  
  ```sql
  CREATE TABLE tabela (coluna1 INT, coluna2 VARCHAR(50));
  ALTER TABLE tabela ADD coluna3 DATE;
  ALTER TABLE tabela DROP COLUMN coluna2;
  ALTER TABLE tabela ALTER COLUMN coluna1 NVARCHAR(100); -- SQL Server
  EXEC sp_rename 'tabela.coluna1', 'coluna1_novo', 'COLUMN'; -- renomear coluna
  EXEC sp_rename 'tabela', 'tabela_nova'; -- renomear tabela
  DROP TABLE tabela;
  ```
- **DML (Data Manipulation Language):** manipulação de dados (`INSERT`, `UPDATE`, `DELETE`).  
- **DCL (Data Control Language):** permissões (`GRANT`, `REVOKE`).  
- **TCL (Transaction Control Language):** controle de transações (`COMMIT`, `ROLLBACK`).  

---

## 📊 OLTP x OLAP

| OLTP (Transacional) | OLAP (Analítico) |
|----------------------|------------------|
| Muitas transações pequenas | Consultas complexas |
| Normalização         | Desnormalização |
| Foco em integridade  | Foco em performance |

---

## 🔧 Tuning e Performance

- Evite `SELECT *`.  
- Use **índices** quando necessário.  
- Analise planos de execução.  
- Prefira filtrar no banco, não na aplicação.  
- Escolha tipos de dados adequados (`DECIMAL` para valores monetários, `CHAR` para campos fixos etc).  

---

## 📊 Funções de Agregação

- `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `COUNT DISTINCT`  
- Geralmente usadas com `GROUP BY`.  

---

## 🧩 Outros Conceitos

- **Views:** consultas armazenadas, podem simplificar acessos.  
- **Stored Procedures:** blocos de SQL reutilizáveis, aumentam segurança e organização.  
- **Triggers:** executam automaticamente após eventos (`INSERT`, `UPDATE`, `DELETE`).  
- **Constraints:** regras de integridade (`NOT NULL`, `CHECK`, `UNIQUE`).  
- **Teoria dos conjuntos:** `UNION`, `INTERSECT`, `EXCEPT`.  

---

## ❓ Q&A Rápido

- **Por que string para CPF/telefone?** Para preservar zeros e evitar cálculos desnecessários.  
- **Por que não usar FLOAT em valores monetários?** Pode gerar imprecisões — use `DECIMAL`.  
- **DELETE x TRUNCATE:** DELETE remove linha a linha (pode usar WHERE); TRUNCATE remove tudo rapidamente, sem WHERE.  
- **WHERE x HAVING:** WHERE filtra antes da agregação, HAVING depois.  

---

## ✅ Prática Recomendada

- Criar bancos e tabelas.  
- Inserir, atualizar e excluir dados.  
- Trabalhar com relacionamentos 1:1, 1:N, N:N.  
- Explorar **JOINs**, **subqueries**, **views**, **procedures**, **triggers**.  

---

## 🚀 Como usar este repositório

- Consulte este README como guia teórico.  
- Veja os arquivos de scripts SQL para praticar os exemplos.  
- Explore os tópicos conforme for avançando nos estudos.  

---

✍️ Autor: Maurilio Nava Junior  
🎯 Objetivo: Estudo contínuo de SQL e SQL Server  

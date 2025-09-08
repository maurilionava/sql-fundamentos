Abaixo vai um **roteiro de exercícios encadeados** para SQL/T-SQL no **SQL Server**, partindo do zero até um mini-ecossistema com múltiplas tabelas, relacionamentos, consultas, views, procedures e triggers. A ideia é você ir **executando em ordem**; ao final, terá um banco consistente para praticar.

> Convenções:
>
> * Use sempre `SQL Server` (T-SQL).
> * Separe cada bloco em um arquivo (ex.: `01_ddl.sql`, `02_dml.sql`, …) se quiser.
> * Onde eu disser “Crie…”, escreva o código — não trago respostas prontas para maximizar a prática. Se quiser, depois eu gero um “gabarito” separado.

---

# Parte 0 — Preparação do ambiente

**Ex. 0.1** Crie o banco e o schema:

```sql
CREATE DATABASE LogisticaAcademica;
GO
USE LogisticaAcademica;
GO
CREATE SCHEMA ops AUTHORIZATION dbo;
GO
```

**Ex. 0.2** Ative `ANSI_NULLS`, `QUOTED_IDENTIFIER` e ajuste `SET NOCOUNT ON` no início dos seus scripts.

---

# Parte 1 — Modelagem e DDL (Entidades principais)

Domínio: **Pedidos, Faturamento e Transporte**.

Entidades: `Clientes`, `Enderecos`, `Produtos`, `Pedidos`, `ItensPedido`, `Transportadoras`, `CTe` (conhecimento de transporte), `NFe` (nota fiscal), `Entregas`, `Motoristas`.

**Ex. 1.1** Crie a tabela `ops.Clientes`:

* `ClienteID` (PK, `INT IDENTITY`), `Nome` (`NVARCHAR(120)` not null), `CpfCnpj` (`VARCHAR(18)`), `Email` (`VARCHAR(120)`), `DtCadastro` (`DATETIME2(0)` default `SYSDATETIME()`), `Ativo` (`BIT` default 1).
* `UNIQUE` em `CpfCnpj` quando não nulo; `CHECK` para `LEN(CpfCnpj)` ∈ {11,14} quando não nulo.

**Ex. 1.2** Crie `ops.Enderecos`:

* `EnderecoID` (PK), `ClienteID` (FK `Clientes`), `Tipo` (`VARCHAR(20)` = {‘COBRANCA’, ‘ENTREGA’}), `Logradouro`, `Numero`, `Bairro`, `Cidade`, `UF` (2), `CEP` (8).
* `CHECK` para limitar `Tipo` e `UF` (lista de UF ou apenas comprimento 2).

**Ex. 1.3** Crie `ops.Produtos`:

* `ProdutoID` (PK), `Nome`, `Categoria`, `PrecoUnitario` (`DECIMAL(12,2)`), `Ativo` (BIT).
* `CHECK` `PrecoUnitario > 0`.

**Ex. 1.4** Crie `ops.Pedidos`:

* `PedidoID` (PK), `ClienteID` (FK), `DataPedido` (`DATETIME2`), `Status` (`VARCHAR(20)` = {‘ABERTO’, ‘FATURADO’, ‘CANCELADO’}), `ValorBruto` (`DECIMAL(14,2)`), `Desconto` (`DECIMAL(14,2)` default 0), `ValorLiquido` (computada: `ValorBruto-Desconto`).
* `CHECK` `Desconto >= 0` e `ValorBruto >= Desconto`.

**Ex. 1.5** Crie `ops.ItensPedido`:

* `ItemID` (PK), `PedidoID` (FK), `ProdutoID` (FK), `Qtde` (`DECIMAL(12,3)`), `PrecoUnitario` (`DECIMAL(12,2)`), `ValorItem` (computada: `Qtde*PrecoUnitario`).
* `CHECK` `Qtde > 0` e `PrecoUnitario > 0`.
* `UNIQUE (PedidoID, ProdutoID)` para não repetir produto no mesmo pedido.

**Ex. 1.6** Crie `ops.Transportadoras` e `ops.Motoristas`:

* Transportadoras: `TransportadoraID` (PK), `RazaoSocial`, `Cnpj` (`VARCHAR(14)` unique), `Ativo`.
* Motoristas: `MotoristaID` (PK), `Nome`, `Cpf` (`VARCHAR(11)` unique), `CNH`, `TransportadoraID` (FK).

**Ex. 1.7** Crie `ops.CTe` (Conhecimento de Transporte):

* `CTeID` (PK), `Numero` (`VARCHAR(44)` unique), `TransportadoraID` (FK), `PedidoID` (FK), `ValorFrete` (`DECIMAL(12,2)`), `DtEmissao` (`DATETIME2`).

**Ex. 1.8** Crie `ops.NFe`:

* `NFeID` (PK), `Chave` (`VARCHAR(44)` unique), `PedidoID` (FK), `ValorTotal` (`DECIMAL(14,2)`), `DtEmissao` (`DATETIME2`).

**Ex. 1.9** Crie `ops.Entregas`:

* `EntregaID` (PK), `PedidoID` (FK), `CTeID` (FK), `MotoristaID` (FK), `DtSaida` (`DATETIME2`), `DtEntrega` (`DATETIME2` null), `Status` (`VARCHAR(15)` = {‘EM\_ROTA’, ‘ENTREGUE’, ‘DEVOLVIDO’}).

**Ex. 1.10** Crie índices úteis:

* `IX_Pedidos_ClienteID_DataPedido`, `IX_ItensPedido_PedidoID`, `IX_ItensPedido_ProdutoID`, `IX_Entregas_Status`, `IX_NFe_PedidoID`, `IX_CTe_PedidoID`.

---

# Parte 2 — DML (dados de exemplo)

**Ex. 2.1** Insira 8–12 clientes (alguns com CPF, outros com CNPJ), variados estados.
**Ex. 2.2** Insira 1–2 endereços por cliente (entrega/cobrança).
**Ex. 2.3** Insira 12–18 produtos em categorias distintas.
**Ex. 2.4** Crie 10–15 pedidos com status variados e datas em um intervalo de 3 meses.
**Ex. 2.5** Popule `ItensPedido` garantindo consistência de preços e quantidades.
**Ex. 2.6** Para parte dos pedidos em status ‘FATURADO’, crie `NFe` coerentes (valor ≈ somatório itens).
**Ex. 2.7** Crie `Transportadoras`, `Motoristas`.
**Ex. 2.8** Gere `CTe` atrelados a pedidos faturados e `Entregas` (algumas concluídas, outras em rota).

---

# Parte 3 — Consultas básicas e intermediárias

**Ex. 3.1** Listar clientes ativos com ao menos um pedido.
**Ex. 3.2** Top 5 produtos por faturamento (soma de `ValorItem`), com `JOIN` entre `ItensPedido`/`Pedidos`/`Produtos`.
**Ex. 3.3** Total de pedidos por UF do endereço de entrega.
**Ex. 3.4** Pedidos sem itens (deve retornar 0 linhas; se retornar >0, você tem problema de integridade).
**Ex. 3.5** Pedidos com valor líquido > média do mês correspondente (subquery correlacionada).
**Ex. 3.6** Produtos nunca vendidos (LEFT JOIN e `WHERE ... IS NULL`).
**Ex. 3.7** Clientes sem e-mail cadastrado mas com pedidos nos últimos 45 dias.
**Ex. 3.8** Total de frete por transportadora (somar `ValorFrete` do `CTe`).
**Ex. 3.9** Pedidos com NF-e mas sem entrega concluída.
**Ex. 3.10** Ranking (janela) de clientes por valor faturado no trimestre, com `ROW_NUMBER()` e `SUM() OVER`.

---

# Parte 4 — Janela, CTE, PIVOT

**Ex. 4.1** Para cada cliente, calcule:

* Valor total, ticket médio, e variação (% mês a mês) usando `LAG()`/`LEAD()`.

**Ex. 4.2** Usando `CTE`, retorne os pedidos com “lacunas” de numeração (se usar uma sequência própria ou IDENTITY com gaps simulados).

**Ex. 4.3** Faça um `PIVOT` para mostrar total vendido por categoria de produto em colunas (por mês).

---

# Parte 5 — Views

**Ex. 5.1** Crie a view `ops.vw_PedidosDetalhados`:

* Junte `Pedidos`, `Clientes`, `Enderecos` (entrega), somatório de itens, e situação de NF-e/CT-e.

**Ex. 5.2** Crie a view `ops.vw_PerformanceTransportadoras`:

* Agrupe por transportadora: total de CT-e, valor total de frete, entregas no prazo (defina atraso como `DtEntrega > DtSaida + 5 dias`, por exemplo) e taxa de sucesso.

**Ex. 5.3** Crie a view `ops.vw_TopProdutosUltimos30Dias`:

* TOP 10 produtos por faturamento dos últimos 30 dias.

---

# Parte 6 — Stored Procedures (T-SQL)

**Ex. 6.1** `ops.pr_CriarPedido`
Parâmetros: `@ClienteID`, tabela-valor `@Itens` (`ProdutoID`, `Qtde`, `PrecoUnitario`).
Regras:

* Deve criar `Pedido` e seus `ItensPedido` **em transação**.
* Recalcular `ValorBruto` a partir dos itens; `Desconto` opcional param.
* `TRY...CATCH` com `ROLLBACK` em erro; retorne `PedidoID` criado.

**Ex. 6.2** `ops.pr_FaturarPedido`
Parâmetros: `@PedidoID`.
Regras:

* Validar se pedido está ‘ABERTO’ e possui itens.
* Criar `NFe` com `ValorTotal = SUM(ValorItem) - Desconto`.
* Atualizar status para ‘FATURADO’. Transação + `TRY...CATCH`.

**Ex. 6.3** `ops.pr_GerarCTeEntrega`
Parâmetros: `@PedidoID`, `@TransportadoraID`, `@MotoristaID`, `@ValorFrete`.
Regras:

* Criar `CTe` e `Entrega` (status ‘EM\_ROTA’). Transação.

**Ex. 6.4** `ops.pr_ConcluirEntrega`
Parâmetros: `@EntregaID`.
Regras:

* Atualiza `DtEntrega = SYSDATETIME()`, `Status = 'ENTREGUE'`.

**Ex. 6.5** `ops.pr_ResumoCliente`
Parâmetros: `@ClienteID`, `@DataIni`, `@DataFim`.
Retornar: pedidos no período, total, ticket médio, participação por categoria (subqueries/CTE).

---

# Parte 7 — Triggers

**Ex. 7.1** Trigger `ops.trg_Pedidos_Itens_ValidaValor` (AFTER INSERT/UPDATE em `ItensPedido`):

* Garante que `PrecoUnitario` seja o atual de `Produtos` ou, se divergente, registra em uma tabela de auditoria `ops.LogPrecoDivergente` (`ItemID`, `ProdutoID`, `PrecoEsperado`, `PrecoInformado`, `Data`).

**Ex. 7.2** Trigger `ops.trg_Pedidos_RecalculaTotais` (AFTER INSERT/UPDATE/DELETE em `ItensPedido`):

* Recalcula `ValorBruto` de `Pedidos` sempre que itens mudarem.

**Ex. 7.3** Trigger `ops.trg_Entregas_Status` (AFTER UPDATE em `Entregas`):

* Se `Status = 'ENTREGUE'` sem `DtEntrega` → seta `DtEntrega = SYSDATETIME()`.
* Se `Status` voltar para ‘EM\_ROTA’, zere `DtEntrega`.

**Ex. 7.4** Trigger `ops.trg_NFe_PedidoCancelado` (INSTEAD OF INSERT em `NFe`):

* Impedir inserção de NF-e para pedido `CANCELADO`. Caso ocorra, lance erro.

---

# Parte 8 — Funções definidas pelo usuário

**Ex. 8.1 (Scalar)** `ops.fn_CalculaFreteEstimado(@PesoTotal DECIMAL(12,3), @UFDestino CHAR(2)) RETURNS DECIMAL(12,2)`

* Retornar fórmula simples baseada em peso + tabela auxiliar de coeficientes por UF.

**Ex. 8.2 (Inline Table-Valued)** `ops.fn_PedidosCliente(@ClienteID INT)`

* Retornar conjunto com pedidos do cliente, status e valor total.

---

# Parte 9 — Transações e controle de erros

**Ex. 9.1** Simule um erro em `ops.pr_CriarPedido` (produto inexistente) e comprove `ROLLBACK`.
**Ex. 9.2** Adapte as procedures para logar erros em `ops.LogErros` com: `Procedure`, `Mensagem`, `Data`, `Usuario`.

---

# Parte 10 — Segurança e Governança

**Ex. 10.1** Crie um usuário somente-leitura e conceda permissão de `SELECT` em views, negando acesso direto às tabelas base.
**Ex. 10.2** Crie um `ROLE` `ops_app_role` com permissões de execução nas procedures de negócio.

---

# Parte 11 — Cargas e UPSERT

**Ex. 11.1** Crie tabela `ops.Stg_Produtos` (staging).
**Ex. 11.2** Carregue linhas novas/alteradas em `Produtos` usando `MERGE`:

* Casos: INSERT novos, UPDATE em mudanças de preço/categoria, opcional `OUTPUT` para log.

---

# Parte 12 — Tópicos extras (opcionais)

**Ex. 12.1** Índices: crie `INCLUDE` columns em índices onde fizer sentido (ex.: consultas mais lidas). Comprove impacto no plano de execução.
**Ex. 12.2** Views indexadas: crie 1 view materializada (regras do SQL Server) para um relatório frequente.
**Ex. 12.3** Particionamento: simule uma tabela de pedidos particionada por mês/ano (apenas se estiver em edição do SQL Server que suporta).
**Ex. 12.4** Temporal Tables: crie `ops.Pedidos_Historico` como temporal para auditar mudanças de status/valores.

---

## Dicas de validação ao longo do caminho

* Use `sp_help 'ops.Pedidos'` e `sys.foreign_keys`/`sys.indexes` para conferir metadados.
* Rode `SET STATISTICS IO, TIME ON` para comparar performance com/sem índices.
* Use `EXPLAIN` no SSMS (Display Estimated Execution Plan) para estudar planos.
* Garanta integridade: queries de validação (ex.: pedidos faturados sem itens devem retornar 0).

---

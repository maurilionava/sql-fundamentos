SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Tabelas de auditoria
IF OBJECT_ID('ops.LogPrecoDivergente','U') IS NOT NULL DROP TABLE ops.LogPrecoDivergente;
GO
CREATE TABLE ops.LogPrecoDivergente(
    LogID       INT IDENTITY(1,1) PRIMARY KEY,
    ItemID      INT,
    ProdutoID   INT,
    PrecoEsperado DECIMAL(12,2),
    PrecoInformado DECIMAL(12,2),
    Data        DATETIME2(0) DEFAULT SYSDATETIME()
);
GO

-- Recalcular ValorItem e logar divergências de preço vs. tabela de produtos
IF OBJECT_ID('ops.trg_Itens_ValidaValor','TR') IS NOT NULL DROP TRIGGER ops.trg_Itens_ValidaValor;
GO
CREATE TRIGGER ops.trg_Itens_ValidaValor
ON ops.ItensPedido
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH base AS (
        SELECT i.ItemID, i.ProdutoID, i.Qtde, i.PrecoUnitario,
               p.PrecoUnitario AS PrecoAtual
        FROM inserted i
        JOIN ops.Produtos p ON p.ProdutoID = i.ProdutoID
    )
    -- Loga divergência
    INSERT INTO ops.LogPrecoDivergente(ItemID, ProdutoID, PrecoEsperado, PrecoInformado)
    SELECT b.ItemID, b.ProdutoID, b.PrecoAtual, b.PrecoUnitario
    FROM base b
    WHERE ABS(ISNULL(b.PrecoUnitario,0) - ISNULL(b.PrecoAtual,0)) > 0.009; -- tolerância de 1 centavo

    -- Recalcula ValorItem com o PrecoUnitario informado (respeita o CSV / input)
    UPDATE ip
       SET ValorItem = ROUND(ip.Qtde * ip.PrecoUnitario, 2)
    FROM ops.ItensPedido ip
    JOIN inserted i ON i.ItemID = ip.ItemID;
END
GO

-- Recalcula totais do pedido quando Itens mudarem
IF OBJECT_ID('ops.trg_Pedidos_RecalculaTotais','TR') IS NOT NULL DROP TRIGGER ops.trg_Pedidos_RecalculaTotais;
GO
CREATE TRIGGER ops.trg_Pedidos_RecalculaTotais
ON ops.ItensPedido
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Afectados TABLE (PedidoID INT PRIMARY KEY);
    INSERT INTO @Afectados(PedidoID)
    SELECT DISTINCT ISNULL(i.PedidoID, d.PedidoID)
    FROM inserted i
    FULL JOIN deleted d ON 1=0;

    UPDATE p
       SET ValorBruto   = x.TotalItens,
           ValorLiquido = x.TotalItens - p.Desconto
    FROM ops.Pedidos p
    JOIN (
        SELECT ip.PedidoID, SUM(ip.ValorItem) AS TotalItens
        FROM ops.ItensPedido ip
        JOIN @Afectados a ON a.PedidoID = ip.PedidoID
        GROUP BY ip.PedidoID
    ) x ON x.PedidoID = p.PedidoID;
END
GO

-- Ajusta DtEntrega conforme Status
IF OBJECT_ID('ops.trg_Entregas_Status','TR') IS NOT NULL DROP TRIGGER ops.trg_Entregas_Status;
GO
CREATE TRIGGER ops.trg_Entregas_Status
ON ops.Entregas
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE e
       SET DtEntrega = CASE WHEN i.Status='ENTREGUE' AND e.DtEntrega IS NULL THEN SYSDATETIME()
                            WHEN i.Status='EM_ROTA'   THEN NULL
                            ELSE e.DtEntrega END
    FROM ops.Entregas e
    JOIN inserted i ON i.EntregaID = e.EntregaID;
END
GO

-- Impede NF-e para pedido CANCELADO
IF OBJECT_ID('ops.trg_NFe_PedidoCancelado','TR') IS NOT NULL DROP TRIGGER ops.trg_NFe_PedidoCancelado;
GO
CREATE TRIGGER ops.trg_NFe_PedidoCancelado
ON ops.NFe
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted n
        JOIN ops.Pedidos p ON p.PedidoID = n.PedidoID
        WHERE p.Status = 'CANCELADO'
    )
    BEGIN
        THROW 50100, 'Não é permitido emitir NF-e para pedido CANCELADO.', 1;
    END

    INSERT INTO ops.NFe(Chave, PedidoID, ValorTotal, DtEmissao)
    SELECT Chave, PedidoID, ValorTotal, DtEmissao FROM inserted;
END
GO
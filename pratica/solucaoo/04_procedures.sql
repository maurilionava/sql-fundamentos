SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Tabela de log de erros
IF OBJECT_ID('ops.LogErros','U') IS NOT NULL DROP TABLE ops.LogErros;
GO
CREATE TABLE ops.LogErros(
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    ProcedureName SYSNAME,
    Mensagem NVARCHAR(4000),
    Data DATETIME2(0) DEFAULT SYSDATETIME(),
    Usuario SYSNAME DEFAULT SUSER_SNAME()
);
GO

-- TVP para itens (para pr_CriarPedido)
IF TYPE_ID('ops.TVP_ItensPedido') IS NOT NULL DROP TYPE ops.TVP_ItensPedido;
GO
CREATE TYPE ops.TVP_ItensPedido AS TABLE(
    ProdutoID INT NOT NULL,
    Qtde      DECIMAL(12,3) NOT NULL,
    PrecoUnitario DECIMAL(12,2) NOT NULL
);
GO

-- pr_CriarPedido
IF OBJECT_ID('ops.pr_CriarPedido','P') IS NOT NULL DROP PROCEDURE ops.pr_CriarPedido;
GO
CREATE PROCEDURE ops.pr_CriarPedido
    @ClienteID INT,
    @Itens ops.TVP_ItensPedido READONLY,
    @Desconto DECIMAL(14,2) = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM ops.Clientes WHERE ClienteID = @ClienteID AND Ativo = 1)
            THROW 50000, 'Cliente inválido ou inativo.', 1;

        IF NOT EXISTS (SELECT 1 FROM @Itens)
            THROW 50001, 'Pedido sem itens.', 1;

        DECLARE @PedidoID INT;

        INSERT INTO ops.Pedidos(ClienteID, DataPedido, Status, ValorBruto, Desconto, ValorLiquido)
        VALUES(@ClienteID, SYSDATETIME(), 'ABERTO', 0, @Desconto, 0);

        SET @PedidoID = SCOPE_IDENTITY();

        INSERT INTO ops.ItensPedido(PedidoID, ProdutoID, Qtde, PrecoUnitario, ValorItem)
        SELECT @PedidoID, i.ProdutoID, i.Qtde, i.PrecoUnitario, (i.Qtde*i.PrecoUnitario)
        FROM @Itens i;

        -- Recalcula totais
        UPDATE p
        SET p.ValorBruto   = x.TotalItens,
            p.ValorLiquido = x.TotalItens - p.Desconto
        FROM ops.Pedidos p
        JOIN (SELECT PedidoID, SUM(ValorItem) AS TotalItens
              FROM ops.ItensPedido
              WHERE PedidoID = @PedidoID
              GROUP BY PedidoID) x
          ON x.PedidoID = p.PedidoID;

        COMMIT;
        SELECT @PedidoID AS PedidoID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        INSERT INTO ops.LogErros(ProcedureName, Mensagem)
        VALUES(OBJECT_NAME(@@PROCID), ERROR_MESSAGE());
        THROW;
    END CATCH
END
GO

-- pr_FaturarPedido
IF OBJECT_ID('ops.pr_FaturarPedido','P') IS NOT NULL DROP PROCEDURE ops.pr_FaturarPedido;
GO
CREATE PROCEDURE ops.pr_FaturarPedido
    @PedidoID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM ops.Pedidos WHERE PedidoID=@PedidoID AND Status='ABERTO')
            THROW 50010, 'Pedido inexistente ou não está ABERTO.', 1;

        IF NOT EXISTS (SELECT 1 FROM ops.ItensPedido WHERE PedidoID=@PedidoID)
            THROW 50011, 'Pedido sem itens.', 1;

        DECLARE @ValorTotal DECIMAL(14,2);
        SELECT @ValorTotal = (SUM(ValorItem) - MAX(Desconto))
        FROM ops.ItensPedido ip
        JOIN ops.Pedidos p ON p.PedidoID = ip.PedidoID
        WHERE ip.PedidoID = @PedidoID;

        INSERT INTO ops.NFe(Chave, PedidoID, ValorTotal, DtEmissao)
        VALUES (REPLICATE('0', 44), @PedidoID, @ValorTotal, SYSDATETIME());

        UPDATE ops.Pedidos
          SET Status='FATURADO',
              ValorBruto = (SELECT SUM(ValorItem) FROM ops.ItensPedido WHERE PedidoID=@PedidoID),
              ValorLiquido = (SELECT SUM(ValorItem) FROM ops.ItensPedido WHERE PedidoID=@PedidoID) - Desconto
        WHERE PedidoID=@PedidoID;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        INSERT INTO ops.LogErros(ProcedureName, Mensagem)
        VALUES(OBJECT_NAME(@@PROCID), ERROR_MESSAGE());
        THROW;
    END CATCH
END
GO

-- pr_GerarCTeEntrega
IF OBJECT_ID('ops.pr_GerarCTeEntrega','P') IS NOT NULL DROP PROCEDURE ops.pr_GerarCTeEntrega;
GO
CREATE PROCEDURE ops.pr_GerarCTeEntrega
    @PedidoID INT,
    @TransportadoraID INT,
    @MotoristaID INT,
    @ValorFrete DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM ops.Pedidos WHERE PedidoID=@PedidoID AND Status='FATURADO')
            THROW 50020, 'Pedido inexistente ou não FATURADO.', 1;

        DECLARE @CTeID INT;
        INSERT INTO ops.CTe(Numero, TransportadoraID, PedidoID, ValorFrete, DtEmissao)
        VALUES(REPLICATE('9',44), @TransportadoraID, @PedidoID, @ValorFrete, SYSDATETIME());
        SET @CTeID = SCOPE_IDENTITY();

        INSERT INTO ops.Entregas(PedidoID, CTeID, MotoristaID, DtSaida, DtEntrega, Status)
        VALUES(@PedidoID, @CTeID, @MotoristaID, SYSDATETIME(), NULL, 'EM_ROTA');

        COMMIT;
        SELECT @CTeID AS CTeID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        INSERT INTO ops.LogErros(ProcedureName, Mensagem)
        VALUES(OBJECT_NAME(@@PROCID), ERROR_MESSAGE());
        THROW;
    END CATCH
END
GO

-- pr_ConcluirEntrega
IF OBJECT_ID('ops.pr_ConcluirEntrega','P') IS NOT NULL DROP PROCEDURE ops.pr_ConcluirEntrega;
GO
CREATE PROCEDURE ops.pr_ConcluirEntrega
    @EntregaID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ops.Entregas
       SET Status = 'ENTREGUE',
           DtEntrega = ISNULL(DtEntrega, SYSDATETIME())
     WHERE EntregaID = @EntregaID;
END
GO

-- pr_ResumoCliente
IF OBJECT_ID('ops.pr_ResumoCliente','P') IS NOT NULL DROP PROCEDURE ops.pr_ResumoCliente;
GO
CREATE PROCEDURE ops.pr_ResumoCliente
    @ClienteID INT,
    @DataIni DATE,
    @DataFim DATE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH vendas AS (
        SELECT p.PedidoID, p.DataPedido, p.ValorLiquido
        FROM ops.Pedidos p
        WHERE p.ClienteID = @ClienteID
          AND p.DataPedido >= @DataIni
          AND p.DataPedido < DATEADD(DAY,1,@DataFim)
          AND p.Status = 'FATURADO'
    ),
    por_categoria AS (
        SELECT pr.Categoria, SUM(ip.ValorItem) AS TotalCat
        FROM ops.ItensPedido ip
        JOIN ops.Pedidos p ON p.PedidoID = ip.PedidoID
        JOIN ops.Produtos pr ON pr.ProdutoID = ip.ProdutoID
        WHERE p.ClienteID = @ClienteID
          AND p.DataPedido >= @DataIni
          AND p.DataPedido < DATEADD(DAY,1,@DataFim)
          AND p.Status = 'FATURADO'
        GROUP BY pr.Categoria
    )
    SELECT
        (SELECT COUNT(*) FROM vendas) AS QtdePedidos,
        (SELECT ISNULL(SUM(ValorLiquido),0) FROM vendas) AS Total,
        (SELECT ISNULL(AVG(ValorLiquido),0) FROM vendas) AS TicketMedio;

    SELECT * FROM por_categoria ORDER BY TotalCat DESC;
END
GO
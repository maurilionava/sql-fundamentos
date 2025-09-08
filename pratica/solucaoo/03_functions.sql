SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Tabela auxiliar de coeficientes de frete por UF (exemplo simples)
IF OBJECT_ID('ops.FreteCoefUF','U') IS NOT NULL DROP TABLE ops.FreteCoefUF;
GO
CREATE TABLE ops.FreteCoefUF(
    UF CHAR(2) PRIMARY KEY,
    Coeficiente DECIMAL(6,3) NOT NULL
);
GO

MERGE ops.FreteCoefUF AS T
USING (VALUES
    ('SP', 1.00),('RJ',1.05),('MG',1.03),('RS',1.07),('SC',1.06),
    ('PR',1.04),('BA',1.10),('PE',1.12),('CE',1.11),('GO',1.02),
    ('ES',1.03),('MT',1.15),('MS',1.14),('PA',1.20),('DF',1.08)
) AS S(UF,Coeficiente)
ON T.UF = S.UF
WHEN MATCHED THEN UPDATE SET Coeficiente = S.Coeficiente
WHEN NOT MATCHED THEN INSERT(UF,Coeficiente) VALUES(S.UF,S.Coeficiente);
GO

-- fn_CalculaFreteEstimado: fórmula simplificada
IF OBJECT_ID('ops.fn_CalculaFreteEstimado','FN') IS NOT NULL DROP FUNCTION ops.fn_CalculaFreteEstimado;
GO
CREATE FUNCTION ops.fn_CalculaFreteEstimado(
    @PesoTotal DECIMAL(12,3),
    @UFDestino CHAR(2)
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @base DECIMAL(12,2) = 25.00;
    DECLARE @coef DECIMAL(6,3) = ISNULL((SELECT Coeficiente FROM ops.FreteCoefUF WHERE UF = @UFDestino), 1.10);
    RETURN CAST(@base + (@PesoTotal * 3.5 * @coef) AS DECIMAL(12,2));
END;
GO

-- fn_PedidosCliente: inline TVF
IF OBJECT_ID('ops.fn_PedidosCliente','IF') IS NOT NULL DROP FUNCTION ops.fn_PedidosCliente;
GO
CREATE FUNCTION ops.fn_PedidosCliente(@ClienteID INT)
RETURNS TABLE
AS RETURN
(
    SELECT p.PedidoID, p.DataPedido, p.Status, p.ValorBruto, p.Desconto, p.ValorLiquido
    FROM ops.Pedidos p
    WHERE p.ClienteID = @ClienteID
);
GO
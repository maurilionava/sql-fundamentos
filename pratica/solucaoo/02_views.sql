SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('ops.vw_PedidosDetalhados','V') IS NOT NULL DROP VIEW ops.vw_PedidosDetalhados;
GO
CREATE VIEW ops.vw_PedidosDetalhados
AS
SELECT
    p.PedidoID,
    p.DataPedido,
    p.Status,
    c.ClienteID,
    c.Nome        AS NomeCliente,
    p.ValorBruto,
    p.Desconto,
    p.ValorLiquido,
    e.Cidade      AS CidadeEntrega,
    e.UF          AS UFEntrega,
    nfe.NFeID,
    cte.CTeID
FROM ops.Pedidos p
JOIN ops.Clientes c
  ON c.ClienteID = p.ClienteID
LEFT JOIN ops.Enderecos e
  ON e.ClienteID = p.ClienteID AND e.Tipo = 'ENTREGA'
LEFT JOIN ops.NFe nfe
  ON nfe.PedidoID = p.PedidoID
LEFT JOIN ops.CTe cte
  ON cte.PedidoID = p.PedidoID;
GO

IF OBJECT_ID('ops.vw_PerformanceTransportadoras','V') IS NOT NULL DROP VIEW ops.vw_PerformanceTransportadoras;
GO
CREATE VIEW ops.vw_PerformanceTransportadoras
AS
WITH entregas AS (
    SELECT
        t.TransportadoraID,
        t.RazaoSocial,
        e.EntregaID,
        e.DtSaida,
        e.DtEntrega,
        CASE WHEN e.DtEntrega IS NOT NULL
             AND e.DtEntrega > DATEADD(DAY, 5, e.DtSaida) THEN 0 ELSE 1 END AS EntregaNoPrazo
    FROM ops.Entregas e
    JOIN ops.CTe cte
      ON cte.CTeID = e.CTeID
    JOIN ops.Transportadoras t
      ON t.TransportadoraID = cte.TransportadoraID
)
SELECT
    TransportadoraID,
    RazaoSocial,
    COUNT(*) AS QtdeEntregas,
    SUM(EntregaNoPrazo) AS EntregasNoPrazo,
    CAST(100.0 * SUM(EntregaNoPrazo) / NULLIF(COUNT(*),0) AS DECIMAL(5,2)) AS TaxaNoPrazo
FROM entregas
GROUP BY TransportadoraID, RazaoSocial;
GO

IF OBJECT_ID('ops.vw_TopProdutosUltimos30Dias','V') IS NOT NULL DROP VIEW ops.vw_TopProdutosUltimos30Dias;
GO
CREATE VIEW ops.vw_TopProdutosUltimos30Dias
AS
SELECT TOP (10)
    ip.ProdutoID,
    pr.Nome AS NomeProduto,
    SUM(ip.ValorItem) AS Faturamento30d
FROM ops.ItensPedido ip
JOIN ops.Pedidos p
  ON p.PedidoID = ip.PedidoID
JOIN ops.Produtos pr
  ON pr.ProdutoID = ip.ProdutoID
WHERE p.DataPedido >= DATEADD(DAY, -30, SYSDATETIME())
  AND p.Status = 'FATURADO'
GROUP BY ip.ProdutoID, pr.Nome
ORDER BY Faturamento30d DESC;
GO
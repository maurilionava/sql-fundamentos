/* Ajuste o caminho para a pasta onde salvou os CSVs */
DECLARE @pasta NVARCHAR(400) = N'C:\dados\csv';  -- <- edite aqui

-- Exemplo BULK INSERT (é necessário que o SQL Server tenha acesso à pasta/arquivo)
-- Obs.: Se preferir, use o Import Flat File (SSMS) ou OPENROWSET(BULK...).
BULK INSERT ops.Clientes
FROM @pasta + '\clientes.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT ops.Enderecos
FROM @pasta + '\enderecos.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT ops.Produtos
FROM @pasta + '\produtos.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT ops.Pedidos
FROM @pasta + '\pedidos.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT ops.ItensPedido
FROM @pasta + '\itens_pedido.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT ops.Transportadoras
FROM @pasta + '\transportadoras.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT ops.Motoristas
FROM @pasta + '\motoristas.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT ops.NFe
FROM @pasta + '\nfe.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT ops.CTe
FROM @pasta + '\cte.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);

BULK INSERT ops.Entregas
FROM @pasta + '\entregas.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
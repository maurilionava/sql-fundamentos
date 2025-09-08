SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'ops')
    EXEC('CREATE SCHEMA ops AUTHORIZATION dbo;');
GO

/* =======================
   DATABASE OBJECTS (DDL)
   ======================= */

-- CLIENTES
IF OBJECT_ID('ops.Clientes','U') IS NOT NULL DROP TABLE ops.Clientes;
GO
CREATE TABLE ops.Clientes (
    ClienteID      INT IDENTITY(1,1) PRIMARY KEY,
    Nome           NVARCHAR(160) NOT NULL,
    CpfCnpj        VARCHAR(14) NULL,  -- CSV traz só dígitos (11 = CPF; 14 = CNPJ)
    Email          VARCHAR(200) NULL,
    DtCadastro     DATETIME2(0) NOT NULL CONSTRAINT DF_Clientes_DtCadastro DEFAULT (SYSDATETIME()),
    Ativo          BIT NOT NULL CONSTRAINT DF_Clientes_Ativo DEFAULT (1),
    CONSTRAINT UQ_Clientes_CpfCnpj UNIQUE (CpfCnpj),
    CONSTRAINT CK_Clientes_CpfCnpj_Len CHECK (CpfCnpj IS NULL OR LEN(CpfCnpj) IN (11,14))
);
GO

-- ENDERECOS
IF OBJECT_ID('ops.Enderecos','U') IS NOT NULL DROP TABLE ops.Enderecos;
GO
CREATE TABLE ops.Enderecos (
    EnderecoID INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID  INT NOT NULL,
    Tipo       VARCHAR(20) NOT NULL,  -- COBRANCA | ENTREGA
    Logradouro NVARCHAR(180) NOT NULL,
    Numero     VARCHAR(10) NOT NULL,
    Bairro     NVARCHAR(120) NOT NULL,
    Cidade     NVARCHAR(120) NOT NULL,
    UF         CHAR(2) NOT NULL,
    CEP        CHAR(8) NOT NULL,
    CONSTRAINT FK_Enderecos_Clientes FOREIGN KEY (ClienteID) REFERENCES ops.Clientes(ClienteID),
    CONSTRAINT CK_Enderecos_Tipo CHECK (Tipo IN ('COBRANCA','ENTREGA')),
    CONSTRAINT CK_Enderecos_UF CHECK (LEN(UF)=2),
    CONSTRAINT CK_Enderecos_CEP CHECK (LEN(CEP)=8)
);
GO

-- PRODUTOS
IF OBJECT_ID('ops.Produtos','U') IS NOT NULL DROP TABLE ops.Produtos;
GO
CREATE TABLE ops.Produtos (
    ProdutoID     INT IDENTITY(1,1) PRIMARY KEY,
    Nome          NVARCHAR(160) NOT NULL,
    Categoria     NVARCHAR(80)  NOT NULL,
    PrecoUnitario DECIMAL(12,2) NOT NULL,
    Ativo         BIT NOT NULL CONSTRAINT DF_Produtos_Ativo DEFAULT (1),
    CONSTRAINT CK_Produtos_Preco_Pos CHECK (PrecoUnitario > 0)
);
GO

-- PEDIDOS
IF OBJECT_ID('ops.Pedidos','U') IS NOT NULL DROP TABLE ops.Pedidos;
GO
CREATE TABLE ops.Pedidos (
    PedidoID     INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID    INT NOT NULL,
    DataPedido   DATETIME2(0) NOT NULL,
    Status       VARCHAR(20) NOT NULL,  -- ABERTO | FATURADO | CANCELADO
    ValorBruto   DECIMAL(14,2) NOT NULL CONSTRAINT DF_Pedidos_ValorBruto DEFAULT (0),
    Desconto     DECIMAL(14,2) NOT NULL CONSTRAINT DF_Pedidos_Desconto  DEFAULT (0),
    ValorLiquido DECIMAL(14,2) NOT NULL CONSTRAINT DF_Pedidos_ValorLiq  DEFAULT (0),
    CONSTRAINT FK_Pedidos_Clientes FOREIGN KEY (ClienteID) REFERENCES ops.Clientes(ClienteID),
    CONSTRAINT CK_Pedidos_Status CHECK (Status IN ('ABERTO','FATURADO','CANCELADO')),
    CONSTRAINT CK_Pedidos_Valores CHECK (ValorBruto >= 0 AND Desconto >= 0 AND ValorBruto >= Desconto)
);
GO

-- ITENS DO PEDIDO
IF OBJECT_ID('ops.ItensPedido','U') IS NOT NULL DROP TABLE ops.ItensPedido;
GO
CREATE TABLE ops.ItensPedido (
    ItemID        INT IDENTITY(1,1) PRIMARY KEY,
    PedidoID      INT NOT NULL,
    ProdutoID     INT NOT NULL,
    Qtde          DECIMAL(12,3) NOT NULL,
    PrecoUnitario DECIMAL(12,2) NOT NULL,
    ValorItem     DECIMAL(14,2) NOT NULL,
    CONSTRAINT FK_Itens_Pedidos  FOREIGN KEY (PedidoID)  REFERENCES ops.Pedidos(PedidoID),
    CONSTRAINT FK_Itens_Produtos FOREIGN KEY (ProdutoID) REFERENCES ops.Produtos(ProdutoID),
    CONSTRAINT UQ_ItensPedido UNIQUE (PedidoID, ProdutoID),
    CONSTRAINT CK_Itens_Qtde CHECK (Qtde > 0),
    CONSTRAINT CK_Itens_Preco CHECK (PrecoUnitario > 0)
);
GO

-- TRANSPORTADORAS
IF OBJECT_ID('ops.Transportadoras','U') IS NOT NULL DROP TABLE ops.Transportadoras;
GO
CREATE TABLE ops.Transportadoras (
    TransportadoraID INT IDENTITY(1,1) PRIMARY KEY,
    RazaoSocial      NVARCHAR(160) NOT NULL,
    Cnpj             VARCHAR(14) NOT NULL UNIQUE,
    Ativo            BIT NOT NULL CONSTRAINT DF_Transp_Ativo DEFAULT (1),
    CONSTRAINT CK_Transp_Cnpj_Len CHECK (LEN(Cnpj)=14)
);
GO

-- MOTORISTAS
IF OBJECT_ID('ops.Motoristas','U') IS NOT NULL DROP TABLE ops.Motoristas;
GO
CREATE TABLE ops.Motoristas (
    MotoristaID      INT IDENTITY(1,1) PRIMARY KEY,
    Nome             NVARCHAR(160) NOT NULL,
    Cpf              VARCHAR(11) NOT NULL UNIQUE,
    CNH              VARCHAR(11) NOT NULL,
    TransportadoraID INT NOT NULL,
    CONSTRAINT FK_Motoristas_Transp FOREIGN KEY (TransportadoraID) REFERENCES ops.Transportadoras(TransportadoraID),
    CONSTRAINT CK_Motoristas_Cpf_Len CHECK (LEN(Cpf)=11)
);
GO

-- CTe
IF OBJECT_ID('ops.CTe','U') IS NOT NULL DROP TABLE ops.CTe;
GO
CREATE TABLE ops.CTe (
    CTeID            INT IDENTITY(1,1) PRIMARY KEY,
    Numero           VARCHAR(44) NOT NULL UNIQUE,
    TransportadoraID INT NOT NULL,
    PedidoID         INT NOT NULL,
    ValorFrete       DECIMAL(12,2) NOT NULL,
    DtEmissao        DATETIME2(0) NOT NULL,
    CONSTRAINT FK_CTe_Transp  FOREIGN KEY (TransportadoraID) REFERENCES ops.Transportadoras(TransportadoraID),
    CONSTRAINT FK_CTe_Pedidos FOREIGN KEY (PedidoID) REFERENCES ops.Pedidos(PedidoID)
);
GO

-- NFe
IF OBJECT_ID('ops.NFe','U') IS NOT NULL DROP TABLE ops.NFe;
GO
CREATE TABLE ops.NFe (
    NFeID      INT IDENTITY(1,1) PRIMARY KEY,
    Chave      VARCHAR(44) NOT NULL UNIQUE,
    PedidoID   INT NOT NULL,
    ValorTotal DECIMAL(14,2) NOT NULL,
    DtEmissao  DATETIME2(0) NOT NULL,
    CONSTRAINT FK_NFe_Pedidos FOREIGN KEY (PedidoID) REFERENCES ops.Pedidos(PedidoID)
);
GO

-- ENTREGAS
IF OBJECT_ID('ops.Entregas','U') IS NOT NULL DROP TABLE ops.Entregas;
GO
CREATE TABLE ops.Entregas (
    EntregaID   INT IDENTITY(1,1) PRIMARY KEY,
    PedidoID    INT NOT NULL,
    CTeID       INT NOT NULL,
    MotoristaID INT NOT NULL,
    DtSaida     DATETIME2(0) NOT NULL,
    DtEntrega   DATETIME2(0) NULL,
    Status      VARCHAR(15) NOT NULL, -- EM_ROTA | ENTREGUE | DEVOLVIDO
    CONSTRAINT FK_Entregas_Pedidos    FOREIGN KEY (PedidoID)    REFERENCES ops.Pedidos(PedidoID),
    CONSTRAINT FK_Entregas_CTe        FOREIGN KEY (CTeID)       REFERENCES ops.CTe(CTeID),
    CONSTRAINT FK_Entregas_Motoristas FOREIGN KEY (MotoristaID) REFERENCES ops.Motoristas(MotoristaID),
    CONSTRAINT CK_Entregas_Status CHECK (Status IN ('EM_ROTA','ENTREGUE','DEVOLVIDO'))
);
GO

/* Indexes úteis */
CREATE INDEX IX_Pedidos_ClienteID_DataPedido ON ops.Pedidos(ClienteID, DataPedido);
CREATE INDEX IX_ItensPedido_PedidoID ON ops.ItensPedido(PedidoID);
CREATE INDEX IX_ItensPedido_ProdutoID ON ops.ItensPedido(ProdutoID);
CREATE INDEX IX_Entregas_Status ON ops.Entregas(Status);
CREATE INDEX IX_NFe_PedidoID ON ops.NFe(PedidoID);
CREATE INDEX IX_CTe_PedidoID ON ops.CTe(PedidoID);
GO
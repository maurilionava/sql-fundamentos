--TRIGGERS DDL(ESTRUTURA DO BANCO); DML(DADOS); LOGON
CREATE TRIGGER NOME
ON TABELA
FOR INSERT,UPDATE,DELETE
AS
BEGIN
    --BLOCO DE INSTRUÇÕES
END

/* 
    EXERCICIOS
    1. Crie uma trigger que impede a exclusão de endereços vinculados a empresas ou funcionários.
    2. Crie uma trigger que registra (com PRINT) uma mensagem sempre que um novo funcionário for inserido.
    3. Crie uma trigger que verifica se o salário de um funcionário é maior que R$ 100.000,00 antes de inserir ou atualizar. Se for, bloqueie com ROLLBACK.
    4. Crie uma trigger que impede alteração do CNPJ de uma empresa (simule uma auditoria).
    5. Crie uma trigger no nível de DATABASE que impede a criação de novos sinônimos (CREATE SYNONYM).    
*/
--EXERCICIO 1
CREATE TRIGGER TRG_EX01
ON DBO.ENDERECO
FOR DELETE
AS
BEGIN
    IF EXISTS(SELECT 1 FROM dbo.Empresa E 
            WHERE E.EnderecoId IN (SELECT Id FROM DELETED)) 
        OR EXISTS(SELECT 1 FROM dbo.Funcionario F
            WHERE F.EnderecoId IN (SELECT Id FROM DELETED))
    BEGIN
        ROLLBACK;
        PRINT 'EXCLUSÃO DE ENDEREÇO VINCULADO COM EMPRESA OU FUNCIONÁRIO NEGADA'
    END
END

--EXERCICIO 2
CREATE TRIGGER TRG_EX02
ON dbo.Funcionario
FOR INSERT
AS
BEGIN
    PRINT 'NOVO USUÁRIO REGISTRADO'
END

--EXERCICIO 2 MELHORADO
CREATE TRIGGER TRG_EX02_2
ON dbo.Funcionario
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;  -- Evita mensagens de contagem de linhas, melhora performance

    INSERT INTO LOG_FUNCIONARIO(Nome,DataHora,Operacao)
    SELECT Nome,GETDATE(),'I'
    FROM INSERTED
END

--EXERCICIO 3
CREATE TRIGGER EX_03
ON dbo.Funcionario
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(SELECT 1 FROM INSERTED WHERE Salario > 100000)
    BEGIN
        ROLLBACK;
        RAISERROR('VALOR DE SALÁRIO SUPERIOR AO MÁXIMO PERMITIDO',16,1);
    END
END;

--EXERCICIO EXTRA
CREATE TRIGGER TRG_BKP_EMPRESA
ON dbo.Empresa
FOR INSERT
AS
IF UPDATE(COLUNA)
BEGIN
    DECLARE @NOMEFANTASIA NVARCHAR(100)
    DECLARE @USUARIO NVARCHAR(100)
    DECLARE @CNPJ CHAR(18)
    DECLARE @NDATA DATE
    DECLARE @ACAO NVARCHAR(100)

    SELECT @NOMEFANTASIA = NomeFantasia FROM inserted --inserted ou deleted
    SELECT @CNPJ = CNPJ FROM inserted --inserted ou deleted

    SET @USUARIO = SUSER_NAME()
    SET @ACAO = 'I'
    SET @NDATA = GETDATE()

    INSERT INTO BKP_EMPRESA(USUARIO, NOMEFANTASIA, CNPJ, ACAO, NDATA) 
    VALUES(@USUARIO, @NOMEFANTASIA, @CNPJ, @ACAO, @NDATA)

    PRINT 'FIM DA EXECUÇÃO DA TRIGGER TRG_BKP_EMPRESA'
END
GO

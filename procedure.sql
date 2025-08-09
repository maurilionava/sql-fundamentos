/*
    @@IDENTITY ULTIMO ID INSERIDO NA BASE DE DADOS
    SP_COLUMNS TABELA --DETALHAMENTO DE TABELA
    SP_HELP TABELA --DETALHAMENTO DE TABELA
*/

CREATE PROCEDURE NOME @PARAMETRO INT
AS
BEGIN
    --BLOCO DE INSTRUÇÕES
END
GO

/*
    EXERCICIOS
    --CRUD Simples
    1. InserirFuncionario
    Recebe nome, CPF, data de nascimento, cargo, salário, empresaId e enderecoId e insere um novo funcionário.

    2. AtualizarSalarioFuncionario
    Recebe Id do funcionário e novo salário, e atualiza o valor.

    3. ExcluirFuncionarioPorId
    Recebe o Id e remove o funcionário correspondente.

    4. AtualizarEnderecoEmpresa
    Recebe o Id da empresa e um novo EnderecoId, e atualiza o endereço da empresa.

    --Com validação e lógica
    5. InserirFuncionarioComValidacao
    Antes de inserir, verifica:

        Se o CPF já existe → se sim, aborta.

        Se o salário está acima de R$ 100.000 → se sim, aborta.

    6. ListarFuncionariosPorCargo
    Recebe o nome de um cargo e retorna todos os funcionários com esse cargo.

    7. ObterFuncionariosPorCidade
    Recebe o nome de uma cidade e retorna todos os funcionários que moram nela (usando Endereco).

    8. ContarFuncionariosPorEmpresa
    Recebe o Id da empresa e retorna a quantidade de funcionários nela.

    9. ListarFuncionariosComMesmoEndereco
    Retorna todos os funcionários que moram no mesmo endereço que outro(s) funcionário(s).

    --Com múltiplas tabelas / lógica mais avançada
    10. ListarFuncionariosComDadosCompletos
    Junta Funcionario, Empresa e Endereco para retornar os dados completos de cada funcionário (nome, cargo, salário, empresa, cidade etc.).

    11. ListarEmpresasSemFuncionarios
    Mostra as empresas que ainda não têm nenhum funcionário.

    12. InserirEmpresaComEnderecoNovo
    Insere um novo endereço, pega o ID gerado, e depois insere a empresa usando esse ID.

    13. AumentarSalarioPorCargo
    Recebe um cargo e um percentual. Aumenta o salário de todos os funcionários com aquele cargo.
*/
--EXERCICIO 01

--
CREATE PROCEDURE SP_SOMAR @VALOR_1 INT, @VALOR_2 INT
AS
    SELECT @VALOR_1 + @VALOR_2 AS "SOMA"
    PRINT 'STORED PROCEDURE SP_SOMAR EXECUTADA COM SUCESSO'
END
--
CREATE PROCEDURE SP_LOGAR @ACAO CHAR, @DESCRICAO VARCHAR
AS
    INSERT INTO LOG(ACAO, DESCRICAO, DATAHORA)
    VALUES(@ACAO, @DESCRICAO, GETDATE())

    PRINT 'NOVOS REGISTROS DE LOG INSERIDOS NA TABELA'
END
GO
--
--VIEW: UMA CONSULTA ARMAZENADA
CREATE VIEW VW_NOME
AS
    --BLOCO DE INSTRUÇÕES
--
/*
    EXERCICIOS
    --Com junções entre tabelas
    1. vw_Funcionarios_Completo
    Junta Funcionario, Empresa e Endereco e mostra dados relevantes de todos eles.

    2. vw_Empresas_ComFuncionarios
    Mostra cada empresa com seus respectivos funcionários (nome, cargo, salário).

    3. vw_FuncionariosPorCidade
    Mostra cidade, quantidade de funcionários e salário médio em cada cidade.

    4. vw_FuncionariosSalariosAltos
    Mostra apenas os funcionários com salário acima de R$ 10.000.

    5. vw_Empresas_Endereco
    Mostra os dados da empresa + cidade e estado onde ela está localizada.

    --Views para dashboards ou relatórios
    6. vw_ResumoFuncionarios
        Total de funcionários
        Média salarial geral
        Salário mínimo e máximo
        Quantos cargos distintos existem

    7. vw_ResumoEmpresas
        Total de empresas
        Total de funcionários por empresa
        Média salarial por empresa

    8. vw_CargosMaisComuns
    Mostra os cargos existentes e a contagem de funcionários em cada um, ordenado do mais comum para o menos comum.
*/
CREATE VIEW VW_FUNCIONARIO_ENDERECO
AS
    SELECT F.Nome, F.Cargo, F.Salario, Emp.NomeFantasia, E.Cidade, E.Estado, E.Pais
    FROM dbo.Funcionario F
    INNER JOIN dbo.Endereco E
    ON F.EnderecoId = E.Id
    INNER JOIN dbo.Empresa Emp
    ON F.EmpresaId = Emp.Id
--
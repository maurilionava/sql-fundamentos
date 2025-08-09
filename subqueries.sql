SELECT 
    *, (F.Salario * 12) AS SALARIO_ANUAL 
FROM 
    dbo.Funcionario AS F
WHERE 
    F.Salario = (
        SELECT MIN(F.Salario)
        FROM dbo.Funcionario
    ) OR F.Salario = (
        SELECT MAX(F.Salario)
        FROM dbo.Funcionario
    )
ORDER BY F.Salario DESC
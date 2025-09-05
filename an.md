# CONCEITOS
## Banco de dados
- Banco de Dados: Conjunto de dados armazenados de forma estruturada
- Tabela: Estrutura que armazena dados em linhas e colunas
- Registro: Linha da tabela, representa uma única ocorrência de dados
- Atributo ou campo: Coluna da tabela, representa uma característica dos dados
- 1 caracter = 1 byte. 1 byte = 8 bits. Exemplo: VARCHAR(100) = 100 bytes
- Chave primária: Atributo ou conjunto de atributos que identifica unicamente um registro na tabela
    ```
    PRIMARY KEY (coluna1, coluna2)
    ```
- Chave estrangeira: Atributo ou conjunto de atributos que estabelece um vínculo entre registros de tabelas diferentes
    ```
    FOREIGN KEY (coluna) REFERENCES tabela(coluna)
    ```
- Chaves natural e artificial:
    - Chave natural: Atributo ou conjunto de atributos que já possui significado no mundo real e é utilizado para identificar registros (ex: CPF, e-mail).
    - Chave artificial: Atributo ou conjunto de atributos criado especificamente para identificar registros, sem significado intrínseco (ex: ID gerado automaticamente).
- Índice: Estrutura que melhora a velocidade de recuperação de dados em uma tabela
    ```
    CREATE INDEX idx_nome ON tabela(coluna)
    ```
- Cardinalidade: Número de elementos em um conjunto ou relação entre tabelas. Pode ser representada como:
    - 1:1 (um para um)
        ```
        SELECT * FROM tabela1
        JOIN tabela2 ON tabela1.id = tabela2.id
        ```
    - 1:N (um para muitos)
        ```
        SELECT * FROM tabela1
        JOIN tabela2 ON tabela1.id = tabela2.id_tabela1
        ```
    - N:1 (muitos para um)
        ```
        SELECT * FROM tabela1
        JOIN tabela2 ON tabela1.id_tabela2 = tabela2.id
        ```
    - N:N (muitos para muitos)
        ```
        SELECT * FROM tabela1
        JOIN tabela2 ON tabela1.id = tabela2.id_tabela1
        ```
- Integridade referencial: Garantia de que as relações entre tabelas sejam mantidas corretamente
- Transação: Conjunto de operações que devem ser executadas como uma unidade, garantindo consistência dos dados
    ```
    BEGIN TRANSACTION
    -- Operações SQL
    COMMIT
    ```
- ACID: Propriedades que garantem a confiabilidade das transações em um banco de dados
    - Atomicidade: Todas as operações da transação são concluídas ou nenhuma é aplicada
    - Consistência: A transação leva o banco de dados de um estado válido para outro estado válido
    - Isolamento: As transações são isoladas umas das outras, evitando interferências
    - Durabilidade: Uma vez que a transação é confirmada, suas alterações são permanentes, mesmo em caso de falhas
- Schema: Estrutura que define a organização do banco de dados, incluindo tabelas, colunas e relacionamentos
- View: Representação virtual de uma tabela, que pode incluir dados de uma ou mais tabelas
    ```
    CREATE VIEW nome_view AS 
    SELECT coluna1, coluna2 
    FROM tabela 
    WHERE condição
    ```
- Trigger: Procedimento que é automaticamente executado em resposta a certos eventos na tabela
    ```
    CREATE TRIGGER nome_trigger
    AFTER INSERT ON tabela
    FOR EACH ROW
    BEGIN
        -- Ações a serem executadas
    END
    ```
- Stored Procedure: Conjunto de instruções SQL que podem ser armazenadas e reutilizadas no banco de dados
    ```
    CREATE PROCEDURE nome_procedimento (parametro1 tipo1, parametro2 tipo2)
    BEGIN
        -- Instruções SQL
    END
    ```
- Cursor: Estrutura que permite a navegação pelos registros de uma tabela, um por um
    ```
    DECLARE cursor_nome CURSOR FOR
    SELECT coluna1, coluna2 FROM tabela
    ```
- Join: Operação que combina registros de duas ou mais tabelas com base em um campo comum
  - Tipos de Join: 
    - Inner Join: Retorna apenas os registros que possuem correspondência em ambas as tabelas
    - Left Join: Retorna todos os registros da tabela à esquerda e os registros correspondentes da tabela à direita. Se não houver correspondência, os valores da tabela à direita serão nulos
    - Right Join: Retorna todos os registros da tabela à direita e os registros correspondentes da tabela à esquerda. Se não houver correspondência, os valores da tabela à esquerda serão nulos
    - Full Join: Retorna todos os registros quando há uma correspondência em uma das tabelas. Se não houver correspondência, os valores da tabela sem correspondência serão nulos
    - Exemplos:
      ```
      SELECT * FROM tabela1
      JOIN tabela2 ON tabela1.id = tabela2.id

      SELECT * FROM tabela1
      LEFT JOIN tabela2 ON tabela1.id = tabela2.id

      SELECT * FROM tabela1
      RIGHT JOIN tabela2 ON tabela1.id = tabela2.id

      SELECT * FROM tabela1
      FULL JOIN tabela2 ON tabela1.id = tabela2.id
      ```
- Subquery: Consulta SQL aninhada dentro de outra consulta
    ```
    SELECT coluna1 FROM tabela1
    WHERE coluna2 IN (SELECT coluna2 FROM tabela2 WHERE condição)
    ```
- Constraint: Regra que limita os valores que podem ser inseridos em uma tabela (ex: NOT NULL, UNIQUE, CHECK)
    ```
    CONSTRAINT nome_constraint CHECK (condição)
    ```
- SQL (Structured Query Language): Linguagem padrão para gerenciamento de bancos de dados relacionais
- TSQL (Transact-SQL): Extensão da linguagem SQL usada no Microsoft SQL Server, que inclui recursos adicionais, como variáveis, loops e tratamento de erros
    ```
    DECLARE @variavel INT
    SET @variavel = 10
    WHILE @variavel > 0
    BEGIN
        PRINT @variavel
        SET @variavel = @variavel - 1
    END
    ```
- Tipos de Dados:
    - Char: Tipo de dado que armazena cadeias de caracteres de comprimento fixo
    - Varchar: Tipo de dado que armazena cadeias de caracteres de comprimento variável
    - Int: Tipo de dado que armazena números inteiros
    - Float: Tipo de dado que armazena números de ponto flutuante
    - Date: Tipo de dado que armazena datas
    - Time: Tipo de dado que armazena horas
    - Datetime: Tipo de dado que armazena datas e horas
    - Boolean: Tipo de dado que armazena valores verdadeiros ou falsos
    - Enum: Tipo de dado que armazena um conjunto fixo de valores possíveis
    - Blob: Tipo de dado que armazena dados binários grandes, como imagens ou arquivos
- Seleção, projeção, junção: Operações fundamentais em consultas SQL
    - Seleção: Filtra registros com base em condições específicas
        ```
        WHERE condição
        ```
    - Projeção: Seleciona colunas específicas de uma tabela
        ```
        SELECT coluna1, coluna2
        ```
    - Junção: Combina registros de duas ou mais tabelas com base em um campo comum
        ```
        JOIN tabela2 ON tabela1.id = tabela2.id
        ```
- Processos de modelagem: Conjunto de etapas para criar um modelo de dados
    - Conceitual: Representa a visão geral do banco de dados, sem se preocupar com a implementação
    - Lógica: Define a estrutura do banco de dados de forma mais detalhada, incluindo tabelas e relacionamentos
    - Física: Implementa a estrutura lógica no SGBD escolhido, definindo como os dados serão armazenados
- Teoria dos conjuntos: Base matemática para a modelagem de dados, que trata de conjuntos de elementos e suas relações
    - Conjunto: Coleção de elementos distintos
    - União: Combinação de dois ou mais conjuntos
    - Interseção: Elementos comuns entre dois ou mais conjuntos
    - Diferença: Elementos que estão em um conjunto, mas não em outro
- SGBD Sistema Gerenciador de Banco de Dados: Software que permite a criação, manipulação e administração de bancos de dados
    - Um SGBD também possui seu banco de dados para armazenar suas informações
- Tipos de SGBD:
    - SGBD Relacional: Armazena dados em tabelas relacionadas entre si (ex: MySQL, PostgreSQL)
    - SGBD Não Relacional: Armazena dados de forma não estruturada, geralmente em documentos (ex: MongoDB, CouchDB)
- Linguagens de Banco de Dados:
    - DDL (Data Definition Language): Linguagem de definição de dados, usada para criar e modificar a estrutura do banco de dados
        - CREATE: Comando usado para criar objetos no banco de dados
            ```
            CREATE TABLE tabela (
                coluna1 tipo1,
                coluna2 tipo2,
                ...
            )
            ```
        - ALTER: Comando usado para modificar a estrutura de objetos existentes
            ```
            ALTER TABLE tabela 
            ADD coluna3 tipo3

            ALTER TABLE tabela 
            DROP COLUMN coluna2

            ALTER TABLE tabela 
            MODIFY COLUMN coluna1 tipo_novo

            ALTER TABLE tabela 
            RENAME COLUMN coluna1 TO coluna1_novo

            ALTER TABLE tabela 
            RENAME TO tabela_nova
            ```
        - DROP: Comando usado para excluir objetos do banco de dados
            ```
            DROP TABLE tabela
            ```
    - DML (Data Manipulation Language): Linguagem de manipulação de dados, usada para inserir, atualizar e excluir dados
        - INSERT: Comando usado para inserir novos registros em uma tabela
            ```
            INSERT INTO tabela (coluna1, coluna2) 
            VALUES (valor1, valor2)
            ```
        - UPDATE: Comando usado para atualizar registros existentes em uma tabela
            ```
            UPDATE tabela 
            SET coluna1 = valor1, coluna2 = valor2 
            WHERE condição
            ```
        - DELETE: Comando usado para excluir registros de uma tabela
            ```
            DELETE FROM tabela 
            WHERE condição
            ```
    - TCL (Transaction Control Language): Linguagem de controle de transações, usada para gerenciar transações no banco de dados
        - COMMIT: Comando usado para confirmar uma transação
        - ROLLBACK: Comando usado para desfazer uma transação
    - DCL (Data Control Language): Linguagem de controle de dados, usada para gerenciar permissões e acessos no banco de dados
        - GRANT: Comando usado para conceder permissões a usuários
            ```
            GRANT tipo_permissao ON objeto TO usuario
            ```
        - REVOKE: Comando usado para revogar permissões de usuários
            ```
            REVOKE tipo_permissao ON objeto FROM usuario
            ```
- Processamento de Dados:
    - OLTP (Online Transaction Processing): Processamento de transações em tempo real, focado na eficiência e na integridade das transações
        - Exemplo: Sistemas de vendas, onde cada venda é uma transação
            ```
            BEGIN TRANSACTION
            INSERT INTO vendas (id_cliente, id_produto, quantidade) VALUES (1, 2, 3)
            COMMIT
            ```
    - OLAP (Online Analytical Processing): Processamento analítico em tempo real, focado na análise de grandes volumes de dados para suporte à decisão
        - Exemplo: Sistemas de BI (Business Intelligence), onde são realizadas análises de dados históricos
            ```
            SELECT cliente, SUM(vendas) AS total_vendas
            FROM tabela_vendas
            WHERE data_venda BETWEEN '2023-01-01' AND '2023-12-31'
            GROUP BY cliente
            ```
- Tipos de Dados:
    - Dados Estruturados: Dados organizados em um formato fixo, como tabelas (ex: SQL)
        - Exemplo: Tabelas de clientes, produtos e vendas em um sistema de e-commerce
    - Dados Não Estruturados: Dados sem um formato predefinido, como textos e imagens (ex: JSON, XML)
        - Exemplo: Documentos de texto, imagens e vídeos armazenados em um sistema de gerenciamento de conteúdo
- Operadores Lógicos:
    - AND: Retorna verdadeiro se ambas as condições forem verdadeiras
        ```
        SELECT * FROM tabela WHERE coluna1 = valor1 AND coluna2 = valor2
        ```
    - OR: Retorna verdadeiro se pelo menos uma das condições for verdadeira
        ```
        SELECT * FROM tabela WHERE coluna1 = valor1 OR coluna2 = valor2
        ```
    - NOT: Inverte o valor lógico da condição
        ```
        SELECT * FROM tabela WHERE NOT coluna1 = valor1
        ```
- Operadores de Comparação:
    - ```=``` Igualdade
    - ```!=``` Desigualdade
    - ```<``` Menor que
    - ```>``` Maior que
    - ```<=``` Menor ou igual a
    - ```>=``` Maior ou igual a

---

## TUNING
  - Ajuste de desempenho de consultas SQL
  - Uso de índices para acelerar buscas
  - Análise de planos de execução
  - Filtrar resultados desnecessários, evitando a utilização do SELECT *
  - Utilizar os operadores lógicos de forma eficiente, evitando condições redundantes

---

## NORMALIZAÇÃO
  - Processo de organização dos dados em um banco de dados para reduzir redundâncias e dependências
  - Formas Normais:
      - 1ª Forma Normal (1NF): Elimina grupos repetitivos e garante que cada coluna contenha apenas valores atômicos. Todo campo vetorizado deve ser transformado em uma tabela separada
      - 2ª Forma Normal (2NF): Elimina dependências parciais, garantindo que cada coluna não-chave dependa da chave primária
      - 3ª Forma Normal (3NF): Elimina dependências transitivas, garantindo que colunas não-chave não dependam de outras colunas não-chave
      - Exemplo: Considerando uma tabela de vendas com as colunas id, id_cliente, nome_cliente, id_produto, nome_produto e quantidade, podemos normalizá-la da seguinte forma:
          - 1NF: Criar tabelas separadas para clientes, produtos e vendas, eliminando grupos repetitivos
          - 2NF: Garantir que as colunas nome_cliente e nome_produto dependam apenas das chaves primárias das tabelas correspondentes
          - 3NF: Eliminar colunas que dependem de outras colunas não-chave, garantindo que cada coluna tenha uma única responsabilidade

---

## DESNORMALIZAÇÃO
  - Processo de introdução de redundâncias em um banco de dados para melhorar o desempenho de consultas
  - Pode envolver a combinação de tabelas ou a adição de colunas redundantes
  - Deve ser usada com cautela, pois pode aumentar a complexidade e o risco de inconsistências
  - Exemplo: Adicionar uma coluna "nome_categoria" na tabela de produtos para evitar joins frequentes

---

## FUNÇÕES DE AGREGAÇÃO
  - Funções que realizam cálculos em um conjunto de valores e retornam um único valor. Pode-se utilizar em conjunto com GROUP BY para agrupar resultados com base em uma ou mais colunas
  - Exemplos:
      - COUNT: Conta o número de registros em um conjunto
      - SUM: Calcula a soma de valores em um conjunto
      - AVG: Calcula a média de valores em um conjunto
      - MIN: Retorna o menor valor em um conjunto
      - MAX: Retorna o maior valor em um conjunto
      - COUNT DISTINCT: Conta o número de valores distintos em um conjunto
  
# Q&A
  - Por que escolher string ao invés de numérico para telefone ou CPF: Para preservar zeros à esquerda e evitar cálculos matemáticos desnecessários.
  - Por que não usar float para valores monetários: Pode causar imprecisões devido à representação binária dos números de ponto flutuante. Usar decimal ou integer é mais seguro.
  - Por que usar enum para status: Para garantir que o valor do status seja sempre um dos valores pré-definidos, evitando erros de digitação e valores inválidos.
  - Por que usar chave primária: Para garantir a unicidade de registros em uma tabela e facilitar a criação de relacionamentos entre tabelas.
  - Por que usar chave estrangeira: Para garantir a integridade referencial entre tabelas e permitir a criação de relacionamentos entre dados.
  - Por que usar índices: Para melhorar o desempenho de consultas, permitindo buscas mais rápidas em grandes volumes de dados.
  - Por que usar views: Para simplificar consultas complexas, encapsulando lógica de negócios e melhorando a segurança ao restringir o acesso a dados sensíveis.
  - Por que usar stored procedures: Para encapsular lógica de negócios no banco de dados, promovendo reutilização de código e melhorando a segurança ao evitar SQL injection.
  - Por que usar triggers: Para automatizar ações no banco de dados em resposta a eventos, garantindo consistência e integridade dos dados.
  - Qual a diferença entre DELETE e TRUNCATE: DELETE remove registros individualmente e pode ser filtrado com WHERE, enquanto TRUNCATE remove todos os registros de uma tabela de forma rápida e não pode ser filtrado.
  - Qual a diferença entre WHERE e HAVING: WHERE filtra registros antes da agregação, enquanto HAVING filtra resultados após a agregação (como em GROUP BY)

# PRÁTICA
- Criar banco de dados
- Criar tabela com diferentes tipos de dados
- Modificar tabela
- Excluir tabela
- Criar tabelas com relacionamentos 1:1 1:N N:1 N:N
- Join
- Subquery
- Stored Procedure
- Trigger
- View
-- CRIAÇÃO DO BANCO COMPANY
CREATE schema company;

USE company;

-- CRIAÇÃO DA TABELA 'EMPLOYEE'
CREATE TABLE employee (
  fname VARCHAR(50),
  minit CHAR(1),
  lname VARCHAR(50),
  ssn CHAR(9) PRIMARY KEY,
  bdate DATE,
  address VARCHAR(100),
  sex CHAR(1),
  salary DECIMAL(10,2),
  superssn CHAR(9),
  dno INT,
  FOREIGN KEY (superssn) REFERENCES employee(ssn),
  FOREIGN KEY (dno) REFERENCES department(dnumber)
);

-- CRIAÇÃO DA TABELA 'DEPENDENT'
CREATE TABLE dependent (
  essn CHAR(9),
  dependent_name VARCHAR(50),
  sex CHAR(1),
  bdate DATE,
  relationship VARCHAR(50),
  FOREIGN KEY (essn) REFERENCES employee(ssn)
);

-- CRIAÇÃO DA TABELA 'DEPT_LOCATIONS'
CREATE TABLE dept_locations (
  dnumber INT,
  dlocation VARCHAR(100),
  PRIMARY KEY (dnumber, dlocation),
  FOREIGN KEY (dnumber) REFERENCES department(dnumber)
);

-- CRIAÇÃO DA TABELA 'DEPARTMENT'
CREATE TABLE department (
  dnumber INT PRIMARY KEY,
  dname VARCHAR(50),
  mgrssn CHAR(9),
  mgrstartdate DATE,
  FOREIGN KEY (mgrssn) REFERENCES employee(ssn)
);

-- CRIAÇÃO DA TABELA 'PROJECT'
CREATE TABLE project (
  pname VARCHAR(50),
  pnumber INT PRIMARY KEY,
  plocation VARCHAR(100),
  dnum INT,
  FOREIGN KEY (dnum) REFERENCES department(dnumber)
);

-- CRIAÇÃO DA TABELA 'WORKS_ON'
CREATE TABLE works_on (
  essn CHAR(9),
  pno INT,
  hours DECIMAL(5,2),
  FOREIGN KEY (essn) REFERENCES employee(ssn),
  FOREIGN KEY (pno) REFERENCES project(pnumber)
);

##############################################
## Parte 1 - Criação de índices e consultas ##
##############################################

-----------------------------------------------------
-- 1 QUAL O DEPARTAMENTO COM MAIOR NÚMERO DE PESSOAS.
-----------------------------------------------------
Podemos criar um índice na tabela "department" na coluna "dnumber" e um índice na tabela "employee" na coluna "dno".

ALTER TABLE department ADD INDEX idx_dnumber (dnumber);
ALTER TABLE employee ADD INDEX idx_dno (dno);

Consulta:
SELECT dname
FROM department
WHERE dnumber = (
    SELECT dno
    FROM employee
    GROUP BY dno
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

Índice criado: idx_dnumber na coluna dnumber da tabela department.
Motivo: Ao criar esse índice, podemos otimizar a consulta para encontrar o departamento com o maior número de pessoas. A consulta envolve agrupar os funcionários por departamento, contar o número de funcionários em cada departamento e, em seguida, selecionar o departamento com o maior número. O índice na coluna dnumber ajuda a acelerar a busca pelo departamento com base no número de funcionários.

-------------------------------------------
-- 2 QUAIS SÃO OS DEPARTAMENTOS POR CIDADE.
-------------------------------------------
Podemos criar um índice na tabela "dept_locations" na coluna "dlocation" para facilitar a consulta.

ALTER TABLE dept_locations ADD INDEX idx_dlocation (dlocation);

Consulta:
SELECT dname, dlocation
FROM department
JOIN dept_locations ON department.dnumber = dept_locations.dnumber;

Índice criado: idx_dlocation na coluna dlocation da tabela dept_locations.
Motivo: Esse índice facilita a consulta para encontrar os departamentos com base na cidade em que estão localizados. Ao criar o índice na coluna dlocation, a busca pelos departamentos de uma determinada cidade se torna mais eficiente.

--------------------------------------------
-- 3 RELAÇÃO DE EMPREGADOS POR DEPARTAMENTO.
--------------------------------------------
Nesse caso, já temos um índice na coluna "dno" da tabela "employee" que nos auxiliará na consulta.

Consulta:
SELECT dname, CONCAT(fname, ' ', lname) AS full_name
FROM department
JOIN employee ON department.dnumber = employee.dno;

Índice existente: idx_dno na coluna dno da tabela employee.
Motivo: Nesse caso, o índice já existente na coluna dno da tabela employee é utilizado para melhorar o desempenho da consulta, que relaciona os funcionários aos seus respectivos departamentos. O índice permite uma busca rápida dos funcionários com base no número do departamento.

-----------------------------------
-- 4 QUAIS OS DADOS MAIS ACESSADOS.
-----------------------------------
Se a coluna "ssn" da tabela "employee" é frequentemente usada em consultas, podemos criar um índice para ela.

ALTER TABLE employee ADD INDEX idx_ssn (ssn);

Índice criado: idx_ssn na coluna ssn da tabela employee.
Motivo: O índice na coluna ssn é criado para otimizar as consultas que envolvem a pesquisa de funcionários com base no número de Segurança Social (Social Security Number). Esse índice facilita a localização rápida dos registros com um determinado número de Segurança Social.

------------------------------------------------
-- 5 QUAIS OS DADOS MAIS RELEVANTES NO CONTEXTO.
------------------------------------------------
Se a coluna "bdate" da tabela "employee" for relevante nas consultas, podemos criar um índice para ela.

ALTER TABLE employee ADD INDEX idx_bdate (bdate);

Índice criado: idx_bdate na coluna bdate da tabela employee.
Motivo: O índice na coluna bdate é criado para melhorar o desempenho das consultas que envolvem filtragem por data de nascimento dos funcionários. Com o índice, as consultas que utilizam a coluna bdate como critério de pesquisa são executadas de forma mais eficiente.

########################################
## Parte 2 - Utilização de procedures ##
########################################

DELIMITER //

CREATE PROCEDURE manipulate_data(
    IN action VARCHAR(10),
    IN table_name VARCHAR(20),
    IN id INT,
    IN column1 VARCHAR(50),
    IN column2 VARCHAR(50),
    IN column3 VARCHAR(50)
)
BEGIN
    DECLARE row_count INT;
    
    IF action = 'insert' THEN
        INSERT INTO table_name (column1, column2, column3) VALUES (column1, column2, column3);
        SET row_count = ROW_COUNT();
        SELECT CONCAT('Inserted ', row_count, ' row(s).');
    ELSEIF action = 'update' THEN
        UPDATE table_name SET column

1 = column1, column2 = column2, column3 = column3 WHERE id = id;
        SET row_count = ROW_COUNT();
        SELECT CONCAT('Updated ', row_count, ' row(s).');
    ELSEIF action = 'delete' THEN
        DELETE FROM table_name WHERE id = id;
        SET row_count = ROW_COUNT();
        SELECT CONCAT('Deleted ', row_count, ' row(s).');
    ELSE
        SELECT 'Invalid action.';
    END IF;
    
END //

DELIMITER;

-----------------------------------------------
-- CHAMADA DA PROCEDURE PARA MANIPULAR OS DADOS
-----------------------------------------------
CALL manipulate_data('insert', 'employee', NULL, 'John', 'Doe', 'Male');
CALL manipulate_data('update', 'employee', 1, 'Jane', 'Smith', 'Female');
CALL manipulate_data('delete', 'employee', 2, NULL, NULL, NULL);
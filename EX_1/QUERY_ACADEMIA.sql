CREATE DATABASE academia

USE academia

CREATE TABLE aluno (
codigo_aluno		INT				,
nome				VARCHAR(150)	,
PRIMARY KEY(codigo_aluno)

)

CREATE TABLE atividade (
codigo			INT			,
descrição		VARCHAR(200) ,
imc				DECIMAL(2,1),
PRIMARY KEY (codigo)
)

CREATE TABLE atividadesaluno(
codigo_aluno		INT		,
altura				DECIMAL(2,2),
peso				DECIMAL(3,2),
imc					DECIMAL(2,1),
atividade			INT		,
FOREIGN KEY (codigo_aluno) REFERENCES aluno(codigo_aluno),
FOREIGN KEY (atividade) REFERENCES atividade(codigo),
PRIMARY KEY (codigo_aluno, atividade)
)

/*Criar uma Stored Procedure (sp_alunoatividades), com as seguintes regras:
- Se, dos dados inseridos, o código for nulo, mas, existirem nome, altura, peso, deve-se inserir um
novo registro nas tabelas aluno e aluno atividade com o imc calculado e as atividades pelas
regras estabelecidas acima.
- Se, dos dados inseridos, o nome for (ou não nulo), mas, existirem código, altura, peso, deve-se
verificar se aquele código existe na base de dados e atualizar a altura, o peso, o imc calculado e
as atividades pelas regras estabelecidas acima.
- Fazer a Stored Procedure atomizada, ou seja, chamando outras Stored Procedures com
responsabilidades específicas.
*/

CREATE PROCEDURE sp_calculaatividade(@imc DECIMAL(2,1), @atividade INT OUTPUT)
AS


SET @atividade = (SELECT codigo FROM atividade
					WHERE imc > @imc)
IF (@atividade IS NULL)
BEGIN
	SET @atividade = 5
END



CREATE PROCEDURE sp_insertaluno(@nome VARCHAR(150))
AS

	DECLARE @id INT
	SET @id = (SELECT MAX(codigo_aluno) as id FROM aluno)
	IF @id IS NULL
	BEGIN
		SET @id = 1
	END
	ELSE
	BEGIN
		SET @id = @id + 1
	END
	INSERT INTO aluno(codigo_aluno, nome)
	VALUES (@id, @nome)


CREATE PROCEDURE sp_insertalunoatividade(@codigoaluno INT, @altura DECIMAL(2,2), @peso DECIMAL (3,2), @imc DECIMAL(2,2), @atividade INT)
AS
	
	DECLARE @valido3 BIT
	EXEC sp_buscaalunoatividade @codigoaluno, @valido3 OUTPUT
	IF (@valido3 = 1)
	BEGIN
		UPDATE atividadesaluno
		SET codigo_aluno = @codigoaluno, altura = @altura, peso = @peso, imc = @imc, atividade = @atividade
	END
	ELSE
	BEGIN
		INSERT INTO atividadesaluno(codigo_aluno, altura, peso,	imc, atividade)
		VALUES(@codigoaluno, @altura, @peso, @imc, @atividade)
	END

CREATE PROCEDURE sp_buscaalunoatividade(@codigoaluno INT, @valido1 BIT OUTPUT)
AS

SET @codigoaluno = (SELECT codigo_aluno FROM atividadesaluno WHERE codigo_aluno = @codigoaluno)
IF @codigoaluno IS NULL 
BEGIN
	SET @valido1 = 0
END ELSE
BEGIN
	SET @valido1 = 1
END





CREATE PROCEDURE sp_alunoatividades(@codigo INT, @altura DECIMAL(2,2), @peso DECIMAL (3,2), @nome VARCHAR(150), @valido BIT OUTPUT)
AS

DECLARE @imc DECIMAL(2,1), @atividade INT, @valido2 BIT

IF (@codigo IS NULL AND @altura IS NOT NULL AND @peso IS NOT NULL AND @nome IS NOT NULL)
BEGIN
	SET @imc = @peso / (@altura * @altura)
	EXEC sp_calculaatividade @imc, @atividade OUTPUT
	EXEC sp_insertaluno @nome
	EXEC sp_insertalunoatividade @codigo, @altura, @peso, @imc, @atividade 
	SET @valido = 1
END
ELSE IF (@codigo IS NOT NULL AND @altura IS NOT NULL AND @peso IS NOT NULL)
BEGIN
	SET @imc = @peso / (@altura * @altura)
	EXEC sp_calculaatividade @imc, @atividade OUTPUT
	EXEC sp_insertalunoatividade @codigo, @altura, @peso, @imc, @atividade 
END
CREATE DATABASE IF NOT EXISTS proyecto_GHM;
USE proyecto_GHM;

DROP TABLE IF EXISTS respuesta;
DROP TABLE IF EXISTS consulta;
DROP TABLE IF EXISTS anuncio;
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS cochera;
DROP TABLE IF EXISTS local;
DROP TABLE IF EXISTS departamento;
DROP TABLE IF EXISTS casa;
DROP TABLE IF EXISTS categoria;
DROP TABLE IF EXISTS inmueble;

CREATE TABLE usuario (
	usuario VARCHAR(30) NOT NULL PRIMARY KEY,
	password VARCHAR(41) NOT NULL,
	dni INT(8) NOT NULL UNIQUE,
	nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL
);

CREATE TABLE inmueble (
	id INT NOT NULL auto_increment PRIMARY KEY,
	direccion VARCHAR(50) NOT NULL,
	m2 SMALLINT NOT NULL
);

CREATE TABLE anuncio (
	codigo INT NOT NULL auto_increment PRIMARY KEY,
	inicio DATE NOT NULL,
	fin DATE NOT NULL,
	inmueble_id INT NOT NULL,
	usuario_usuario VARCHAR(30) NOT NULL,
	
	monto_alquiler MEDIUMINT,
	monto_venta INT,

	INDEX inmueble (inmueble_id),
	FOREIGN KEY (inmueble_id) REFERENCES inmueble(id) ON DELETE CASCADE,

	INDEX usuario (usuario_usuario),
	FOREIGN KEY (usuario_usuario) REFERENCES usuario(usuario) ON DELETE CASCADE
);

CREATE TABLE consulta (
	id INT NOT NULL auto_increment PRIMARY KEY,
	texto TINYTEXT NOT NULL,
	anuncio_codigo INT NOT NULL,

	INDEX anuncio (anuncio_codigo),
	FOREIGN KEY (anuncio_codigo) REFERENCES anuncio(codigo) ON DELETE CASCADE
);

CREATE TABLE respuesta (
	id INT NOT NULL auto_increment PRIMARY KEY,
	texto TINYTEXT NOT NULL,
	usuario_usuario VARCHAR(30) NOT NULL,
	consulta_id INT NOT NULL,

	INDEX usuario (usuario_usuario),
	FOREIGN KEY (usuario_usuario) REFERENCES usuario(usuario) ON DELETE CASCADE,

	INDEX consulta (consulta_id),
	FOREIGN KEY (consulta_id) REFERENCES consulta(id) ON DELETE CASCADE
);

CREATE TABLE cochera (
	inmueble_id INT NOT NULL,

	PRIMARY KEY inmueble (inmueble_id),
	FOREIGN KEY (inmueble_id) REFERENCES inmueble(id) ON DELETE CASCADE
);

CREATE TABLE local (
	inmueble_id INT NOT NULL,

	PRIMARY KEY inmueble (inmueble_id),
	FOREIGN KEY (inmueble_id) REFERENCES inmueble(id) ON DELETE CASCADE
);

CREATE TABLE departamento (
	inmueble_id INT NOT NULL,
	expensas DECIMAL(4,2) NOT NULL,

	PRIMARY KEY inmueble (inmueble_id),
	FOREIGN KEY (inmueble_id) REFERENCES inmueble(id) ON DELETE CASCADE,

	CONSTRAINT expensas_positivas CHECK (expensas>0)
);

CREATE TABLE categoria (
	id TINYINT NOT NULL auto_increment PRIMARY KEY,
	nombre VARCHAR(30) NOT NULL
);

CREATE TABLE casa (
	inmueble_id INT NOT NULL,
	categoria_id TINYINT NOT NULL,
	cantidad_habitaciones TINYINT NOT NULL,

	PRIMARY KEY inmueble (inmueble_id),
	FOREIGN KEY (inmueble_id) REFERENCES inmueble(id) ON DELETE CASCADE,

	INDEX categoria (categoria_id),
	FOREIGN KEY (categoria_id) REFERENCES categoria(id) ON DELETE CASCADE
);


START TRANSACTION;

INSERT INTO categoria (id, nombre)
VALUES (1, 'duplex'), (2, 'monoambiente');

INSERT INTO usuario (usuario, password, dni, nombre, apellido)
VALUES 
    ('nicoalfa', PASSWORD('nico88'), 30987162, 'nicolas', 'gomez'), 
    ('ignaciobeta', PASSWORD('nacho22'), 27093648, 'ignacio', 'herrero'), 
    ('guillegama', PASSWORD('guille18'), 31882009, 'guillermo', 'morilla'); 

INSERT INTO inmueble (id, direccion, m2)
VALUES 
    (1, 'laguna blanca 800', 60), 
    (2, 'segurola 1200', 90), 
    (3, 'constitucion 500', 43), 
    (4, 'sebastian vera 678', 34), 
    (5, 'baigorria 34', 67), 
    (6, 'dean funes 134', 90), 
    (7, 'cabrera 198', 120);    

INSERT INTO cochera (inmueble_id)
VALUES (1), (3);

INSERT INTO local (inmueble_id)
VALUES (2);

INSERT INTO departamento (inmueble_id, expensas)
VALUES (4, 570.20), (5, 1200);


INSERT INTO casa (inmueble_id, cantidad_habitaciones, categoria_id)
VALUES (6, 1, 1), (7, 2, 2);

INSERT INTO anuncio (codigo, inicio, fin, inmueble_id, usuario_usuario, monto_alquiler)
VALUES 
    (123, '2000-03-12', '2001-01-23', 1, 'nicoalfa', 1723);

INSERT INTO anuncio (codigo, inicio, fin, inmueble_id, usuario_usuario, monto_venta)
VALUES 
    (124, '2010-01-15', '2012-03-10', 2, 'ignaciobeta',10570000);

INSERT INTO anuncio (codigo, inicio, fin, inmueble_id, usuario_usuario, monto_venta, monto_alquiler)
VALUES 
    (125, '2010-01-15', '2012-03-10', 2, 'ignaciobeta',400000,1200);
    
INSERT INTO consulta (id, texto, anuncio_codigo)
VALUES 
    (1000, 'hola...', 123), 
    (1001, 'Buen dia..', 123),
	(1002, 'Guten Morgen', 124);

INSERT INTO respuesta (id, texto, usuario_usuario, consulta_id)
VALUES 
    (500, 'si, asi es..', 'nicoalfa', 1000), 
    (501, 'esta alquilada.', 'ignaciobeta', 1000);    
	
COMMIT;


DROP FUNCTION IF EXISTS overlapping;
DROP TRIGGER IF EXISTS deny_overlapping;

DELIMITER $$
CREATE FUNCTION overlapping (n_inicio DATE, n_fin DATE, inmueble INT) RETURNS BOOL DETERMINISTIC
BEGIN
	DECLARE overlap BOOL;
	SELECT COUNT(codigo)>0 INTO overlap FROM anuncio WHERE n_inicio < fin AND n_fin > inicio AND inmueble_id = inmueble;
	RETURN overlap;
END$$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER deny_overlapping BEFORE INSERT ON anuncio
FOR EACH ROW BEGIN
    DECLARE msg VARCHAR(100);
    IF (overlapping(NEW.inicio, NEW.fin, NEW.inmueble_id)) THEN
        set msg = "HORROR: ¿no entendes? no se puede publicar dos anuncio para un inmueble en la misma fecha.";
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;
END$$
DELIMITER ;

-- Test Trigger Overlapping (superposicion)
-- Los tests con fechas superpuestas lanzan un error y evitan que se almacene el valor.
-- estos test estan comentados para evitar que se ejecuten al procesar el script.

-- Superposicion total
--	INSERT INTO anuncio (inicio, fin, inmueble_id, usuario_usuario)
--	VALUES ('2000-04-01', '2000-05-01', 1, 'nicoalfa');

-- Superpocicion al Comienzo
--	INSERT INTO anuncio (inicio, fin, inmueble_id, usuario_usuario)
--	VALUES ('2001-01-01', '2001-02-01', 1, 'nicoalfa');

-- Superpocicion al Final
--	INSERT INTO anuncio (inicio, fin, inmueble_id, usuario_usuario)
--	VALUES ('2000-01-01', '2000-04-01', 1, 'nicoalfa');

-- Test con valores correctos.
START TRANSACTION;
	-- OK Anterior
	INSERT INTO anuncio (inicio, fin, inmueble_id, usuario_usuario)
	VALUES ('2000-01-01', '2000-02-01', 1, 'nicoalfa');

	-- OK Posterior
	INSERT INTO anuncio (inicio, fin, inmueble_id, usuario_usuario)
	VALUES ('2013-01-01', '2013-03-01', 1, 'nicoalfa');
ROLLBACK;



DROP TRIGGER IF EXISTS deny_answer_overflow;
DROP FUNCTION IF EXISTS answer_overflow;

DELIMITER $$
CREATE FUNCTION answer_overflow (consulta INT) RETURNS BOOL DETERMINISTIC
BEGIN
	DECLARE overflow BOOL;
	SELECT COUNT(id)>=10 INTO overflow FROM respuesta WHERE consulta_id = consulta;
	RETURN overflow;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER deny_answer_overflow BEFORE INSERT ON respuesta
FOR EACH ROW BEGIN
    DECLARE msg VARCHAR(100);
    IF (answer_overflow(NEW.consulta_id)) THEN
        set msg = "NI LO PIENSES!: No vale la pena seguir contestanto esta pregunta.";
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;
END$$
DELIMITER ;

-- Test con valores correctos.
START TRANSACTION;

-- Inserción OK --
	INSERT INTO respuesta (texto, usuario_usuario, consulta_id)
	VALUES 
		('esta alquilada.', 'ignaciobeta', 1001),    
		('esta alquilada.', 'ignaciobeta', 1001),    
		('esta alquilada.', 'ignaciobeta', 1001),    
		('esta alquilada.', 'ignaciobeta', 1001),    
		('esta alquilada.', 'ignaciobeta', 1001),    
		('esta alquilada.', 'ignaciobeta', 1001),    
		('esta alquilada.', 'ignaciobeta', 1001),    
		('esta alquilada.', 'ignaciobeta', 1001),    
		('esta alquilada.', 'ignaciobeta', 1001),    
		('esta alquilada.', 'ignaciobeta', 1001);    
		
-- Inserción ERR --
-- El siguiente test lanza el error, por lo que esta comentado 
-- para evitar que se ejecuten al procesar el script.

--	INSERT INTO respuesta (texto, usuario_usuario, consulta_id)
--	VALUES 
--		('esta alquilada.', 'ignaciobeta', 1001);
ROLLBACK;



-- Forma alternativa de eliminar anuncios. Para utilizar esta forma, 
-- en vez de hacer una eliminción, se hace una insercion.
-- Al insertar un usuario y un anuncion en "eliminar_anuncio" se dispara
-- un trigger que toma los datos del anuncio, lo elimina y almacena toda
-- la información en la tabla que funcionará como auditoria (eliminar_anuncio)

DROP TABLE IF EXISTS eliminar_anuncio;
DROP TRIGGER IF EXISTS eliminar_anuncio;

CREATE TABLE eliminar_anuncio (
	usuario VARCHAR(77) NOT NULL,
	anuncio_codigo INT NOT NULL,

	id INT auto_increment PRIMARY KEY,
	fecha_baja TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	
	anuncio_inicio DATE NOT NULL,
	anuncio_fin DATE NOT NULL,
	anuncio_inmueble_id INT NOT NULL,
	anuncio_usuario_usuario VARCHAR(30) NOT NULL
);

DELIMITER $$
CREATE TRIGGER eliminar_anuncio BEFORE INSERT ON eliminar_anuncio
FOR EACH ROW BEGIN
	DECLARE existe BOOL;
	DECLARE t_inicio, t_fin DATE;
	DECLARE t_inmueble_id INT;
	DECLARE t_usuario_usuario VARCHAR(30);
	DECLARE msg VARCHAR(120);
	
	(SELECT COUNT(codigo) <=> 1 INTO existe FROM anuncio WHERE (codigo = NEW.anuncio_codigo));
	
	IF (not existe) THEN
        set msg = "HORROR: que fue primero ¿el huevo o la gallina?... Estas tratando de eliminar un anuncio que no existe!";
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
	ELSE
		(SELECT inicio INTO t_inicio FROM anuncio WHERE (codigo = NEW.anuncio_codigo));
		(SELECT fin INTO t_fin FROM anuncio WHERE (codigo = NEW.anuncio_codigo));
		(SELECT inmueble_id INTO t_inmueble_id FROM anuncio WHERE (codigo = NEW.anuncio_codigo));
		(SELECT usuario_usuario INTO t_usuario_usuario FROM anuncio WHERE (codigo = NEW.anuncio_codigo));
		
		set NEW.anuncio_inicio = t_inicio;
		set NEW.anuncio_fin = t_fin;
		set NEW.anuncio_inmueble_id = t_inmueble_id;
		set NEW.anuncio_usuario_usuario = t_usuario_usuario;
		
		DELETE FROM anuncio WHERE (codigo = NEW.anuncio_codigo);
    END IF;
END$$
DELIMITER ;


-- TESTS DE ELIMINACION POR INSERCIÓN
-- Test eliminacion OK
START TRANSACTION;
	insert into eliminar_anuncio (usuario,anuncio_codigo) values ('ignaciobeta',123);
ROLLBACK;

-- Test ERRRO al eliminar
-- El test se encuentra comentado porque al ejecutarlo el gestor dispara un error.
-- insert into eliminar_anuncio (usuario,anuncio_codigo) values ('ignaciobeta',12345)



DROP TABLE IF EXISTS baja_anuncio;
-- La tabla baja anuncion guarda la informacion del anuncio, el usuario y fecha que fue eliminado.
-- Por ser una tabla de auditoria, consideramos que no necesita claves foraneas.
CREATE TABLE baja_anuncio (
	id INT auto_increment PRIMARY KEY,
	usuario VARCHAR(77) NOT NULL,
	fecha_baja TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	
	anuncio_codigo INT NOT NULL,
	anuncio_inicio DATE NOT NULL,
	anuncio_fin DATE NOT NULL,
	anuncio_inmueble_id INT NOT NULL,
	anuncio_usuario_usuario VARCHAR(30) NOT NULL
);

DELIMITER $$
CREATE TRIGGER baja_anuncio BEFORE DELETE ON anuncio
FOR EACH ROW BEGIN

	INSERT INTO baja_anuncio (usuario, anuncio_codigo, anuncio_inicio, anuncio_fin, anuncio_inmueble_id, anuncio_usuario_usuario)
	VALUES (CURRENT_USER(), OLD.codigo, OLD.inicio, OLD.fin, OLD.inmueble_id, OLD.usuario_usuario);
	
END$$
DELIMITER ;



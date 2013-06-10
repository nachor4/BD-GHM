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

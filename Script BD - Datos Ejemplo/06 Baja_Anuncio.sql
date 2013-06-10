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



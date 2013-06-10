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
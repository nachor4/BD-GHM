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
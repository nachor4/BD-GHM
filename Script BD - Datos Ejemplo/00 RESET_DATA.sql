START TRANSACTION;

USE proyecto_GHM;

-- Al eliminar un inmueble, se eliminan sus especializaciones y los anuncios 
-- relacionados. Con estos, se eliminan las consultas y respuestas
DELETE FROM inmueble;

-- Debe eliminarse despues de los inmuebles
DELETE FROM categoria;
DELETE FROM usuario;

-- Estas tablas no tienen relaciones, pero los triggers le insertan elementos, 
-- por lo que se las debe eliminar último
TRUNCATE eliminar_anuncio;
TRUNCATE baja_anuncio;


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
    (125, '2013-01-15', '2013-03-10', 2, 'ignaciobeta',400000,1200);
    
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
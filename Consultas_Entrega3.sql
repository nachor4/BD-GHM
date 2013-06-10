-- Consulta A
	SELECT inmueble.*, an.cantidad_anuncios FROM inmueble 
	JOIN (SELECT inmueble_id, COUNT(codigo) AS cantidad_anuncios FROM anuncio GROUP BY (inmueble_id)) AS an
	ON inmueble.id = an.inmueble_id;


-- Consulta B
	SELECT anuncio.* FROM ANUNCIO 
	JOIN (SELECT MAX(DATEDIFF(fin,inicio)) AS cantidad FROM `anuncio`) AS max 
	ON DATEDIFF(anuncio.fin,anuncio.inicio) = max.cantidad;
	
-- Consulta C1
	-- Muestra TODAS las consultas, sus respuestas y los usuarios que la respondieron
	SELECT 
		consulta.anuncio_codigo AS anuncio,
		consulta.texto AS consulta,
		respuesta.usuario_usuario AS usuario_respuesta,
		respuesta.texto AS respuesta
	FROM consulta JOIN respuesta ON consulta.id = respuesta.consulta_id;
	
	-- Consultas SIN respuesta
	SELECT texto AS consulta, anuncio_codigo AS anuncio  FROM consulta 
	WHERE id IN (SELECT consulta_id FROM respuesta);
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
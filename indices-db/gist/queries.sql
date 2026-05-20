-- Script de ejemplo para demostrar el uso de índices GiST en PostgreSQL (con datos geoespaciales simples)

-- Eliminar la tabla si ya existe (para comenzar limpio)
DROP TABLE IF EXISTS lugares;

-- Crear la tabla de lugares
CREATE TABLE lugares (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    ubicacion POINT NOT NULL,  -- Tipo de dato punto de PostgreSQL
    descripcion TEXT
);

-- Insertar algunos datos de ejemplo (coordenadas aproximadas de Nueva York en longitud, latitud)
-- Nota: En un sistema real, usaríamos SRID y talvez la extensión PostGIS, pero para este ejemplo usamos POINT simple.
INSERT INTO lugares (nombre, ubicacion, descripcion) VALUES
('Empire State Building', point(-73.9857, 40.7484), 'Iconic skyscraper'),
('Central Park', point(-73.9654, 40.7829), 'Large urban park'),
('Statue of Liberty', point(-74.0445, 40.6892), 'Monument on Liberty Island'),
('Times Square', point(-73.9855, 40.7580), 'Major commercial intersection'),
('Brooklyn Bridge', point(-73.9969, 40.7061), 'Iconic suspension bridge'),
('One World Trade Center', point(-74.0110, 40.7096), 'Main building of the rebuilt WTC complex');

-- Crear índice GiST en la columna ubicacion
CREATE INDEX idx_lugares_ubicacion ON lugares USING gist (ubicacion);

-- Consultas de ejemplo para demostrar el uso del índice GiST

-- 1. Encontrar lugares dentro de un radio de aproximadamente 0.01 grados (unos 1 km) de un punto dado
EXPLAIN ANALYZE
SELECT nombre, ubicacion
FROM lugares
WHERE ubicacion <-> point(-73.9857, 40.7484) < 0.01  -- Cercano al Empire State Building
ORDER BY ubicacion <-> point(-73.9857, 40.7484);

-- 2. Encontrar lugares dentro de un cuadro delimitador (bounding box)
EXPLAIN ANALYZE
SELECT nombre, ubicacion
FROM lugares
WHERE ubicacion && box(point(-74.0, 40.7), point(-73.9, 40.8));  -- Cuadro que cubre gran parte de NYC

-- 3. Encontrar el lugar más cercano a un punto dado (ordenando por distancia)
EXPLAIN ANALYZE
SELECT nombre, ubicacion
FROM lugares
ORDER BY ubicacion <-> point(-73.9654, 40.7829)  -- Cercano a Central Park
LIMIT 1;

-- 4. Consulta que no usa el índice (por ejemplo, filtrando por nombre)
EXPLAIN ANALYZE
SELECT * FROM lugares WHERE nombre = 'Statue of Liberty';

-- 5. Usando el operador de distancia sin índice (para comparar, pero eliminemos el índice temporalmente para ver la diferencia)
-- Nota: No eliminamos el índice en este script, pero podemos comparar el plan con y sin índice si lo deseamos.

-- Eliminar la tabla al final (opcional, para limpiar)
-- DROP TABLE lugares;
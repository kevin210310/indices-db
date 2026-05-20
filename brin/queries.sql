-- Script de ejemplo para demostrar el uso de índices BRIN en PostgreSQL (con datos de serie temporal)

-- Eliminar la tabla si ya existe (para comenzar limpio)
DROP TABLE IF EXISTS mediciones;

-- Crear la tabla de mediciones
CREATE TABLE mediciones (
    id SERIAL PRIMARY KEY,
    sensor_id INTEGER NOT NULL,
    valor DECIMAL(10, 4) NOT NULL,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de ejemplo: 1 millón de filas, simulando mediciones de un sensor cada 30 segundos durante aproximadamente un año
-- Vamos a usar generate_series para generar timestamps y valores aleatorios
INSERT INTO mediciones (sensor_id, valor, fecha_registro)
SELECT
    (random() * 10)::int + 1,  -- sensor_id entre 1 y 10
    round(random() * 100, 4),  -- valor entre 0 y 100 con 4 decimales
    timestamp '2023-01-01 00:00:00' + (random() * (timestamp '2024-01-01 00:00:00' - timestamp '2023-01-01 00:00:00'))
FROM generate_series(1, 1000000);

-- Crear índice BRIN en la columna fecha_registro
CREATE INDEX idx_mediciones_fecha ON mediciones USING brin (fecha_registro);
-- También podemos crear un índice B-tree en la misma columna para comparar tamaño y rendimiento
-- CREATE INDEX idx_mediciones_fecha_btree ON mediciones (fecha_registro);

-- Consultas de ejemplo para demostrar el uso del índice BRIN

-- 1. Obtener las mediciones de la última semana (asumiendo que los datos están en 2023-2024, ajustamos a una fecha conocida)
-- Vamos a usar una fecha fija para que el resultado sea determinista en el ejemplo
EXPLAIN ANALYZE
SELECT COUNT(*) FROM mediciones
WHERE fecha_registro >= timestamp '2023-06-01'
  AND fecha_registro < timestamp '2023-06-08';

-- 2. Obtener las mediciones de un día específico
EXPLAIN ANALYZE
SELECT COUNT(*) FROM mediciones
WHERE fecha_registro >= timestamp '2023-06-15'
  AND fecha_registro < timestamp '2023-06-16';

-- 3. Obtener el valor promedio de un sensor en un mes
EXPLAIN ANALYZE
SELECT AVG(valor) FROM mediciones
WHERE sensor_id = 5
  AND fecha_registro >= timestamp '2023-07-01'
  AND fecha_registro < timestamp '2023-08-01';

-- 4. Obtener las mediciones fuera de un rango (para ver si también usa el índice)
EXPLAIN ANALYZE
SELECT COUNT(*) FROM mediciones
WHERE fecha_registro < timestamp '2023-01-01';

-- 5. Comparar el tamaño de los índices (opcional, requiere acceder a pg_total_relation_size o similar)
-- NOTA: Estas consultas pueden requerir permisos de superusuario o acceso a la catalogación.
-- Pero podemos incluirla como comentario para que el usuario la ejecute por separado si desea.
-- SELECT
--     pg_size_pretty(pg_total_relation_size('idx_mediciones_fecha')) AS brin_size,
--     pg_size_pretty(pg_total_relation_size('idx_mediciones_fecha_btree')) AS btree_size;

-- Eliminar la tabla al final (opcional, para limpiar)
-- DROP TABLE mediciones;
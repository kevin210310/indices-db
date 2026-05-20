-- Script de ejemplo para demostrar el uso de índices Bloom en PostgreSQL

-- Crear la extensión bloom si no existe
-- NOTA: Esto requiere permisos de superusuario o que la extensión esté disponible en la instalación.
CREATE EXTENSION IF NOT EXISTS bloom;

-- Eliminar la tabla si ya existe (para comenzar limpio)
DROP TABLE IF EXISTS ventas;

-- Crear la tabla de ventas
CREATE TABLE ventas (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL,
    producto_id INTEGER NOT NULL,
    pais_id INTEGER NOT NULL,
    monto DECIMAL(10, 2) NOT NULL,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Insertar algunos datos de ejemplo
INSERT INTO ventas (usuario_id, producto_id, pais_id, monto) VALUES
(1, 101, 10, 29.99),
(1, 102, 10, 15.50),
(2, 101, 20, 29.99),
(2, 105, 15, 99.99),
(3, 101, 10, 29.99),
(3, 103, 30, 45.00),
(4, 104, 10, 75.25),
(5, 105, 20, 99.99),
(1, 101, 10, 29.99),  -- Duplicado intencional para probar
(6, 106, 30, 120.00);

-- Crear índice Bloom en las columnas usuario_id, producto_id y pais_id
CREATE INDEX idx_ventas_bloom ON ventas USING bloom (usuario_id, producto_id, pais_id);

-- Consultas de ejemplo para demostrar el uso del índice Bloom

-- 1. Consulta de igualdad en tres columnas (usa idx_ventas_bloom)
EXPLAIN ANALYZE
SELECT * FROM ventas WHERE usuario_id = 1 AND producto_id = 101 AND pais_id = 10;

-- 2. Consulta de igualdad en dos columnas (el índice Bloom aún puede usarse para verificar la presencia)
EXPLAIN ANALYZE
SELECT * FROM ventas WHERE usuario_id = 2 AND producto_id = 105;

-- 3. Consulta de igualdad en una columna (el índice Bloom puede usarse, pero podría ser menos eficiente que un índice B-tree simple)
EXPLAIN ANALYZE
SELECT * FROM ventas WHERE usuario_id = 3;

-- 4. Consulta que no coincide (para ver el comportamiento de falsos positivos, aunque en este pequeño conjunto es poco probable)
EXPLAIN ANALYZE
SELECT * FROM ventas WHERE usuario_id = 999 AND producto_id = 999 AND pais_id = 999;

-- 5. Consulta con rango (NO usará el índice Bloom, probablemente Seq Scan)
EXPLAIN ANALYZE
SELECT * FROM ventas WHERE monto > 50;

-- 6. Consulta de ordenamiento (NO usará el índice Bloom)
EXPLAIN ANALYZE
SELECT * FROM ventas ORDER BY fecha LIMIT 5;

-- 7. Verificar el tamaño del índice Bloom (opcional)
-- SELECT pg_size_pretty(pg_total_relation_size('idx_ventas_bloom')) AS bloom_index_size;

-- Eliminar la tabla al final (opcional, para limpiar)
-- DROP TABLE ventas;
-- -- Desinstalar la extensión (opcional, pero generalmente se deja instalada)
-- DROP EXTENSION IF EXISTS bloom;
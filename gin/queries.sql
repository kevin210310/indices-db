-- Script de ejemplo para demostrar el uso de índices GIN en PostgreSQL (con arrays de etiquetas)

-- Eliminar la tabla si ya existe (para comenzar limpio)
DROP TABLE IF EXISTS articulos;

-- Crear la tabla de articulos
CREATE TABLE articulos (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    contenido TEXT,
    etiquetas TEXT[],  -- Array de etiquetas
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar algunos datos de ejemplo
INSERT INTO articulos (titulo, contenido, etiquetas) VALUES
('Introducción a PostgreSQL', 'Aprende las bases de este poderoso sistema de gestión de bases de datos.', ARRAY['postgresql', 'base de datos', 'sql']),
('Optimización de consultas', 'Mejora el rendimiento de tus consultas SQL con estos consejos.', ARRAY['optimizacion', 'sql', 'rendimiento']),
('Índices en PostgreSQL', 'Todo lo que necesitas saber sobre los diferentes tipos de índices.', ARRAY['indices', 'postgresql', 'optimizacion']),
('Aprende a usar Arrays', 'Los arrays son una característica poderosa de PostgreSQL.', ARRAY['arrays', 'postgresql', 'tutorial']),
('JSONB y su potencia', 'Explora el tipo de dato JSONB para almacenar datos no estructurados.', ARRAY['jsonb', 'nosql', 'postgresql']),
('Búsqueda de texto completo', 'Implementa búsqueda de texto eficiente en tus aplicaciones.', ARRAY['texto completo', 'busca', 'postgresql']);

-- Crear índice GIN en la columna etiquetas
CREATE INDEX idx_articulos_etiquetas ON articulos USING gin (etiquetas);

-- Consultas de ejemplo para demostrar el uso del índice GIN

-- 1. Encontrar artículos que contengan una etiqueta específica (usando @> )
EXPLAIN ANALYZE
SELECT * FROM articulos WHERE etiquetas @> ARRAY['postgresql'];

-- 2. Encontrar artículos que contengan cualquiera de un conjunto de etiquetas (usando && )
EXPLAIN ANALYZE
SELECT * FROM articulos WHERE etiquetas && ARRAY['optimizacion', 'rendimiento'];

-- 3. Encontrar artículos que contengan todas las etiquetas de un conjunto (usando @> con múltiples valores)
EXPLAIN ANALYZE
SELECT * FROM articulos WHERE etiquetas @> ARRAY['postgresql', 'optimizacion'];

-- 4. Encontrar artículos que no contengan una etiqueta específica (usando <> )
-- Nota: El operador <> para arrays no es estándar; usamos NOT @> para negación de contención.
EXPLAIN ANALYZE
SELECT * FROM articulos WHERE NOT (etiquetas @> ARRAY['jsonb']);

-- 5. Consulta que no usa el índice GIN (por ejemplo, filtrando por título)
EXPLAIN ANALYZE
SELECT * FROM articulos WHERE titulo = 'Índices en PostgreSQL';

-- 6. Usando expresiones regulares en el título (no usa el índice GIN de etiquetas)
EXPLAIN ANALYZE
SELECT * FROM articulos WHERE titulo ~* 'postgresql';

-- Eliminar la tabla al final (opcional, para limpiar)
-- DROP TABLE articulos;
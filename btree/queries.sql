-- Script de ejemplo para demostrar el uso de índices B-tree en PostgreSQL

-- Eliminar la tabla si ya existe (para comenzar limpio)
DROP TABLE IF EXISTS productos;

-- Crear la tabla de productos
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    categoria VARCHAR(100),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar algunos datos de ejemplo
INSERT INTO productos (nombre, precio, categoria) VALUES
('iPhone 15', 999.99, 'Electronics'),
('Samsung Galaxy S24', 899.99, 'Electronics'),
('MacBook Pro 16"', 2499.99, 'Electronics'),
('Dell XPS 13', 1299.99, 'Electronics'),
('AirPods Pro', 249.99, 'Electronics'),
('Cafetera Expresso', 199.99, 'Home'),
('Licuadora de Vaso', 89.99, 'Home'),
('Sofá Seccional', 1499.99, 'Furniture'),
('Mesa de Centro', 349.99, 'Furniture'),
('Lámpara de Pie', 129.99, 'Home');

-- Crear índices B-tree
CREATE INDEX idx_productos_nombre ON productos (nombre);
CREATE INDEX idx_productos_precio ON productos (precio);
CREATE INDEX idx_productos_categoria_precio ON productos (categoria, precio);

-- Consultas de ejemplo para demostrar el uso de los índices

-- 1. Búsqueda por nombre exacto (usa idx_productos_nombre)
EXPLAIN ANALYZE
SELECT * FROM productos WHERE nombre = 'iPhone 15';

-- 2. Filtrado por rango de precio (usa idx_productos_precio)
EXPLAIN ANALYZE
SELECT * FROM productos WHERE precio BETWEEN 500 AND 1500;

-- 3. Ordenamiento por precio (puede usar idx_productos_precio para evitar ordenamiento)
EXPLAIN ANALYZE
SELECT * FROM productos ORDER BY precio LIMIT 5;

-- 4. Consulta compuesta por categoría y rango de precio (usa idx_productos_categoria_precio)
EXPLAIN ANALYZE
SELECT * FROM productos WHERE categoria = 'Electronics' AND precio BETWEEN 800 AND 1200;

-- 5. Consulta que usa solo la primera parte de un índice compuesto (categoria)
EXPLAIN ANALYZE
SELECT * FROM productos WHERE categoria = 'Home';

-- Eliminar la tabla al final (opcional, para limpiar)
-- DROP TABLE productos;
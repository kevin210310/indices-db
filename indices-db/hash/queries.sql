-- Script de ejemplo para demostrar el uso de índices Hash en PostgreSQL

-- Eliminar la tabla si ya existe (para comenzar limpio)
DROP TABLE IF EXISTS sesiones;

-- Crear la tabla de sesiones
CREATE TABLE sesiones (
    id SERIAL PRIMARY KEY,
    token VARCHAR(255) UNIQUE NOT NULL,
    usuario_id INTEGER NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP NOT NULL
);

-- Insertar algunos datos de ejemplo
INSERT INTO sesiones (token, usuario_id, fecha_expiracion) VALUES
('abc123def456', 1, CURRENT_TIMESTAMP + INTERVAL '1 hour'),
('def456ghi789', 2, CURRENT_TIMESTAMP + INTERVAL '2 hours'),
('ghi789jkl012', 3, CURRENT_TIMESTAMP + INTERVAL '3 hours'),
('jkl012mno345', 1, CURRENT_TIMESTAMP + INTERVAL '45 minutes'),
('mno345pqr678', 4, CURRENT_TIMESTAMP + INTERVAL '90 minutes');

-- Crear índice Hash en la columna token
CREATE INDEX idx_sesiones_token ON sesiones USING hash (token);

-- Consultas de ejemplo para demostrar el uso del índice Hash

-- 1. Búsqueda por token exacto (usa idx_sesiones_token)
EXPLAIN ANALYZE
SELECT * FROM sesiones WHERE token = 'def456ghi789';

-- 2. Búsqueda por token que no existe (para ver el comportamiento)
EXPLAIN ANALYZE
SELECT * FROM sesiones WHERE token = 'token_inexistente';

-- 3. Búsqueda por usuario_id (NO usa el índice Hash en token, podría hacer Seq Scan o usar otro índice si existiera)
EXPLAIN ANALYZE
SELECT * FROM sesiones WHERE usuario_id = 1;

-- 4. Intento de uso de rango (NO usará el índice Hash, probablemente Seq Scan)
EXPLAIN ANALYZE
SELECT * FROM sesiones WHERE usuario_id > 2;

-- 5. Intento de uso de LIKE (NO usará el índice Hash)
EXPLAIN ANALYZE
SELECT * FROM sesiones WHERE token LIKE 'abc%';

-- Eliminar la tabla al final (opcional, para limpiar)
-- DROP TABLE sesiones;
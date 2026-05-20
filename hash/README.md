# Índice Hash en PostgreSQL

## ¿Qué es un índice Hash?

Un índice Hash en PostgreSQL utiliza una tabla hash para almacenar los valores indexados. Es particularmente eficiente para consultas de igualdad exacta, pero no soporta consultas de rango, ordenamiento o patrones como `LIKE` (excepto cuando se usa con operadores de igualdad).

## ¿Cuándo usar un índice Hash?

Use un índice Hash cuando:
- Solo necesita realizar búsquedas de igualdad exacta (`=` o `IN`).
- La columna tiene alta cardinalidad y los valores están distribuidos uniformemente.
- No necesita ordenar los resultados ni realizar búsquedas de rango.
- Está dispuesto a aceptar las limitaciones del índice Hash a cambio de un rendimiento potencialmente mejor en búsquedas de igualdad.

> **Nota:** En PostgreSQL, los índices Hash no son transaccionalmente seguros en versiones anteriores a 10.0. Desde la versión 10, son seguros para su uso en producción, pero aún tienen limitaciones respecto a los índices B-tree.

## ¿Cómo crear un índice Hash en PostgreSQL?

La sintaxis es:

```sql
CREATE INDEX nombre_indice ON nombre_tabla USING hash (nombre_columna);
```

Por ejemplo, para crear un índice Hash en la columna `codigo_postal` de la tabla `direcciones`:

```sql
CREATE INDEX idx_direcciones_codigo_postal ON direcciones USING hash (codigo_postal);
```

## Ejemplo de la vida real

Imagine que tiene una tabla de sesiones de usuario en una aplicación web, donde cada sesión se identifica por un token único. Las operaciones más comunes son buscar una sesión por su token para validarla.

### Esquema de la tabla

```sql
CREATE TABLE sesiones (
    id SERIAL PRIMARY KEY,
    token VARCHAR(255) UNIQUE NOT NULL,
    usuario_id INTEGER NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP NOT NULL
);
```

### Consultas comunes

1. Validar una sesión por su token:
   ```sql
   SELECT * FROM sesiones WHERE token = 'abc123def456';
   ```

2. Verificar si existe una sesión para un usuario (si también indexamos por usuario_id, pero aquí nos enfocamos en token):
   ```sql
   SELECT * FROM sesiones WHERE usuario_id = 123; -- Esto no se beneficiaría del índice Hash en token
   ```

### Creación de índice

Para optimizar la búsqueda por token, creamos un índice Hash:

```sql
CREATE INDEX idx_sesiones_token ON sesiones USING hash (token);
```

### Verificación del uso del índice

Después de crear el índice, podemos usar `EXPLAIN` para verificar:

```sql
EXPLAIN SELECT * FROM sesiones WHERE token = 'abc123def456';
```

Debería mostrar un `Index Scan` usando el método `hash`.

## Limitaciones

- No soporta cláusulas `ORDER BY`.
- No soporta consultas de rango (`>`, `<`, `BETWEEN`, etc.).
- No soporta patrones de coincidencia como `LIKE` (a menos que se use con operadores de igualdad, lo cual no tiene sentido para patrones).
- El planificador de PostgreSQL a veces prefiere usar un índice B-tree incluso para igualdad debido a su flexibilidad, por lo que el índice Hash podría no ser utilizado en algunos casos.

## Archivo de consultas de ejemplo

El archivo `queries.sql` en este directorio contiene las sentencias SQL para crear la tabla de ejemplo, insertar algunos datos de prueba, crear el índice Hash y ejecutar consultas para demostrar su uso.

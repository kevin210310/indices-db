# Índice Bloom en PostgreSQL

## ¿Qué es un índice Bloom?

Un índice Bloom es un índice probabilístico basado en filtros de Bloom. Utiliza una estructura de datos compacta para probar si un elemento es probablemente un miembro de un conjunto, con la posibilidad de falsos positivos (pero nunca falsos negativos). En el contexto de bases de datos, un índice Bloom puede acelerar consultas que involucran múltiples condiciones de igualdad al evitar acceder a la tabla cuando el filtro indica que la fila no coincide.

## ¿Cuándo usar un índice Bloom?

Use un índice Bloom cuando:
- Tiene una tabla con muchas columnas y frecuentemente consulta por igualdad en varias de esas columnas (por ejemplo, `WHERE col1 = val1 AND col2 = val2 AND col3 = val3`).
- Las columnas indexadas tienen alta cardinalidad (muchos valores únicos).
- Está dispuesto a aceptar una pequeña tasa de falsos positivos a cambio de un uso significativamente menor de espacio y un rendimiento más rápido en ciertas consultas.
- Las operaciones de escritura son relativamente raras en comparación con las lecturas, ya que mantener el índice Bloom tiene un costo en inserciones y actualizaciones.
- Ya ha considerado otros tipos de índices (como B-tree compuesto o GIN) y encuentra que el índice Bloom ofrece un mejor equilibrio entre espacio y rendimiento para su caso de uso específico.

> **Nota:** El índice Bloom está disponible como una extensión en PostgreSQL (`bloom`). No viene instalado por defecto.

## ¿Cómo crear un índice Bloom en PostgreSQL?

Primero, necesita instalar la extensión `bloom` (una vez por base de datos):

```sql
CREATE EXTENSION IF NOT EXISTS bloom;
```

Luego, puede crear el índice Bloom en una o más columnas:

```sql
CREATE INDEX nombre_indice ON nombre_tabla USING bloom (columna1, columna2, columna3);
```

Por ejemplo, para crear un índice Bloom en las columnas `usuario_id`, `producto_id` y `pais_id` de una tabla `ventas`:

```sql
CREATE EXTENSION IF NOT EXISTS bloom;
CREATE INDEX idx_ventas_bloom ON ventas USING bloom (usuario_id, producto_id, pais_id);
```

## Ejemplo de la vida real

Imagine que tiene una tabla de análisis de ventas que registra cada transacción. Cada transacción tiene un ID de usuario, ID de producto, ID de país, timestamp y monto. Los analistas suelen ejecutar consultas para encontrar transacciones específicas combinando estos tres IDs (por ejemplo, todas las compras de un usuario específico de un producto específico en un país específico).

### Esquema de la tabla

```sql
CREATE TABLE ventas (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL,
    producto_id INTEGER NOT NULL,
    pais_id INTEGER NOT NULL,
    monto DECIMAL(10, 2) NOT NULL,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Consultas comunes

1. Encontrar todas las transacciones de un usuario y producto específicos en cualquier país:
   ```sql
   SELECT * FROM ventas WHERE usuario_id = 123 AND producto_id = 456;
   ```

2. Encontrar transacciones de un usuario específico, producto específico y país específico:
   ```sql
   SELECT * FROM ventas WHERE usuario_id = 123 AND producto_id = 456 AND pais_id = 789;
   ```

3. Encontrar transacciones donde el usuario y el país coincidan (ignorando el producto):
   ```sql
   SELECT * FROM ventas WHERE usuario_id = 123 AND pais_id = 789;
   ```

### Creación de índice

Para optimizar estas consultas de igualdad múltiple, creamos un índice Bloom en las tres columnas:

```sql
CREATE EXTENSION IF NOT EXISTS bloom;
CREATE INDEX idx_ventas_bloom ON ventas USING bloom (usuario_id, producto_id, pais_id);
```

### Verificación del uso del índice

Después de crear el índice y la extensión, podemos usar `EXPLAIN` para verificar:

```sql
EXPLAIN ANALYZE
SELECT * FROM ventas WHERE usuario_id = 123 AND producto_id = 456 AND pais_id = 789;
```

Debería mostrar un `Index Scan` usando el método `bloom`.

## Consideraciones importantes

- **Falsos positivos**: El índice Bloom puede indicar que una fila podría coincidir cuando en realidad no lo hace (falso positivo). Esto significa que la base de datos podría realizar una verificación adicional (revisar la fila real en la tabla) para descartar el falso positivo. La tasa de falsos positivos depende del número de bits y hash functions configurados en el índice (valores predeterminados suelen ser razonables).
- **No soporta rangos o ordenamiento**: El índice Bloom solo es efectivo para consultas de igualdad.
- **Mantenimiento**: Al igual que otros índices, el índice Bloom necesita ser actualizado cuando se insertan, actualizan o eliminan filas. Su overhead de mantenimiento es generalmente bajo.
- **Extensión requerida**: Recuerde crear la extensión `bloom` en su base de datos antes de usar este tipo de índice.

## Archivo de consultas de ejemplo

El archivo `queries.sql` en este directorio contiene las sentencias SQL para crear la extensión `bloom` (si no existe), crear la tabla de ejemplo, insertar algunos datos de prueba, crear el índice Bloom y ejecutar consultas para demostrar su uso en consultas de igualdad múltiple.

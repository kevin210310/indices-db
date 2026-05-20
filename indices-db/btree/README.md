# Índice B-tree en PostgreSQL

## ¿Qué es un índice B-tree?

El índice B-tree (árbol balanceado) es el tipo de índice predeterminado en PostgreSQL. Utiliza una estructura de árbol que permite búsquedas, inserciones y eliminaciones en tiempo logarítmico. Es eficiente para consultas que involucran igualdad, rangos, ordenamiento y patrones como `LIKE` (cuando el patrón no comienza con un comodín).

## ¿Cuándo usar un índice B-tree?

Use un índice B-tree cuando:
- Tiene columnas que se utilizan frecuentemente en cláusulas `WHERE` con operadores de comparación (`=`, `>`, `<`, `>=`, `<=`, `BETWEEN`, `IN`).
- Necesita ordenar resultados con `ORDER BY`.
- Está realizando uniones (`JOIN`) basadas en columnas indexadas.
- Tiene columnas con alta cardinalidad (muchos valores únicos) pero también funciona bien con baja cardinalidad.

## ¿Cómo crear un índice B-tree en PostgreSQL?

La sintaxis básica es:

```sql
CREATE INDEX nombre_indice ON nombre_tabla (nombre_columna);
```

Por ejemplo, para crear un índice B-tree en la columna `email` de la tabla `usuarios`:

```sql
CREATE INDEX idx_usuarios_email ON usuarios (email);
```

También puede especificar explícitamente el método de acceso (aunque es el predeterminado):

```sql
CREATE INDEX idx_usuarios_email ON usuarios USING btree (email);
```

## Ejemplo de la vida real

Imagine que tiene una tabla de productos en una tienda en línea con millones de registros. Los usuarios buscan productos por nombre y filtran por rango de precios.

### Esquema de la tabla

```sql
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    categoria VARCHAR(100),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Consultas comunes

1. Buscar productos por nombre exacto:
   ```sql
   SELECT * FROM productos WHERE nombre = 'iPhone 15';
   ```

2. Filtrar productos por rango de precio:
   ```sql
   SELECT * FROM productos WHERE precio BETWEEN 500 AND 1000;
   ```

3. Ordenar productos por precio:
   ```sql
   SELECT * FROM productos ORDER BY precio;
   ```

### Creación de índices

Para optimizar estas consultas, podemos crear los siguientes índices B-tree:

```sql
-- Índice para búsqueda por nombre exacto
CREATE INDEX idx_productos_nombre ON productos (nombre);

-- Índice para filtrado por rango de precio
CREATE INDEX idx_productos_precio ON productos (precio);

-- Índice para ordenamiento por precio (el mismo índice anterior puede servir)
-- También podemos crear un índice compuesto si frecuentemente filtramos por categoría y rango de precio
CREATE INDEX idx_productos_categoria_precio ON productos (categoria, precio);
```

### Verificación del uso del índice

Después de crear los índices, podemos usar `EXPLAIN` para verificar que la consulta esté usando el índice:

```sql
EXPLAIN SELECT * FROM productos WHERE nombre = 'iPhone 15';
```

Debería mostrar un `Index Scan` usando `idx_productos_nombre` en lugar de un `Seq Scan`.

## Archivo de consultas de ejemplo

El archivo `queries.sql` en este directorio contiene las sentencias SQL para crear la tabla de ejemplo, insertar algunos datos de prueba, crear los índices y ejecutar consultas para demostrar su uso.

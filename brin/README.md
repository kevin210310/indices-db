# Índice BRIN en PostgreSQL

## ¿Qué es un índice BRIN?

BRIN (Block Range Index) es un tipo de índice diseñado para tablas muy grandes donde los datos están almacenados de manera ordenada correlacionada con su ubicación física en el disco. En lugar de indexar cada valor individual, BRIN almacena resúmenes (mínimo y máximo) para cada bloque de páginas de la tabla, lo que lo hace extremadamente eficiente en términos de espacio de almacenamiento.

## ¿Cuándo usar un índice BRIN?

Use un índice BRIN cuando:
- Tiene una tabla muy grande (millones o miles de millones de filas).
- Los datos en la columna están ordenados naturalmente correlacionados con su ubicación física (por ejemplo, una columna de timestamp que aumenta con el tiempo, o un ID autoincremental).
- Las consultas suelen involucrar rangos (por ejemplo, filtrar por fechas recientes) o igualdad en columnas que tienen esta correlación.
- Necesita minimizar el espacio de almacenamiento utilizado por los índices (un índice BRIN puede ser órdenes de magnitud más pequeño que un B-tree equivalente).
- Las actualizaciones en la tabla son frecuentes y desea un índice que sea barato de mantener.

> **Nota:** BRIN es menos efectivo si los datos están desordenados o si la correlación entre el valor y la ubicación física es baja.

## ¿Cómo crear un índice BRIN en PostgreSQL?

La sintaxis es:

```sql
CREATE INDEX nombre_indice ON nombre_tabla USING brin (nombre_columna);
```

Por ejemplo, para crear un índice BRIN en una columna de timestamp `fecha_registro` en una tabla `mediciones`:

```sql
CREATE INDEX idx_mediciones_fecha ON mediciones USING brin (fecha_registro);
```

También puede especificar el número de páginas por rango (el valor por defecto es 128):

```sql
CREATE INDEX idx_mediciones_fecha ON mediciones USING brin (fecha_registro) WITH (pages_per_range = 32);
```

## Ejemplo de la vida real

Imagine que tiene un sistema de monitoreo que registra mediciones de sensores cada segundo. La tabla `mediciones` tiene miles de millones de filas, cada una con un timestamp y un valor medido. Las consultas más comunes son obtener las mediciones de las últimas 24 horas o de una semana específica.

### Esquema de la tabla

```sql
CREATE TABLE mediciones (
    id SERIAL PRIMARY KEY,
    sensor_id INTEGER NOT NULL,
    valor DECIMAL(10, 4) NOT NULL,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Consultas comunes

1. Obtener las mediciones de la última hora:
   ```sql
   SELECT * FROM mediciones WHERE fecha_registro >= NOW() - INTERVAL '1 hour';
   ```

2. Obtener las mediciones de un día específico:
   ```sql
   SELECT * FROM mediciones 
   WHERE fecha_registro >= '2026-05-01' 
     AND fecha_registro < '2026-05-02';
   ```

3. Obtener el valor máximo de un sensor en una semana:
   ```sql
   SELECT MAX(valor) FROM mediciones 
   WHERE sensor_id = 42 
     AND fecha_registro >= '2026-04-28'
     AND fecha_registro < '2026-05-05';
   ```

### Creación de índice

Para optimizar estas consultas por rango de tiempo, creamos un índice BRIN en la columna `fecha_registro`:

```sql
CREATE INDEX idx_mediciones_fecha ON mediciones USING brin (fecha_registro);
```

### Verificación del uso del índice

Después de crear el índice, podemos usar `EXPLAIN` para verificar:

```sql
EXPLAIN ANALYZE
SELECT * FROM mediciones 
WHERE fecha_registro >= NOW() - INTERVAL '1 hour';
```

Debería mostrar un `Index Scan` usando el método `brin`.

## Consideraciones importantes

- **Correlación**: La eficacia de BRIN depende de la correlación entre el orden de los valores y su ubicación física. Puede verificar la correlación con:
  ```sql
  SELECT correlation(fecha_registro, ctid) FROM mediciones;
  ```
  Un valor cercano a 1 o -1 indica buena correlación.
- **Mantenimiento**: Si los datos se insertan siempre al final (como en una serie temporal), el índice BRIN se mantiene eficiente. Si hay actualizaciones que mueven filas, puede ser necesario volver a crear el índice ocasionalmente.
- **Combinación con otros índices**: En ocasiones, puede ser beneficioso tener un índice BRIN para filtrado por rango rápido y luego un índice secundario (como B-tree) para otras condiciones.

## Archivo de consultas de ejemplo

El archivo `queries.sql` en este directorio contiene las sentencias SQL para crear la tabla de ejemplo, insertar muchos datos de prueba (simulando una serie temporal), crear el índice BRIN y ejecutar consultas para demostrar su uso en filtrado por rangos de tiempo.

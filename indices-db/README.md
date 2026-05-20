# Índices en Base de Datos

Este proyecto tiene como objetivo explicar los diferentes tipos de índices en bases de datos, específicamente en PostgreSQL, y proporcionar ejemplos prácticos de su uso.

## ¿Qué es un índice?

Un índice en una base de datos es una estructura de datos que mejora la velocidad de las operaciones de lectura (SELECT) en una tabla, a costa de un espacio adicional y una ligera disminución en el rendimiento de las operaciones de escritura (INSERT, UPDATE, DELETE). Funciona de manera similar a un índice en un libro, permitiendo que la base de datos encuentre rápidamente las filas que coinciden con una condición sin tener que escanear toda la tabla.

## Tipos de índices en PostgreSQL
En este proyecto, exploramos los siguientes tipos de índices:

- [B-tree](#btree)
- [Hash](#hash)
- [GiST](#gist)
- [GIN](#gin)
- [BRIN](#brin)
- [Bloom](#bloom)

Cada tipo de índice tiene sus propias características, ventajas y casos de uso ideales. A continuación, se proporciona una breve descripción de cada uno. Para obtener más detalles, incluidos ejemplos de uso y cuándo aplicarlos, consulte los directorios específicos para cada tipo de índice.

### B-tree
El índice B-tree es el tipo de índice predeterminado en PostgreSQL. Es adecuado para una amplia gama de consultas, incluyendo igualdad, rangos y patrones de ordenamiento.

### Hash
Los índices hash son eficientes para consultas de igualdad, pero no soportan consultas de rango o ordenamiento. Son menos comunes que los B-tree debido a sus limitaciones.

### GiST (Generalized Search Tree)
GiST es un índice flexible que puede adaptarse a muchos tipos de datos y operadores, incluyendo datos geométricos, texto completo y más.

### GIN (Generalized Inverted Index)
GIN está diseñado para manejar valores compuestos, como arrays, documentos JSONB o búsquedas de texto completo, donde se busca la presencia de un elemento dentro de un valor compuesto.

### BRIN (Block Range Index)
BRIN está diseñado para tablas muy grandes donde los datos están almacenados de manera ordenada correlacionada con su ubicación física. Es muy eficiente en espacio y útil para columnas con ordenamiento natural (como timestamps).

### Bloom
El índice Bloom es un índice probabilístico basado en filtros de Bloom. Es útil para columnas con alta cardinalidad y múltiples condiciones de igualdad, ofreciendo un uso eficiente de espacio a cambio de una pequeña probabilidad de falsos positivos.


## Desventajas

1. INSERT más lento

Cuando haces:

```
INSERT INTO usuarios ...
```

PostgreSQL debe:

guardar fila
actualizar TODOS los índices

Si tienes:

15 índices

cada INSERT es más caro.

2. UPDATE más lento

Peor si modificas columnas indexadas.

Ejemplo:

```
UPDATE usuarios
SET email = 'nuevo@mail.com'
```

Debe:

borrar índice viejo
crear nuevo

3. DELETE más lento

También actualiza índices.

4. Consumen disco

Índices gigantes pueden pesar más que la tabla.

Puedes verlo con:

```
SELECT
    pg_size_pretty(pg_indexes_size('usuarios'));
```

5. Más RAM usada

PostgreSQL intenta cachear índices en memoria.

Muchos índices:

más RAM
más presión de cache

6. VACUUM y mantenimiento más costoso

Más índices:

más trabajo de mantenimiento
más fragmentación

## Cómo usar este proyecto

Cada tipo de índice tiene su propio directorio dentro de este proyecto. En cada directorio, encontrará:

- Un `README.md` detallado que explica:
  - Qué es el índice y cómo funciona.
  - Cuándo usarlo (casos de uso).
  - Cómo crearlo y usarlo en PostgreSQL.
  - Un ejemplo de la vida real.
- Un archivo `queries.sql` que contiene sentencias SQL de ejemplo para crear el índice, probarlo y ver su efecto en el rendimiento.

Para comenzar, navegue a uno de los directorios de tipo de índice y lea su `README.md`.

## Requisitos

- PostgreSQL instalado y en ejecución.
- Acceso a una base de datos donde pueda crear tablas e índices (por ejemplo, a través de `psql` o una herramienta gráfica).

## Contribuir

Si desea agregar más tipos de índices o mejorar la documentación, siéntase libre de hacer un fork del proyecto y enviar un pull request.

## Licencia

Este proyecto está bajo la licencia MIT - vea el archivo [LICENSE](LICENSE) para más detalles.
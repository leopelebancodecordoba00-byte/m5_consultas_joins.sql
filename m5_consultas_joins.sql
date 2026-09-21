-- M5 - CONSULTAS CON JOINs PARA EL PROYECTO
-- Proyecto: RetailPro - Ventas_Tech_DB
   
USE Ventas_Tech_DB;

  -- CONSULTA 1 - Vista base del proyecto (INNER JOIN)
  -- Cruza ventas + clientes + productos + categorias
  -- Incluye ciudad (dimensión geográfica) como columna
  -- Para agrupar/filtrar en Power BI.

SELECT
    v.fecha_venta,
    c.id_cliente,
    c.nombre_cliente,
    c.ciudad,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas v
INNER JOIN clientes c
    ON v.id_cliente = c.id_cliente
INNER JOIN productos p
    ON v.id_producto = p.id_producto
INNER JOIN categorias cat
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;



-- CONSULTA 2 - Clientes sin ventas (LEFT JOIN)

SELECT
    c.nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v
    ON c.id_cliente = v.id_cliente
WHERE v.id_cliente IS NULL;


--CONSULTA 3 - Productos sin ventas (LEFT JOIN)

SELECT
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v
    ON p.id_producto = v.id_producto
WHERE v.id_producto IS NULL;


/* ------------------------------------------------------------
   CONSULTA 4 - Consolidado por canal (UNION ALL)
   La columna "canal" no se consulta, se crea como literal.
   Criterio elegido: dos períodos de venta (quincenas de marzo 2024).
   Primero se unen las ventas fila por fila con su canal (UNION ALL)
   y luego se agrupa ese resultado con GROUP BY para el total por canal.
   ------------------------------------------------------------ */
WITH ventas_por_canal AS (
    SELECT
        fecha_venta AS fecha,
        (cantidad * precio_unitario) AS total,
        'Primera Quincena' AS canal
    FROM ventas
    WHERE fecha_venta < '2024-03-10'

    UNION ALL

    SELECT
        fecha_venta AS fecha,
        (cantidad * precio_unitario) AS total,
        'Segunda Quincena' AS canal
    FROM ventas
    WHERE fecha_venta >= '2024-03-10'
)
SELECT
    canal,
    COUNT(*) AS cantidad_ventas,
    SUM(total) AS total_por_canal
FROM ventas_por_canal
GROUP BY canal;

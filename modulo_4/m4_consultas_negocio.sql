
-- M4 - Consultas SQL de negocio
 
USE Ventas_Tech_DB;
GO
 

-- Consulta 1: Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio, por mes

    SELECT
        MONTH(fecha_venta)                             AS mes,
        SUM(cantidad * precio_unitario)                AS total_facturado,
        COUNT(*)                                        AS cantidad_pedidos,
        SUM(cantidad * precio_unitario) / COUNT(*)      AS ticket_promedio
    FROM ventas
    GROUP BY MONTH(fecha_venta)
    ORDER BY mes;
    GO
 

-- Consulta 2: Ranking de productos (Top 5 por total facturado)

SELECT TOP 5
    id_producto,
    SUM(cantidad)                                   AS unidades_vendidas,
    SUM(cantidad * precio_unitario)                 AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
GO
 

-- Consulta 3: Clientes recurrentes (más de un pedido)

SELECT
    id_cliente,
    COUNT(*)                                        AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)                 AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
GO
 

-- Consulta 4: Meses por encima/por debajo del promedio

SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_mensual) FROM (
            SELECT SUM(cantidad * precio_unitario) AS total_mensual
            FROM ventas
            GROUP BY MONTH(fecha_venta)
        ) AS promedios)
        THEN 'Por encima'
        ELSE 'Por debajo'
    END                                              AS comparacion_promedio
FROM (
    SELECT
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
) AS resumen_mensual
ORDER BY mes;
GO
 

-- Hallazgos:
-- 1. El producto 1 concentra aproximadamente el 56% de la facturación total
--    del período ($3600 sobre $6444) debido a su alto precio unitario,
--    a pesar de tener solo 3 unidades vendidas.
-- 2. Los 5 clientes de la base son recurrentes: cada uno realizó
--    2 pedidos.
-- 3. Todas las ventas cargadas caen dentro de marzo de 2024 (mes 3), por lo
--    que el análisis de "por encima/por debajo del promedio" no es
--    representativo todavía: se necesitan mas datos y de más meses para que la
--    comparación mensual tenga sentido.

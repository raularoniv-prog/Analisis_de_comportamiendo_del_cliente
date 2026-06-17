
use  customer_behavior
SELECT * FROM cliente

--¿Cuál es el ingreso total generado por clientes masculinos vs. femeninos?

select género, sum(monto_de_compra) as ganancia
From cliente
group by género

--Q2. ¿Qué clientes utilizaron un descuento pero aun así gastaron más que el monto promedio de compra?


SELECT id_cliente, monto_de_compra
FROM cliente
WHERE descuento_aplicado = 'Sí' 
  AND monto_de_compra >= (SELECT AVG(monto_de_compra) FROM cliente);

--Q3. ¿Cuáles son los 5 productos principales con la calificación promedio de reseña más alta?

SELECT top 5 artículo_comprado, ROund(AVG(calificación),2) as 'calificacion_promedio_del_producto'
From cliente
Group BY artículo_comprado
ORDER BY AVG(calificación) desc ;

--Q4. Compara los montos promedio de compra entre el envío Estándar (Standard) y el Exprés (Express).

SELECT tipo_de_envío,
ROUND(AVG(monto_de_compra),2) as 'monto_promedio'
FROM cliente
WHERE tipo_de_envío in ('Exprés','Estándar')
GROUP BY tipo_de_envío

--Q5. ¿Los clientes suscritos gastan más? Compara el gasto promedio y el ingreso total entre suscriptores y no suscriptores.
SELECT estado_de_suscripción, 
COUNT (id_cliente) AS cliente_totales,
ROUND(AVG(monto_de_compra),2) AS gasto_promedio,
ROUND(SUM(monto_de_compra),2) AS total_ingresos
FROM cliente
GROUP BY estado_de_suscripción
ORDER BY gasto_promedio,total_ingresos desc;

--Q6. ¿Cuáles 5 productos tienen el mayor porcentaje de compras con descuentos aplicados?

SELECT TOP 5 artículo_comprado,
ROUND(100 * SUM(CASE WHEN descuento_aplicado = 'Sí' THEN 1 ELSE 0 END)/COUNT(*),2) AS 'tasa_de_descuento'
FROM cliente
GROUP BY artículo_comprado
ORDER BY tasa_de_descuento DESC

--Q7. Segmenta a los clientes en Nuevos (New), Recurrentes (Returning) y Fieles (Loyal) según su número total de compras anteriores, y muestra el recuento de cada segmento.
WITH tipo_de_cliente AS (
SELECT id_cliente, compras_anteriores,
CASE 
    WHEN compras_anteriores = 1 THEN'Nuevo'
    WHEN compras_anteriores BETWEEN  2 AND 10 THEN 'Recurrentes'
    ELSE 'Leal'
    END AS segmento_de_cliente
FROM cliente
)
SELECT segmento_de_cliente, COUNT(*) AS "numero_de_cientes"
FROM tipo_de_cliente
GROUP BY segmento_de_cliente

--Q8. ¿Cuáles son los 3 productos más comprados dentro de cada categoría?

WITH recuento_de_articulo AS (
SELECT categoría, artículo_comprado,
COUNT(id_cliente) AS 'pedidos_totales',
ROW_NUMBER() OVER(PARTITION BY categoría ORDER BY COUNT(id_cliente) DESC) AS 'clasificacion_del_articulo'
FROM cliente
GROUP BY categoría, artículo_comprado)

SELECT clasificacion_del_articulo, categoría, artículo_comprado, pedidos_totales
FROM recuento_de_articulo
WHERE clasificacion_del_articulo <= 3;

--Q9. ¿Es probable que los clientes que son compradores repetitivos (más de 5 compras anteriores) también se suscriban?

SELECT estado_de_suscripción,
COUNT(id_cliente) AS 'compradores_recurrentes'
FROM cliente
WHERE compras_anteriores > 5
GROUP BY estado_de_suscripción

--Q10. ¿Cuál es la contribución de ingresos de cada grupo de edad?

SELECT grupo_de_edad,
SUM(monto_de_compra) AS total_ganancia
FROM cliente
GROUP BY grupo_de_edad
ORDER BY total_ganancia DESC

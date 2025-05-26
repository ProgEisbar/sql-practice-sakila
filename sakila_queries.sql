
-- sakila_queries.sql
-- Consultas SQL resueltas utilizando la base de datos Sakila
-- Autor: Joaquin Salas
-- Descripción: Consultas SQL clasificadas por nivel y propósito

-- ====================================
-- 1. CONSULTAS BÁSICAS
-- ====================================

-- 1.1 Monto total de pagos de alquileres entre 30 y 60 días
SELECT SUM(p.amount) AS total_pago
FROM rental r
JOIN payment p ON r.rental_id = p.rental_id
WHERE DATEDIFF(r.return_date, r.rental_date) BETWEEN 30 AND 60;

-- 1.2 Total de clientes y cuántos realizaron al menos un alquiler
SELECT 
    COUNT(*) AS total_clientes,
    COUNT(DISTINCT r.customer_id) AS clientes_con_alquiler
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id;

-- 1.3 Pago mínimo, máximo y total agrupado por duración del alquiler
SELECT 
    CASE 
        WHEN DATEDIFF(r.return_date, r.rental_date) BETWEEN 0 AND 3 THEN '0-3 días'
        WHEN DATEDIFF(r.return_date, r.rental_date) BETWEEN 4 AND 7 THEN '4-7 días'
        WHEN DATEDIFF(r.return_date, r.rental_date) BETWEEN 8 AND 14 THEN '8-14 días'
        ELSE '15+ días'
    END AS rango_dias,
    MIN(p.amount) AS pago_minimo,
    MAX(p.amount) AS pago_maximo,
    SUM(p.amount) AS pago_total
FROM rental r
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY rango_dias;

-- 1.4 Lista de películas por categoría concatenadas
SELECT 
    c.name AS categoria,
    GROUP_CONCAT(f.title ORDER BY f.title SEPARATOR ', ') AS peliculas
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY c.name;

-- ====================================
-- 2. MEJORA DE CONSULTAS
-- ====================================

-- 2.5a Número de películas por categoría para 'Action' y 'Comedy'
SELECT 
    c.name AS categoria,
    COUNT(*) AS cantidad_peliculas
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
WHERE c.name IN ('Action', 'Comedy')
GROUP BY c.name;

-- 2.5b Promedio de gasto y antigüedad de clientes por ciudad
SELECT 
    ci.city,
    ROUND(AVG(p.amount), 2) AS promedio_gasto,
    ROUND(AVG(DATEDIFF(CURDATE(), c.create_date)), 0) AS antiguedad_promedio_dias
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY ci.city
ORDER BY promedio_gasto DESC
LIMIT 5;

-- ====================================
-- 3. CONSULTAS CON CONDICIONES ESPECÍFICAS
-- ====================================

-- 3.6a Clientes que alquilaron en 2005 y gastaron más de $100 ese año
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name,
    SUM(p.amount) AS total_2005
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
WHERE YEAR(p.payment_date) = 2005
GROUP BY c.customer_id
HAVING SUM(p.amount) > 100;

-- 3.6b Clientes que NO alquilaron en 2005 pero gastaron más de $100 en total
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name,
    SUM(p.amount) AS total_pago
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
WHERE c.customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM payment
    WHERE YEAR(payment_date) = 2005
)
GROUP BY c.customer_id
HAVING SUM(p.amount) > 100;

-- ====================================
-- 4. ANÁLISIS TEMPORAL
-- ====================================

-- 4.7 Informe histórico anual de alquileres por tienda
WITH alquileres_por_año AS (
    SELECT 
        s.store_id,
        YEAR(r.rental_date) AS anio,
        COUNT(*) AS cantidad
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN store s ON i.store_id = s.store_id
    GROUP BY s.store_id, YEAR(r.rental_date)
),
alquileres_con_acumulado AS (
    SELECT 
        store_id,
        anio,
        cantidad,
        SUM(cantidad) OVER (PARTITION BY store_id ORDER BY anio) AS acumulado,
        LAG(cantidad) OVER (PARTITION BY store_id ORDER BY anio) AS cantidad_anterior
    FROM alquileres_por_año
)
SELECT *,
    ROUND((cantidad - cantidad_anterior) / cantidad_anterior * 100, 2) AS variacion_pct
FROM alquileres_con_acumulado;

-- ====================================
-- 5. OPTIMIZACIÓN DE RENDIMIENTO
-- ====================================

-- 5.8 Estrategias sugeridas:
-- - Crear índices en columnas: rental_date, customer_id, store_id, etc.
-- - Materializar vistas de resúmenes si el volumen es alto.
-- - Evitar SELECT * y funciones en columnas filtradas.

-- 5.9 Reportes optimizados por año y mes (recomendación):
-- - Crear tabla resumen mensual con customer_id, año, mes, total_pago.
-- - Agregar columnas computadas para truncar fecha.

-- ====================================
-- 6. CONSULTAS ADICIONALES
-- ====================================

-- 6.10a Total de ingresos por cliente por año
SELECT customer_id, YEAR(payment_date) AS anio, SUM(amount) AS total
FROM payment
GROUP BY customer_id, anio;

-- 6.10b Total de ingresos por cliente por mes (2005)
SELECT customer_id, MONTH(payment_date) AS mes, SUM(amount) AS total
FROM payment
WHERE YEAR(payment_date) = 2005
GROUP BY customer_id, mes;

-- 6.10c Total de ingresos entre fechas específicas
SELECT customer_id, SUM(amount) AS total
FROM payment
WHERE payment_date BETWEEN '2005-07-01' AND '2005-09-30'
GROUP BY customer_id;

-- 6.11 Total de días de alquiler por cliente (2005)
SELECT 
    r.customer_id,
    SUM(DATEDIFF(r.return_date, r.rental_date)) AS total_dias
FROM rental r
WHERE YEAR(r.rental_date) = 2005
GROUP BY r.customer_id;

-- 6.12a Tiendas más populares en 2005
SELECT s.store_id, COUNT(*) AS cantidad
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN store s ON i.store_id = s.store_id
WHERE YEAR(r.rental_date) = 2005
GROUP BY s.store_id
ORDER BY cantidad DESC;

-- 6.12b Alquileres por tienda y mes en 2006
SELECT 
    s.store_id, 
    MONTH(r.rental_date) AS mes, 
    COUNT(*) AS cantidad
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN store s ON i.store_id = s.store_id
WHERE YEAR(r.rental_date) = 2006
GROUP BY s.store_id, mes;

-- 6.12c Tiendas más populares en julio de 2005
SELECT s.store_id, COUNT(*) AS cantidad
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN store s ON i.store_id = s.store_id
WHERE r.rental_date BETWEEN '2005-07-01' AND '2005-07-31'
GROUP BY s.store_id;

-- 6.13a Muestra aleatoria: 10% de alquileres
SELECT * 
FROM rental
ORDER BY RAND()
LIMIT (SELECT ROUND(COUNT(*) * 0.10) FROM rental);

-- 6.13b Muestra aleatoria: 20% de alquileres por tienda
SELECT * 
FROM (
    SELECT r.*, 
           ROW_NUMBER() OVER (PARTITION BY i.store_id ORDER BY RAND()) AS rn,
           COUNT(*) OVER (PARTITION BY i.store_id) AS total_por_tienda
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
) sub
WHERE rn <= total_por_tienda * 0.2;

-- 6.13c Muestra aleatoria: 1000 clientes
SELECT * 
FROM customer
ORDER BY RAND()
LIMIT 1000;

-- 6.14 Total de ingresos por cliente ordenado por fecha
SELECT 
    p.customer_id, 
    p.payment_date, 
    SUM(p.amount) AS total
FROM payment p
GROUP BY p.customer_id, p.payment_date
ORDER BY p.payment_date;

-- 6.15 Ranking de clientes por días totales de alquiler
SELECT 
    r.customer_id,
    SUM(DATEDIFF(r.return_date, r.rental_date)) AS total_dias,
    RANK() OVER (ORDER BY SUM(DATEDIFF(r.return_date, r.rental_date)) DESC) AS ranking
FROM rental r
GROUP BY r.customer_id;

-- 6.16 Participación en ingresos por cliente
SELECT 
    customer_id,
    SUM(amount) AS total_cliente,
    ROUND(SUM(amount) / (SELECT SUM(amount) FROM payment) * 100, 2) AS porcentaje
FROM payment
GROUP BY customer_id;

-- 6.17 Promedio de importe de pagos por mes y año
SELECT 
    YEAR(payment_date) AS anio,
    MONTH(payment_date) AS mes,
    ROUND(AVG(amount), 2) AS promedio_pago
FROM payment
GROUP BY anio, mes;

-- 6.18 Clientes que alquilaron en una ciudad específica
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN rental r ON c.customer_id = r.customer_id
WHERE ci.city = 'Buenos Aires'; -- cambiar por la ciudad deseada

-- 6.19 Total de días de alquiler por cliente en una ciudad específica
SELECT 
    c.customer_id, 
    SUM(DATEDIFF(r.return_date, r.rental_date)) AS total_dias
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN rental r ON c.customer_id = r.customer_id
WHERE ci.city = 'Buenos Aires'
GROUP BY c.customer_id
ORDER BY total_dias DESC;

-- 6.20 Alquileres por ciudad en un mes específico
SELECT 
    ci.city,
    COUNT(*) AS total_alquileres
FROM rental r
JOIN customer c ON r.customer_id = c.customer_id
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
WHERE r.rental_date BETWEEN '2005-07-01' AND '2005-07-31'
GROUP BY ci.city;

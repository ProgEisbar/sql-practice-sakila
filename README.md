# sql-practice-sakila
Consultas SQL resueltas con base de datos Sakila como parte de mi portfolio de análisis de datos.

Este proyecto forma parte de mi portfolio como **Data Analyst / Data Engineer en formación**. Incluye una serie de **consultas SQL** resueltas utilizando la base de datos de ejemplo **Sakila**, ampliamente utilizada para practicar habilidades de SQL en escenarios similares a los del mundo real.

---

Sobre mí

Soy estudiante de Ciencias de Datos con foco en Ingeniería y Análisis de Datos. Este proyecto es parte de mi portfolio técnico para mostrar mis habilidades en el uso de SQL aplicado a datos reales.

Conectá conmigo en [LinkedIn](https://www.linkedin.com/in/salasj/)

---

Objetivos del proyecto

- Practicar SQL desde nivel básico hasta avanzado.
- Aplicar funciones agregadas, joins, subconsultas, CTEs y funciones de ventana.
- Simular análisis de negocio como ingresos por cliente, ranking, análisis temporal, etc.
- Mostrar buenas prácticas y claridad en la escritura de consultas SQL.

---

Dataset: Sakila

La base de datos [Sakila](https://dev.mysql.com/doc/sakila/en/) representa el negocio de un videoclub:
- Clientes, películas, alquileres, pagos, tiendas, ciudades, actores.
- Esquema relacional realista y buena cantidad de registros.

**Nota**: Sakila puede instalarse fácilmente en MySQL o importarse en entornos como DBeaver, DB Fiddle, etc.

---

¿Qué tipo de consultas incluye?

✅ Agrupaciones por fechas, ciudades, tiendas  
✅ Concatenación de resultados (`GROUP_CONCAT`)  
✅ Subconsultas y `HAVING` para filtros agregados  
✅ Funciones de ventana: `RANK()`, `LAG()`, `ROW_NUMBER()`  
✅ Análisis por año, mes, y entre rangos de fechas  
✅ Participación porcentual y ranking de clientes  
✅ Muestras aleatorias con `RAND()`  
✅ Estrategias de optimización sugeridas

---

Consultas destacadas

- **Informe histórico anual de alquileres por tienda** con acumulado y variación porcentual.
- **Ranking de clientes** por días totales de alquiler usando `RANK()`.
- **Porcentaje de participación** de cada cliente en los ingresos totales.
- **Agrupación de películas** por categoría con `GROUP_CONCAT`.
- **Clientes que alquilaron o no en determinado año** y cruzar con gasto total.

---
 Cómo ejecutar las consultas

1. Instalar MySQL o usar una herramienta como DBeaver, MySQL Workbench, DB Fiddle o SQLite con adaptaciones.
2. Descargar e importar la base de datos Sakila desde:
   [https://dev.mysql.com/doc/sakila/en/](https://dev.mysql.com/doc/sakila/en/)
3. Abrir el archivo `sakila_queries_completo.sql` y ejecutar secciones según tu interés.

---

Licencia

Este repositorio se comparte con fines educativos y de portfolio bajo licencia MIT.


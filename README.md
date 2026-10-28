# Automatizaci-n-de-Reporte-de-Ventas-Semanal

# Manual de uso
# Objetivo
Automatizar la obtención del resumen ejecutivo de ventas agrupado por canal y categoría para un rango de fechas parametrizable, permitiendo que cualquier miembro del equipo comercial obtenga resultados consistentes.

# Prerrequisitos
Microsoft SQL Server Management Studio (SSMS) instalado.

Acceso a la base de datos con la tabla ventas_historial cargada.

# Pasos para Ejecutar el Reporte
Abre SSMS y conéctate a tu servidor de base de datos.

Abre una nueva ventana de consulta (New Query).

Asegúrate de seleccionar la base de datos correspondiente (ej. USE clase; o USE Ventas_Tech_DB;).

Copia y pega el siguiente script T-SQL:

SQL
-- Parámetros de entrada (Modificar las fechas según el rango requerido)
DECLARE @FechaInicio DATETIME = '2025-01-01 00:00:00';
DECLARE @FechaFin DATETIME = '2025-06-30 23:59:59';

-- Consulta de agregación y resumen ejecutivo
SELECT 
    channel,
    product_category,
    COUNT(order_id) AS cantidad_pedidos,
    ROUND(SUM(amount), 2) AS total_facturado,
    ROUND(AVG(amount), 2) AS ticket_promedio
FROM 
    ventas_historial
WHERE 
    date >= @FechaInicio 
    AND date <= @FechaFin
GROUP BY 
    channel, 
    product_category
ORDER BY 
    total_facturado DESC;
Parametrización: Modifica los valores de @FechaInicio y @FechaFin en las líneas 2 y 3 sin alterar la estructura del resto del código.

Presiona Execute (F5) para correr la consulta.

(Opcional) Para exportar los resultados a Excel/CSV: Haz clic derecho sobre la cuadrícula de resultados (Results), selecciona Save Results As... (Guardar resultados como) y guarda el archivo en formato .csv.

# diccionario de datos:
channel, Canal de venta a través del cual se originó el pedido (ej: Web, Store, Mobile, B2B Portal).
product_category,Categoría del producto vendido (ej: Electronics, Clothing, Home & Kitchen).
total_facturado, Suma total del monto vendido (amount) expresado con dos decimales.
ticket_promedio, Valor promedio facturado por pedido (total_facturado / cantidad_pedidos), redondeado a dos decimales.

# Troubleshooting:
Caso 1: El formato de fecha cambia en el archivo origen
Problema: El CSV entrante utiliza un formato regional distinto (ej. DD/MM/YYYY en lugar de YYYY-MM-DD HH:MM:SS).

Causa: SQL Server no puede interpretar implícitamente cadenas en formatos no Estándar ISO.

Solución: Al realizar consultas directas o conversiones, aplica la función TRY_CONVERT o PARSE especificando el código de estilo (103 para formato británico/italiano DD/MM/YYYY):

SQL
SELECT TRY_CONVERT(DATETIME, '31/01/2025', 103);
Caso 2: Registros con valores nulos (NULL) en amount o date
Problema: Al ejecutar agregaciones (SUM o AVG), SQL Server arroja la advertencia "Warning: Null value is eliminated by an aggregate or other SET operation".

Solución: Incluir un filtro explícito en la cláusula WHERE para ignorar filas corruptas/incompletas:

SQL
WHERE date IS NOT NULL 
  AND amount IS NOT NULL
  AND date >= @FechaInicio 
  AND date <= @FechaFin
Caso 3: La consulta devuelve 0 registros
Problema: La consulta se ejecuta sin errores pero la tabla de resultados aparece vacía.

Solución:

Verifica que las fechas del parámetro abarquen registros existentes ejecutando: SELECT MIN(date), MAX(date) FROM ventas_historial;.

Revisa que el filtro de hora no esté excluyendo ventas del último día (asegúrate de usar '23:59:59' en la fecha de fin o usar < DATEADD(day, 1, @FechaFin)).
